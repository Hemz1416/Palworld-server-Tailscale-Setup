using System;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using HemzPalworldConnectionSetup.Models;
using HemzPalworldConnectionSetup.Services;

namespace HemzPalworldConnectionSetup.Views;

public class DiagnosticItemViewModel : DiagnosticCheckResult
{
    public Visibility RecommendationVisibility => string.IsNullOrWhiteSpace(Recommendation) ? Visibility.Collapsed : Visibility.Visible;
}

public partial class TroubleshootWindow : Window
{
    private readonly TailscaleService _tailscale;
    private readonly ConnectionConfig _config;
    public ObservableCollection<DiagnosticItemViewModel> Diagnostics { get; } = [];

    public TroubleshootWindow(TailscaleService tailscale, ConnectionConfig config)
    {
        InitializeComponent();
        _tailscale = tailscale;
        _config = config;
        ItemsDiagnosticList.ItemsSource = Diagnostics;
        Loaded += async (s, e) => await RunDiagnosticsAsync();
    }

    private async void BtnRerun_Click(object sender, RoutedEventArgs e)
    {
        await RunDiagnosticsAsync();
    }

    private void BtnOpenLog_Click(object sender, RoutedEventArgs e)
    {
        Logger.OpenLog();
    }

    private void BtnClose_Click(object sender, RoutedEventArgs e)
    {
        Close();
    }

    public async Task RunDiagnosticsAsync()
    {
        BtnRerun.IsEnabled = false;
        Diagnostics.Clear();

        Logger.Log("Starting 12-point troubleshooting diagnostic scan...");

        // 1. Tailscale installed?
        bool installed = _tailscale.IsTailscaleInstalled();
        Diagnostics.Add(new DiagnosticItemViewModel
        {
            StepNumber = 1,
            Title = "1. Tailscale Installed",
            Status = installed ? DiagnosticStatus.Pass : DiagnosticStatus.Fail,
            Details = installed ? $"Tailscale CLI found at: {_tailscale.GetTailscaleCliPath()}" : "Tailscale CLI is not installed on this machine.",
            Recommendation = installed ? "" : "Click 'REINSTALL TAILSCALE' on the main window to automatically download and install official Tailscale."
        });

        // 2. Tailscale Windows service active?
        string serviceState = _tailscale.GetTailscaleServiceState();
        bool serviceRunning = serviceState == "Running";
        Diagnostics.Add(new DiagnosticItemViewModel
        {
            StepNumber = 2,
            Title = "2. Tailscale Windows Service Active",
            Status = serviceRunning ? DiagnosticStatus.Pass : DiagnosticStatus.Fail,
            Details = serviceRunning ? "Tailscale Windows service active (Status: Running)." : $"Tailscale Windows service is not running (Status: {serviceState}).",
            Recommendation = serviceRunning ? "" : "Ensure the Windows Service 'Tailscale' is set to Automatic and started in services.msc."
        });

        // 3. User authenticated?
        var status = await _tailscale.GetStatusAsync();
        bool authenticated = status?.Self?.Online == true || status?.BackendState == "Running";
        Diagnostics.Add(new DiagnosticItemViewModel
        {
            StepNumber = 3,
            Title = "3. Tailscale Authentication",
            Status = authenticated ? DiagnosticStatus.Pass : DiagnosticStatus.Fail,
            Details = authenticated ? $"Authenticated to Tailscale. Backend State: {status?.BackendState}" : $"Not authenticated. Backend State: {status?.BackendState ?? "Unknown"}",
            Recommendation = authenticated ? "" : "Accept the shared machine invitation link in your browser and complete Tailscale sign-in."
        });

        // 4. Client Account Context
        Diagnostics.Add(new DiagnosticItemViewModel
        {
            StepNumber = 4,
            Title = "4. Client Tailscale Context",
            Status = authenticated ? DiagnosticStatus.Pass : DiagnosticStatus.Fail,
            Details = authenticated ? "Client account authenticated on Tailscale network." : "Not signed into Tailscale.",
            Recommendation = authenticated ? "" : "Sign in using the single-use machine share invitation provided by Hemz."
        });

        // 5. Shared server machine visible?
        var (serverIp, serverName, discoveryMethod) = await _tailscale.DiscoverSharedServerAsync(_config, status);
        bool serverVisible = !string.IsNullOrWhiteSpace(serverIp);
        Diagnostics.Add(new DiagnosticItemViewModel
        {
            StepNumber = 5,
            Title = "5. Shared Server Machine Visibility",
            Status = serverVisible ? DiagnosticStatus.Pass : DiagnosticStatus.Fail,
            Details = serverVisible ? $"Shared server machine '{serverName}' discovered with Tailscale IP: {serverIp} ({discoveryMethod})." : $"Server machine '{_config.ServerDeviceName}' is not visible in peer table.",
            Recommendation = serverVisible ? "" : "Ensure Hemz has started Tailscale on the server machine, and that the machine-share invitation was accepted."
        });

        // 6. Shared server machine reachable?
        TailscalePingResult? pingResult = null;
        if (!string.IsNullOrWhiteSpace(serverIp))
        {
            pingResult = await _tailscale.PingServerAsync(serverIp);
        }

        bool pingOk = pingResult?.Success == true;
        Diagnostics.Add(new DiagnosticItemViewModel
        {
            StepNumber = 6,
            Title = "6. Shared Server Host Reachability",
            Status = pingOk ? DiagnosticStatus.Pass : DiagnosticStatus.Fail,
            Details = pingOk ? $"Host ping reply received ({pingResult?.LatencyMs:F1}ms, Path: {pingResult?.PathType})." : "Shared server host did not respond to Tailscale ping.",
            Recommendation = pingOk ? "" : "Ensure the server laptop is turned on, awake, and connected to the Internet."
        });

        // 7. Server port configured as 8211?
        bool portOk = _config.ServerPort == 8211;
        Diagnostics.Add(new DiagnosticItemViewModel
        {
            StepNumber = 7,
            Title = "7. Dedicated Server Port Configuration",
            Status = portOk ? DiagnosticStatus.Pass : DiagnosticStatus.Warning,
            Details = $"Configured Port: {_config.ServerPort} (Standard Palworld Port: 8211)",
            Recommendation = portOk ? "" : "Palworld Dedicated Server default port is 8211. Ensure both client and server agree on port 8211."
        });

        // 8. Palworld Dedicated Server UDP Endpoint
        Diagnostics.Add(new DiagnosticItemViewModel
        {
            StepNumber = 8,
            Title = "8. Palworld Dedicated Server UDP Endpoint",
            Status = DiagnosticStatus.Info,
            Details = "UDP 8211 cannot be verified via diagnostic ping; Palworld Dedicated Server must be running and tested in-game.",
            Recommendation = pingOk ? "Host machine is reachable. Launch Palworld and connect via 'Join Multiplayer Game' to verify gameplay replication." : "Host machine must be reachable first."
        });

        // 9. Host Machine power state?
        Diagnostics.Add(new DiagnosticItemViewModel
        {
            StepNumber = 9,
            Title = "9. Host Machine Power & Network Response",
            Status = pingOk ? DiagnosticStatus.Pass : DiagnosticStatus.Warning,
            Details = pingOk ? "Host machine is active and responding to network packets." : "Host machine may be asleep or shutting down.",
            Recommendation = pingOk ? "" : "Confirm with Hemz that the server PC is awake and connected."
        });

        // 10. Peer Network Connectivity
        Diagnostics.Add(new DiagnosticItemViewModel
        {
            StepNumber = 10,
            Title = "10. Peer Network Packet Routing",
            Status = (serverVisible && pingOk) ? DiagnosticStatus.Pass : (serverVisible && !pingOk ? DiagnosticStatus.Warning : DiagnosticStatus.Info),
            Details = (serverVisible && pingOk) ? "Network packets are actively routing to host via Tailscale overlay." : "Shared machine visible but packets not returning.",
            Recommendation = (serverVisible && !pingOk) ? "Verify Windows firewall on the server permits Tailscale UDP/ICMP traffic." : ""
        });

        // 11. Connection Path (DIRECT, RELAYED / DERP, or PEER RELAY)
        bool isDirect = pingResult?.IsDirect == true;
        Diagnostics.Add(new DiagnosticItemViewModel
        {
            StepNumber = 11,
            Title = "11. Connection Path (Direct vs Relayed)",
            Status = pingOk ? (isDirect ? DiagnosticStatus.Pass : DiagnosticStatus.Warning) : DiagnosticStatus.Info,
            Details = pingOk ? $"Path: {pingResult?.PathType} ({pingResult?.LatencyMs:F1}ms). Direct connections generally provide lower latency/higher throughput while relays are a fallback." : "Path evaluation unavailable.",
            Recommendation = (!isDirect && pingOk) ? "Relayed (DERP) connections are fully functional and safe without port forwarding. Direct connections offer slightly lower latency." : ""
        });

        // 12. Palworld client installed?
        string? palworldExe = PalworldDetector.DetectPalworldExecutable(_config.PalworldExecutableHint);
        bool clientFound = palworldExe != null;
        Diagnostics.Add(new DiagnosticItemViewModel
        {
            StepNumber = 12,
            Title = "12. Palworld Game Client Installation",
            Status = clientFound ? DiagnosticStatus.Pass : DiagnosticStatus.Warning,
            Details = clientFound ? $"Palworld found at: {palworldExe}" : "Palworld game executable not detected in default locations.",
            Recommendation = clientFound ? "" : "Use the 'SELECT PALWORLD EXE' button on the main screen to locate your Palworld.exe manually."
        });

        BtnRerun.IsEnabled = true;
        Logger.Log("Completed 12-point troubleshooting diagnostic scan.");
    }
}
