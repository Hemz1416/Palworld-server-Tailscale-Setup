using System;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using System.Windows;
using HemzPalworldConnectionSetup.Models;
using HemzPalworldConnectionSetup.Services;

namespace HemzPalworldConnectionSetup;

public partial class App : Application
{
    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern bool AttachConsole(int dwProcessId);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern bool AllocConsole();

    private const int ATTACH_PARENT_PROCESS = -1;

    protected override async void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        string[] cmdArgs = Environment.GetCommandLineArgs();
        bool isTestMode = cmdArgs.Any(a => a.Equals("--test", StringComparison.OrdinalIgnoreCase));
        bool isDiagnosticsMode = cmdArgs.Any(a => a.Equals("--diagnostics", StringComparison.OrdinalIgnoreCase));

        if (isTestMode || isDiagnosticsMode)
        {
            if (!AttachConsole(ATTACH_PARENT_PROCESS))
            {
                AllocConsole();
            }

            Console.WriteLine();
            Console.WriteLine("================================================================================");
            Console.WriteLine("        HEMZ PALWORLD CONNECTION SETUP - CLI DIAGNOSTIC MODE");
            Console.WriteLine("================================================================================");

            Logger.Initialize("1.0.0-CLI");
            var config = ConfigManager.Current;
            var tailscale = new TailscaleService();
            var probe = new NetworkProbeService(tailscale);

            Logger.Log($"[1/5] Configuration Test: AppName='{config.AppName}', Server='{config.ServerName}', Device='{config.ServerDeviceName}', Port={config.ServerPort}");
            Console.WriteLine($"[1/5] Configuration Test:");
            Console.WriteLine($"      App Name        : {config.AppName}");
            Console.WriteLine($"      Server Name     : {config.ServerName}");
            Console.WriteLine($"      Target Device   : {config.ServerDeviceName}");
            Console.WriteLine($"      Target Port     : {config.ServerPort} (UDP)");
            Console.WriteLine($"      MagicDNS Host   : {(string.IsNullOrEmpty(config.ServerMagicDnsName) ? "(None)" : config.ServerMagicDnsName)}");
            Console.WriteLine($"      Has Password    : {!string.IsNullOrEmpty(config.PalworldServerPassword)}");
            Console.WriteLine();

            bool tsInstalled = tailscale.IsTailscaleInstalled();
            string tsServiceState = tailscale.GetTailscaleServiceState();
            Logger.Log($"[2/5] Tailscale Installation Test: Installed={tsInstalled}, Path={tailscale.GetTailscaleCliPath() ?? "None"}, ServiceStatus={tsServiceState}");
            Console.WriteLine($"[2/5] Tailscale Installation & Windows Service Test:");
            Console.WriteLine($"      Installed       : {tsInstalled}");
            Console.WriteLine($"      CLI Path        : {tailscale.GetTailscaleCliPath() ?? "(Not found)"}");
            Console.WriteLine($"      Windows Service : {tsServiceState}");
            Console.WriteLine();

            var status = await tailscale.GetStatusAsync();
            bool authenticated = status?.Self?.Online == true || status?.BackendState == "Running";
            Logger.Log($"[3/5] Tailscale Auth Test: State={status?.BackendState ?? "Offline"}, Auth={authenticated}, IP={status?.Self?.TailscaleIPs?.FirstOrDefault() ?? "None"}");
            Console.WriteLine($"[3/5] Tailscale Authentication & Shared Machine Access Test:");
            Console.WriteLine($"      Backend State   : {status?.BackendState ?? "Offline/Unknown"}");
            Console.WriteLine($"      Authenticated   : {authenticated}");
            Console.WriteLine($"      Self TailscaleIP: {status?.Self?.TailscaleIPs?.FirstOrDefault() ?? "None"}");
            Console.WriteLine($"      Self DNSName    : {status?.Self?.DNSName ?? "None"}");
            Console.WriteLine();

            var (serverIp, serverName, discoveryMethod) = await tailscale.DiscoverSharedServerAsync(config, status);
            Logger.Log($"[4/5] Server Discovery Test: Target='{config.ServerDeviceName}', DiscoveredName='{serverName ?? "None"}', DiscoveredIP='{serverIp ?? "None"}', Method='{discoveryMethod}'");
            Console.WriteLine($"[4/5] Shared Server Machine Discovery & Probe Test:");
            Console.WriteLine($"      Target Identity : {config.ServerDeviceName}");
            Console.WriteLine($"      Discovered Name : {(serverName ?? "(Not in peer table)")}");
            Console.WriteLine($"      Discovered IP   : {(serverIp ?? "(Unresolved)")}");
            Console.WriteLine($"      Discovery Method: {discoveryMethod}");

            if (!string.IsNullOrWhiteSpace(serverIp))
            {
                var probeResult = await probe.TestConnectionAsync(serverIp, config.ServerPort);
                Logger.Log($"[PROBE] Reachable={probeResult.DeviceReachable}, Path={probeResult.PathType}, Latency={probeResult.LatencyMs:F1}ms");
                Console.WriteLine($"      Reachable        : {probeResult.DeviceReachable}");
                Console.WriteLine($"      Path Type        : {probeResult.PathType}");
                Console.WriteLine($"      Latency          : {probeResult.LatencyMs:F1} ms");
                Console.WriteLine($"      UDP 8211 Status  : {probeResult.UdpPortSummary}");
            }
            else
            {
                Console.WriteLine($"      Probe skipped because server IP could not be resolved.");
            }
            Console.WriteLine();

            string? palworldPath = PalworldDetector.DetectPalworldExecutable(config.PalworldExecutableHint);
            Logger.Log($"[5/5] Palworld Game Client Test: Detected='{palworldPath ?? "None"}'");
            Console.WriteLine($"[5/5] Palworld Game Client Detection Test:");
            Console.WriteLine($"      Detected Client  : {(palworldPath ?? "(Not detected automatically)")}");
            Console.WriteLine();

            Console.WriteLine("================================================================================");
            Console.WriteLine($"CLI Diagnostics completed. Log written to: {Logger.LogFilePath}");
            Console.WriteLine("================================================================================");

            Shutdown(0);
            return;
        }

        // Standard GUI Launch
        var mainWindow = new MainWindow();
        mainWindow.Show();
    }
}
