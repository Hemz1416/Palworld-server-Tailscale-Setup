using System;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Threading.Tasks;
using HemzPalworldConnectionSetup.Models;

namespace HemzPalworldConnectionSetup.Services;

public class NetworkProbeResult
{
    public bool DeviceReachable { get; set; }
    public bool IsDirectPath { get; set; }
    public string PathType { get; set; } = "UNKNOWN"; // DIRECT, RELAYED (DERP), or UNREACHABLE
    public double LatencyMs { get; set; }
    public bool? PortListening { get; set; }
    public string PortSummary { get; set; } = "NOT DIRECTLY VERIFIED";
    public string UdpPortSummary => PortSummary;
    public string StatusMessage { get; set; } = string.Empty;
}

public class NetworkProbeService
{
    private readonly TailscaleService _tailscale;

    public NetworkProbeService(TailscaleService tailscale)
    {
        _tailscale = tailscale;
    }

    public async Task<NetworkProbeResult> TestConnectionAsync(string serverTarget, int port, CancellationToken ct = default)
    {
        bool isTcp = (port == 25565);
        string proto = isTcp ? "TCP" : (port == 8211 ? "UDP" : "Port");
        Logger.Log($"Beginning network probe for target '{serverTarget}' on {proto} port {port}...");
        var result = new NetworkProbeResult();

        // Step 1: Tailscale ICMP/DERP ping
        var pingResult = await _tailscale.PingServerAsync(serverTarget, ct);
        result.DeviceReachable = pingResult.Success;
        result.IsDirectPath = pingResult.IsDirect;
        result.PathType = pingResult.PathType;
        result.LatencyMs = pingResult.LatencyMs;

        if (!pingResult.Success)
        {
            result.StatusMessage = "Server host is currently unreachable on Tailscale.";
            result.PortSummary = "Host Unreachable";
            Logger.Log($"[PROBE] Device {serverTarget} is unreachable.");
            return result;
        }

        // Step 2: Protocol-specific verification
        if (isTcp)
        {
            try
            {
                using var client = new TcpClient();
                var connectTask = client.ConnectAsync(serverTarget, port);
                var completed = await Task.WhenAny(connectTask, Task.Delay(1500, ct));
                if (completed == connectTask && client.Connected)
                {
                    result.PortListening = true;
                    result.PortSummary = $"TCP {port}: Online & Listening";
                }
                else
                {
                    result.PortListening = false;
                    result.PortSummary = $"TCP {port}: No listener (Start Minecraft Server)";
                }
            }
            catch
            {
                result.PortListening = false;
                result.PortSummary = $"TCP {port}: Closed (Host reachable)";
            }
        }
        else
        {
            // Palworld uses UDP; endpoint cannot be passively probed without game replication packets
            result.PortListening = null;
            result.PortSummary = $"UDP {port}: Host Reachable (Verify in-game)";
        }

        result.StatusMessage = $"Shared server machine reachable via Tailscale ({result.PathType}, {result.LatencyMs:F1}ms).";
        Logger.Log($"[PROBE RESULT] Reachable={result.DeviceReachable}, Path={result.PathType}, Latency={result.LatencyMs:F1}ms, PortDiag={result.PortSummary}");
        return result;
    }
}
