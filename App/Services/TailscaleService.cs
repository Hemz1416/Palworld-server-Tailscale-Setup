using System;
using System.Diagnostics;
using System.IO;
using System.Net.Http;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using HemzPalworldConnectionSetup.Models;

namespace HemzPalworldConnectionSetup.Services;

public class TailscaleService
{
    private static readonly HttpClient HttpClient = new() { Timeout = TimeSpan.FromSeconds(60) };

    public const string OfficialInstallerUrl = "https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe";

    private string? _cachedCliPath;

    public string? GetTailscaleCliPath()
    {
        if (_cachedCliPath != null && File.Exists(_cachedCliPath))
        {
            return _cachedCliPath;
        }

        string[] candidatePaths =
        [
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "Tailscale", "tailscale.exe"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86), "Tailscale", "tailscale.exe"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Tailscale", "tailscale.exe")
        ];

        foreach (var path in candidatePaths)
        {
            if (File.Exists(path))
            {
                _cachedCliPath = path;
                return path;
            }
        }

        // Check PATH
        try
        {
            using var proc = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "where.exe",
                    Arguments = "tailscale.exe",
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                }
            };
            proc.Start();
            string output = proc.StandardOutput.ReadToEnd().Trim();
            proc.WaitForExit(2000);
            if (!string.IsNullOrWhiteSpace(output) && File.Exists(output.Split(Environment.NewLine)[0]))
            {
                _cachedCliPath = output.Split(Environment.NewLine)[0];
                return _cachedCliPath;
            }
        }
        catch
        {
            // Ignore where.exe errors
        }

        return null;
    }

    public bool IsTailscaleInstalled()
    {
        return GetTailscaleCliPath() != null;
    }

    public string GetTailscaleServiceState()
    {
        try
        {
            using var proc = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "sc.exe",
                    Arguments = "query Tailscale",
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                }
            };
            proc.Start();
            string output = proc.StandardOutput.ReadToEnd();
            proc.WaitForExit(3000);

            if (output.Contains("STATE") && output.Contains("RUNNING"))
            {
                return "Running";
            }
            if (output.Contains("STATE") && output.Contains("STOPPED"))
            {
                return "Stopped";
            }
            if (output.Contains("FAILED 1060"))
            {
                return "Not Installed";
            }
        }
        catch
        {
        }

        // Fallback process check
        try
        {
            if (Process.GetProcessesByName("tailscaled").Length > 0)
                return "Running";
        }
        catch { }

        return "Stopped";
    }

    public bool IsTailscaleServiceRunning()
    {
        return GetTailscaleServiceState() == "Running";
    }

    public async Task<bool> DownloadInstallerAsync(string destinationPath, IProgress<int>? progress = null, CancellationToken ct = default)
    {
        Logger.Log($"Downloading official Tailscale installer from: {OfficialInstallerUrl}");
        Logger.Log($"Destination: {destinationPath}");

        try
        {
            using var response = await HttpClient.GetAsync(OfficialInstallerUrl, HttpCompletionOption.ResponseHeadersRead, ct);
            response.EnsureSuccessStatusCode();

            var totalBytes = response.Content.Headers.ContentLength ?? -1L;
            await using var contentStream = await response.Content.ReadAsStreamAsync(ct);
            await using var fileStream = new FileStream(destinationPath, FileMode.Create, FileAccess.Write, FileShare.None, 8192, true);

            var buffer = new byte[16384];
            var totalRead = 0L;
            int bytesRead;

            while ((bytesRead = await contentStream.ReadAsync(buffer, ct)) > 0)
            {
                await fileStream.WriteAsync(buffer.AsMemory(0, bytesRead), ct);
                totalRead += bytesRead;

                if (totalBytes > 0 && progress != null)
                {
                    int pct = (int)((double)totalRead / totalBytes * 100);
                    progress.Report(pct);
                }
            }

            Logger.Log($"Download complete. Total bytes: {totalRead}");
            return true;
        }
        catch (Exception ex)
        {
            Logger.LogError("Failed to download Tailscale installer", ex);
            return false;
        }
    }

    public async Task<bool> InstallTailscaleAsync(string installerPath, CancellationToken ct = default)
    {
        Logger.Log($"Launching Tailscale installer silently with UAC elevation: {installerPath}");

        try
        {
            var psi = new ProcessStartInfo
            {
                FileName = installerPath,
                Arguments = "/quiet /norestart",
                UseShellExecute = true,
                Verb = "RunAs" // Requests administrative elevation
            };

            using var process = Process.Start(psi);
            if (process == null)
            {
                Logger.Log("[ERROR] Failed to start installer process.");
                return false;
            }

            await process.WaitForExitAsync(ct);
            Logger.Log($"Installer exited with code: {process.ExitCode}");

            // Invalidate cached CLI path and search again
            _cachedCliPath = null;

            // Wait a few seconds for Tailscale background service to initialize
            for (int i = 0; i < 15; i++)
            {
                await Task.Delay(1000, ct);
                if (IsTailscaleInstalled())
                {
                    Logger.Log($"Tailscale detected at: {GetTailscaleCliPath()}");
                    return true;
                }
            }

            return IsTailscaleInstalled();
        }
        catch (Exception ex)
        {
            Logger.LogError("Installation process encountered error", ex);
            return false;
        }
    }

    public async Task<TailscaleStatusResponse?> GetStatusAsync(CancellationToken ct = default)
    {
        string? cli = GetTailscaleCliPath();
        if (cli == null) return null;

        try
        {
            var psi = new ProcessStartInfo
            {
                FileName = cli,
                Arguments = "status --json",
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };

            using var proc = Process.Start(psi);
            if (proc == null) return null;

            string json = await proc.StandardOutput.ReadToEndAsync(ct);
            await proc.WaitForExitAsync(ct);

            if (string.IsNullOrWhiteSpace(json)) return null;

            var options = new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            };
            return JsonSerializer.Deserialize<TailscaleStatusResponse>(json, options);
        }
        catch (Exception ex)
        {
            Logger.LogError("Error getting Tailscale status", ex);
            return null;
        }
    }

    public async Task<string?> GetLocalTailscaleIpv4Async(CancellationToken ct = default)
    {
        string? cli = GetTailscaleCliPath();
        if (cli == null) return null;

        try
        {
            var psi = new ProcessStartInfo
            {
                FileName = cli,
                Arguments = "ip -4",
                RedirectStandardOutput = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };

            using var proc = Process.Start(psi);
            if (proc == null) return null;

            string output = (await proc.StandardOutput.ReadToEndAsync(ct)).Trim();
            await proc.WaitForExitAsync(ct);

            var firstLine = output.Split(Environment.NewLine)[0].Trim();
            return !string.IsNullOrWhiteSpace(firstLine) && firstLine.StartsWith("100.") ? firstLine : null;
        }
        catch
        {
            return null;
        }
    }

    public async Task<TailscalePingResult> PingServerAsync(string target, CancellationToken ct = default)
    {
        string? cli = GetTailscaleCliPath();
        if (cli == null)
        {
            return new TailscalePingResult
            {
                Success = false,
                PathType = "UNREACHABLE",
                Message = "Tailscale CLI not found."
            };
        }

        try
        {
            Logger.Log($"Pinging server target via Tailscale: {target}");
            var psi = new ProcessStartInfo
            {
                FileName = cli,
                Arguments = $"ping -c 2 {target}",
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };

            using var proc = Process.Start(psi);
            if (proc == null)
            {
                return new TailscalePingResult { Success = false, PathType = "UNREACHABLE" };
            }

            using var pingCts = CancellationTokenSource.CreateLinkedTokenSource(ct);
            pingCts.CancelAfter(TimeSpan.FromSeconds(10));

            string output = await proc.StandardOutput.ReadToEndAsync(pingCts.Token);
            await proc.WaitForExitAsync(pingCts.Token);

            Logger.Log($"Ping output: {output.Trim().Replace(Environment.NewLine, " | ")}");

            if (output.Contains("is local Tailscale IP", StringComparison.OrdinalIgnoreCase))
            {
                return new TailscalePingResult
                {
                    Success = true,
                    IsDirect = true,
                    PathType = "LOCAL (HOST)",
                    LatencyMs = 0.1,
                    Message = "Target is the local host machine."
                };
            }

            var lines = output.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.RemoveEmptyEntries);
            var pongLines = lines
                .Select(l => l.Trim())
                .Where(l => l.StartsWith("pong from", StringComparison.OrdinalIgnoreCase))
                .ToList();

            if (pongLines.Count == 0)
            {
                return new TailscalePingResult
                {
                    Success = false,
                    IsDirect = false,
                    PathType = "UNREACHABLE",
                    LatencyMs = 0,
                    Message = "Host did not reply to Tailscale ping."
                };
            }

            string lastPong = pongLines.Last();

            bool isPeerRelay = lastPong.Contains("via peer-relay", StringComparison.OrdinalIgnoreCase) ||
                               lastPong.Contains("via peer relay", StringComparison.OrdinalIgnoreCase) ||
                               lastPong.Contains("via peer", StringComparison.OrdinalIgnoreCase);

            bool isRelayed = lastPong.Contains("via DERP", StringComparison.OrdinalIgnoreCase);

            bool isDirect = !isPeerRelay && !isRelayed &&
                            (Regex.IsMatch(lastPong, @"via\s+([0-9\.]+:\d+|\[.+\]:\d+)") ||
                             lastPong.Contains("via [") ||
                             lastPong.Contains("direct") ||
                             lastPong.Contains("via"));

            double latency = 0;
            var latencyMatch = Regex.Match(lastPong, @"in\s+([0-9\.]+)ms", RegexOptions.IgnoreCase);
            if (latencyMatch.Success && double.TryParse(latencyMatch.Groups[1].Value, System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out double parsedLat))
            {
                latency = parsedLat;
            }

            string pathType = isPeerRelay ? "PEER RELAY" : (isRelayed ? "RELAYED / DERP" : "DIRECT");

            return new TailscalePingResult
            {
                Success = true,
                IsDirect = pathType == "DIRECT",
                PathType = pathType,
                LatencyMs = latency,
                Message = $"Path: {pathType}, Latency: {latency:F1}ms"
            };
        }
        catch (Exception ex)
        {
            Logger.LogError($"Tailscale ping to {target} failed", ex);
            return new TailscalePingResult
            {
                Success = false,
                PathType = "UNREACHABLE",
                Message = ex.Message
            };
        }
    }

    public async Task<(string? Ip, string? Name, string DiscoveryMethod)> DiscoverSharedServerAsync(
        ConnectionConfig config, 
        TailscaleStatusResponse? status = null, 
        CancellationToken ct = default)
    {
        if (config == null)
        {
            return (null, null, "Not Found");
        }

        // 1. Configured MagicDNS/device hostname if valid FQDN
        if (!string.IsNullOrWhiteSpace(config.ServerMagicDnsName))
        {
            string dns = config.ServerMagicDnsName.Trim();
            bool isValidDns = Regex.IsMatch(dns, @"^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$") &&
                              !dns.Contains(' ') && !dns.Contains('!');
            if (isValidDns)
            {
                Logger.Log($"[DISCOVERY] Step 1: Using configured MagicDNS name: {dns}");
                return (dns, dns, "Configured MagicDNS");
            }
            else
            {
                Logger.Log($"[DISCOVERY] Step 1: Configured MagicDNS name '{dns}' failed syntax validation; skipping.");
            }
        }

        // 2 & 3: Tailscale status peer information (requiring explicit configured target device name)
        if (!string.IsNullOrWhiteSpace(config.ServerDeviceName))
        {
            status ??= await GetStatusAsync(ct);
            if (status?.Peer != null && status.Peer.Count > 0)
            {
                string target = config.ServerDeviceName.Trim();

                // Exact match by HostName or DNSName
                var matchedPeer = status.Peer.Values.FirstOrDefault(p =>
                    (!string.IsNullOrWhiteSpace(p.HostName) && p.HostName.Equals(target, StringComparison.OrdinalIgnoreCase)) ||
                    (!string.IsNullOrWhiteSpace(p.DNSName) && p.DNSName.TrimEnd('.').Equals(target, StringComparison.OrdinalIgnoreCase)));

                // Substring match only if target name is at least 3 characters and distinct
                if (matchedPeer == null && target.Length >= 3)
                {
                    matchedPeer = status.Peer.Values.FirstOrDefault(p =>
                        (!string.IsNullOrWhiteSpace(p.HostName) && p.HostName.Contains(target, StringComparison.OrdinalIgnoreCase)) ||
                        (!string.IsNullOrWhiteSpace(p.DNSName) && p.DNSName.Contains(target, StringComparison.OrdinalIgnoreCase)));
                }

                // If matched, extract Tailscale IPv4
                if (matchedPeer != null)
                {
                    string? ip = matchedPeer.TailscaleIPs?.FirstOrDefault(a => a.Contains('.')) ?? matchedPeer.DNSName?.TrimEnd('.');
                    if (!string.IsNullOrWhiteSpace(ip))
                    {
                        Logger.Log($"[DISCOVERY] Discovered shared server machine '{matchedPeer.HostName}' with IP: {ip}");
                        return (ip, matchedPeer.HostName ?? target, "Discovered Shared Machine (Peer Table)");
                    }
                }
            }
        }

        // 4. Fallback to manually configured server Tailscale IP if valid IPv4
        if (!string.IsNullOrWhiteSpace(config.ServerTailscaleIp) &&
            System.Net.IPAddress.TryParse(config.ServerTailscaleIp, out var parsedIp) &&
            parsedIp.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork)
        {
            Logger.Log($"[DISCOVERY] Step 4: Using configured fallback Tailscale IP: {config.ServerTailscaleIp}");
            return (config.ServerTailscaleIp, config.ServerDeviceName, "Configured Fallback IP");
        }

        Logger.Log("[DISCOVERY] Server device could not be resolved from peer table or configuration.");
        return (null, null, "Not Found");
    }

    public async Task StartTailscaleAppAsync()
    {
        try
        {
            string? cli = GetTailscaleCliPath();
            if (cli != null)
            {
                string guiPath = Path.Combine(Path.GetDirectoryName(cli)!, "tailscale-ipn.exe");
                if (File.Exists(guiPath))
                {
                    Process.Start(new ProcessStartInfo(guiPath) { UseShellExecute = true });
                    Logger.Log("Started Tailscale GUI client (tailscale-ipn.exe).");
                }
            }
        }
        catch (Exception ex)
        {
            Logger.LogError("Error starting Tailscale GUI", ex);
        }
    }
}
