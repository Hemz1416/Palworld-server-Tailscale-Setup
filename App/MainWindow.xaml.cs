using System;
using System.Diagnostics;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using HemzPalworldConnectionSetup.Models;
using HemzPalworldConnectionSetup.Services;
using HemzPalworldConnectionSetup.Views;
using Microsoft.Win32;

namespace HemzPalworldConnectionSetup;

public partial class MainWindow : Window
{
    private readonly TailscaleService _tailscale = new();
    private readonly NetworkProbeService _networkProbe;
    private ConnectionConfig _config = ConfigManager.Current;

    private string? _discoveredServerIp;
    private string? _discoveredServerName;
    private string? _detectedPalworldExe;
    private bool _isPasswordRevealed = false;
    private CancellationTokenSource? _authPollCts;

    public MainWindow()
    {
        InitializeComponent();
        _networkProbe = new NetworkProbeService(_tailscale);

        Loaded += MainWindow_Loaded;
        Closing += MainWindow_Closing;
    }

    private async void MainWindow_Loaded(object sender, RoutedEventArgs e)
    {
        Logger.Initialize("1.0.0");
        ApplyConfigToUI();

        // 1. Check Windows compatibility
        if (!Environment.Is64BitOperatingSystem)
        {
            MessageBox.Show(this, "Palworld and Tailscale require a 64-bit version of Windows.", "Unsupported System", MessageBoxButton.OK, MessageBoxImage.Error);
            Logger.Log("[FATAL] 32-bit Windows detected; aborting.");
            Close();
            return;
        }

        // 2. Detect Palworld game
        CheckPalworldInstallation();

        // 3. Begin Tailscale & Shared Server connection workflow
        await InitializeConnectionWorkflowAsync();
    }

    private void MainWindow_Closing(object? sender, System.ComponentModel.CancelEventArgs e)
    {
        _authPollCts?.Cancel();
    }

    private void ApplyConfigToUI()
    {
        TxtHeaderTitle.Text = string.IsNullOrWhiteSpace(_config.AppName) ? "TAILSCALE CONNECTION SETUP" : _config.AppName.ToUpperInvariant();
        TxtHeaderSubtitle.Text = $"Private Tailscale Connection to the Shared {_config.ServerName} Machine";
        TxtServerName.Text = _config.ServerName;
        TxtServerDevice.Text = !string.IsNullOrWhiteSpace(_config.ServerMagicDnsName) 
            ? _config.ServerMagicDnsName 
            : _config.ServerDeviceName;

        string proto = _config.ServerPort == 25565 ? "TCP" : (_config.ServerPort == 8211 ? "UDP" : "Port");
        LblPortDiag.Text = $"{proto} {_config.ServerPort} Diagnostic:";

        bool isMinecraft = _config.ServerName.Contains("Minecraft", StringComparison.OrdinalIgnoreCase) || _config.ServerPort == 25565;
        LblGameClient.Text = isMinecraft ? "MINECRAFT GAME CLIENT" : (_config.ServerPort == 8211 ? "PALWORLD GAME CLIENT" : "GAME CLIENT");
        BtnBrowseGame.Content = isMinecraft ? "Browse Minecraft" : (_config.ServerPort == 8211 ? "Browse Palworld.exe" : "Browse Executable");
        BtnConnectGame.Content = isMinecraft ? "CONNECT TO MINECRAFT" : (_config.ServerPort == 8211 ? "CONNECT TO PALWORLD" : "CONNECT & COPY");

        ChkRememberPassword.IsChecked = ConfigManager.Settings.RememberPassword;

        if (string.IsNullOrWhiteSpace(_config.PalworldServerPassword))
        {
            TxtPasswordMasked.Text = "(None configured)";
            BtnTogglePassword.Visibility = Visibility.Collapsed;
        }
        else
        {
            TxtPasswordMasked.Text = "••••••••••••";
            BtnTogglePassword.Visibility = Visibility.Visible;
        }
    }

    private void CheckPalworldInstallation()
    {
        _detectedPalworldExe = PalworldDetector.DetectPalworldExecutable(_config.PalworldExecutableHint);
        if (_detectedPalworldExe != null)
        {
            TxtPalworldDetectedPath.Text = _detectedPalworldExe;
            TxtPalworldDetectedPath.Foreground = new SolidColorBrush(Color.FromRgb(0x34, 0xD3, 0x99));
        }
        else
        {
            TxtPalworldDetectedPath.Text = "Not detected automatically (Use 'Browse Palworld.exe' if needed)";
            TxtPalworldDetectedPath.Foreground = new SolidColorBrush(Color.FromRgb(0xF5, 0x9E, 0x0B));
        }
    }

    private async Task InitializeConnectionWorkflowAsync()
    {
        ProgressBarAction.IsIndeterminate = true;

        // Step 1: Check Tailscale installed
        if (!_tailscale.IsTailscaleInstalled())
        {
            Logger.Log("Tailscale is not installed. Prompting user for automatic installation...");
            TxtClientStatus.Text = "Missing - Installing...";
            TxtServiceStatus.Text = "Not Installed";
            UpdateBadge(BadgeTailscale, TxtBadgeTailscale, "● Tailscale: Missing", "#EF4444");

            var result = MessageBox.Show(this,
                "Tailscale is required to connect to the shared Hemz Palworld Dedicated Server machine.\n\nWould you like this application to automatically download and install official Tailscale now?",
                "Tailscale Required",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question);

            if (result == MessageBoxResult.Yes)
            {
                bool installed = await PerformTailscaleInstallAsync();
                if (!installed)
                {
                    TxtClientStatus.Text = "Installation Failed";
                    ProgressBarAction.IsIndeterminate = false;
                    return;
                }
            }
            else
            {
                TxtClientStatus.Text = "Not Installed";
                ProgressBarAction.IsIndeterminate = false;
                return;
            }
        }

        TxtClientStatus.Text = "Installed";
        TxtServiceStatus.Text = _tailscale.GetTailscaleServiceState();
        UpdateBadge(BadgeTailscale, TxtBadgeTailscale, "● Tailscale: Installed", "#F59E0B");

        // Step 2: Ensure background service / GUI is running
        await _tailscale.StartTailscaleAppAsync();

        // Step 3: Check Authentication
        await VerifyAuthenticationAndDiscoverServerAsync();
        ProgressBarAction.IsIndeterminate = false;
    }

    private async Task<bool> PerformTailscaleInstallAsync()
    {
        string tempInstaller = Path.Combine(Path.GetTempPath(), "tailscale-setup-latest.exe");
        TxtClientStatus.Text = "Downloading Tailscale...";

        var progress = new Progress<int>(pct =>
        {
            TxtClientStatus.Text = $"Downloading Tailscale: {pct}%";
        });

        bool downloaded = await _tailscale.DownloadInstallerAsync(tempInstaller, progress);
        if (!downloaded)
        {
            MessageBox.Show(this, "Failed to download official Tailscale installer. Check your Internet connection.", "Download Failed", MessageBoxButton.OK, MessageBoxImage.Error);
            return false;
        }

        TxtClientStatus.Text = "Installing (Accept UAC Prompt)...";
        bool installed = await _tailscale.InstallTailscaleAsync(tempInstaller);

        try { if (File.Exists(tempInstaller)) File.Delete(tempInstaller); } catch { }

        if (!installed)
        {
            MessageBox.Show(this, "Tailscale installation did not complete successfully.", "Installation Incomplete", MessageBoxButton.OK, MessageBoxImage.Warning);
            return false;
        }

        return true;
    }

    private async Task VerifyAuthenticationAndDiscoverServerAsync()
    {
        var status = await _tailscale.GetStatusAsync();
        bool authenticated = status?.Self?.Online == true || status?.BackendState == "Running";

        TxtServiceStatus.Text = _tailscale.GetTailscaleServiceState();

        if (!authenticated)
        {
            Logger.Log($"Tailscale not authenticated. BackendState: {status?.BackendState ?? "Unknown"}");
            TxtClientStatus.Text = "Authentication Required";
            UpdateBadge(BadgeTailscale, TxtBadgeTailscale, "● Tailscale: Sign-in Needed", "#EF4444");
            BannerAuthRequired.Visibility = Visibility.Visible;

            // Automatically open invite URL if configured
            OpenInviteUrl();

            // Start polling for authentication completion
            StartAuthPolling();
            return;
        }

        // Authenticated!
        BannerAuthRequired.Visibility = Visibility.Collapsed;
        _authPollCts?.Cancel();

        string? localIp = await _tailscale.GetLocalTailscaleIpv4Async();
        TxtLocalIp.Text = localIp ?? status?.Self?.TailscaleIPs?[0] ?? "100.x.x.x";
        TxtClientStatus.Text = "Authenticated & Connected";
        UpdateBadge(BadgeTailscale, TxtBadgeTailscale, "● Tailscale: Connected", "#10B981");

        // Discover Shared Server Machine
        await DiscoverAndProbeServerAsync(status);
    }

    private void StartAuthPolling()
    {
        _authPollCts?.Cancel();
        _authPollCts = new CancellationTokenSource();
        var ct = _authPollCts.Token;

        Task.Run(async () =>
        {
            while (!ct.IsCancellationRequested)
            {
                await Task.Delay(2500, ct);
                var status = await _tailscale.GetStatusAsync(ct);
                if (status?.Self?.Online == true || status?.BackendState == "Running")
                {
                    await Dispatcher.InvokeAsync(async () =>
                    {
                        Logger.Log("Tailscale authentication detected!");
                        await VerifyAuthenticationAndDiscoverServerAsync();
                    });
                    break;
                }
            }
        }, ct);
    }

    private async Task DiscoverAndProbeServerAsync(TailscaleStatusResponse? status)
    {
        UpdateBadge(BadgeServer, TxtBadgeServer, "● Host PC: Discovering...", "#F59E0B");

        // Perform discovery
        var (discoveredIp, discoveredName, discoveryMethod) = await _tailscale.DiscoverSharedServerAsync(_config, status);
        _discoveredServerIp = discoveredIp;
        _discoveredServerName = discoveredName;

        if (string.IsNullOrWhiteSpace(_discoveredServerIp))
        {
            TxtServerAddress.Text = "Not Discovered (Check Invitation Acceptance)";
            TxtServerAddress.Foreground = new SolidColorBrush(Color.FromRgb(0xEF, 0x44, 0x44));
            UpdateBadge(BadgeServer, TxtBadgeServer, "● Host PC: Not Found", "#EF4444");
            TxtConnectionPath.Text = "-";
            TxtLatency.Text = "-";
            TxtUdpPort.Text = "Shared Host Unresolved";
            BtnConnectGame.IsEnabled = false;
            return;
        }

        TxtServerDevice.Text = _discoveredServerName ?? _config.ServerDeviceName;
        string fullAddress = $"{_discoveredServerIp}:{_config.ServerPort}";
        TxtServerAddress.Text = fullAddress;
        TxtServerAddress.Foreground = new SolidColorBrush(Color.FromRgb(0x38, 0xBD, 0xF8));

        // Test reachability probe via Tailscale ping
        var probe = await _networkProbe.TestConnectionAsync(_discoveredServerIp, _config.ServerPort);
        TxtConnectionPath.Text = probe.PathType;
        TxtLatency.Text = probe.DeviceReachable ? $"{probe.LatencyMs:F1} ms" : "Unreachable";
        string portProto = _config.ServerPort == 25565 ? "TCP" : (_config.ServerPort == 8211 ? "UDP" : "Port");
        TxtUdpPort.Text = probe.DeviceReachable ? $"{portProto} {_config.ServerPort}: Host Reachable (Verify in-game)" : "Host Unreachable";

        if (probe.DeviceReachable)
        {
            UpdateBadge(BadgeServer, TxtBadgeServer, "● Host PC: Reachable", "#10B981");
            BtnConnectGame.IsEnabled = true;
        }
        else
        {
            UpdateBadge(BadgeServer, TxtBadgeServer, "● Host PC: Unreachable", "#EF4444");
            BtnConnectGame.IsEnabled = true; // Still allow friend to launch Palworld
        }
    }

    private void UpdateBadge(Border border, TextBlock textBlock, string text, string hexColor)
    {
        textBlock.Text = text;
        try
        {
            var color = (Color)ColorConverter.ConvertFromString(hexColor);
            border.Background = new SolidColorBrush(color);
        }
        catch { }
    }

    private void OpenInviteUrl()
    {
        string url = "https://login.tailscale.com";
        if (!string.IsNullOrWhiteSpace(_config.TailscaleInviteUrl))
        {
            if (Uri.TryCreate(_config.TailscaleInviteUrl, UriKind.Absolute, out var uri) &&
                uri.Scheme == Uri.UriSchemeHttps &&
                uri.Host.EndsWith("tailscale.com", StringComparison.OrdinalIgnoreCase))
            {
                url = uri.AbsoluteUri;
            }
            else
            {
                Logger.Log("[WARN] TailscaleInviteUrl failed security validation; defaulting to https://login.tailscale.com");
            }
        }

        // Never log the actual invitation URL
        Logger.Log("Opening Tailscale shared machine invitation in browser: [REDACTED]");
        try
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = url,
                UseShellExecute = true
            });
        }
        catch (Exception ex)
        {
            Logger.LogError("Error opening browser", ex);
        }
    }

    // Button event handlers

    private void BtnOpenInvite_Click(object sender, RoutedEventArgs e)
    {
        OpenInviteUrl();
    }

    private void BtnConnectGame_Click(object sender, RoutedEventArgs e)
    {
        if (string.IsNullOrWhiteSpace(_discoveredServerIp))
        {
            MessageBox.Show(this, "Server address has not been discovered yet. Please run Test Connection or Troubleshoot.", "Server Address Unavailable", MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        string fullAddress = $"{_discoveredServerIp}:{_config.ServerPort}";
        Clipboard.SetText(fullAddress);
        Logger.Log($"Copied server address to clipboard: {fullAddress}");

        // Attempt to launch Palworld
        if (_detectedPalworldExe != null && File.Exists(_detectedPalworldExe))
        {
            PalworldDetector.LaunchGame(_detectedPalworldExe);
        }

        // Show instruction dialog
        var dialog = new ConnectInstructionsDialog(fullAddress, _config.PalworldServerPassword)
        {
            Owner = this
        };
        dialog.ShowDialog();
    }

    private void BtnCopyAddress_Click(object sender, RoutedEventArgs e)
    {
        if (!string.IsNullOrWhiteSpace(_discoveredServerIp))
        {
            string fullAddress = $"{_discoveredServerIp}:{_config.ServerPort}";
            Clipboard.SetText(fullAddress);
            MessageBox.Show(this, $"Copied server address to clipboard:\n{fullAddress}", "Address Copied", MessageBoxButton.OK, MessageBoxImage.Information);
        }
        else
        {
            MessageBox.Show(this, "Server address is not yet available.", "Unavailable", MessageBoxButton.OK, MessageBoxImage.Warning);
        }
    }

    private void BtnTogglePassword_Click(object sender, RoutedEventArgs e)
    {
        if (string.IsNullOrWhiteSpace(_config.PalworldServerPassword)) return;

        _isPasswordRevealed = !_isPasswordRevealed;
        if (_isPasswordRevealed)
        {
            TxtPasswordMasked.Text = _config.PalworldServerPassword;
            BtnTogglePassword.Content = "Hide";
        }
        else
        {
            TxtPasswordMasked.Text = "••••••••••••";
            BtnTogglePassword.Content = "Show";
        }
    }

    private void BtnCopyPassword_Click(object sender, RoutedEventArgs e)
    {
        if (!string.IsNullOrWhiteSpace(_config.PalworldServerPassword))
        {
            Clipboard.SetText(_config.PalworldServerPassword);
            MessageBox.Show(this, "Server password copied to clipboard!", "Password Copied", MessageBoxButton.OK, MessageBoxImage.Information);
        }
    }

    private void ChkRememberPassword_Changed(object sender, RoutedEventArgs e)
    {
        var settings = ConfigManager.Settings;
        settings.RememberPassword = ChkRememberPassword.IsChecked == true;
        ConfigManager.SaveUserSettings(settings);
    }

    private void BtnBrowsePalworld_Click(object sender, RoutedEventArgs e)
    {
        var ofd = new OpenFileDialog
        {
            Title = "Select Palworld Executable (Palworld.exe)",
            Filter = "Palworld Executable (Palworld*.exe)|Palworld*.exe|All Executables (*.exe)|*.exe"
        };

        if (ofd.ShowDialog(this) == true)
        {
            _detectedPalworldExe = ofd.FileName;
            TxtPalworldDetectedPath.Text = _detectedPalworldExe;
            TxtPalworldDetectedPath.Foreground = new SolidColorBrush(Color.FromRgb(0x34, 0xD3, 0x99));

            var settings = ConfigManager.Settings;
            settings.CustomPalworldExePath = _detectedPalworldExe;
            ConfigManager.SaveUserSettings(settings);
            Logger.Log($"User manually selected Palworld exe: {_detectedPalworldExe}");
        }
    }

    private async void BtnTestConnection_Click(object sender, RoutedEventArgs e)
    {
        ProgressBarAction.IsIndeterminate = true;
        await VerifyAuthenticationAndDiscoverServerAsync();
        ProgressBarAction.IsIndeterminate = false;
    }

    private void BtnTroubleshoot_Click(object sender, RoutedEventArgs e)
    {
        var win = new TroubleshootWindow(_tailscale, _config)
        {
            Owner = this
        };
        win.ShowDialog();
    }

    private async void BtnReinstallTailscale_Click(object sender, RoutedEventArgs e)
    {
        var res = MessageBox.Show(this, "Are you sure you want to download and reinstall official Tailscale?", "Confirm Reinstall", MessageBoxButton.YesNo, MessageBoxImage.Question);
        if (res == MessageBoxResult.Yes)
        {
            ProgressBarAction.IsIndeterminate = true;
            await PerformTailscaleInstallAsync();
            await VerifyAuthenticationAndDiscoverServerAsync();
            ProgressBarAction.IsIndeterminate = false;
        }
    }

    private void BtnOpenLog_Click(object sender, RoutedEventArgs e)
    {
        Logger.OpenLog();
    }

    private void BtnExit_Click(object sender, RoutedEventArgs e)
    {
        Close();
    }
}