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
    public string UdpPortSummary { get; set; } = "NOT DIRECTLY VERIFIED";
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
        Logger.Log($"Beginning network probe for target '{serverTarget}' on UDP port {port}...");
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
            result.UdpPortSummary = "UNREACHABLE";
            Logger.Log($"[PROBE] Device {serverTarget} is unreachable.");
            return result;
        }

        // Palworld uses connectionless UDP for gameplay replication.
        // As directed, we do not claim tailscale ping proves UDP 8211, nor do we fabricate UDP reachability.
        result.UdpPortSummary = "Palworld UDP endpoint cannot be directly verified from this diagnostic mode.";
        result.StatusMessage = $"Shared server machine reachable via Tailscale ({result.PathType}, {result.LatencyMs:F1}ms).";

        Logger.Log($"[PROBE RESULT] Reachable={result.DeviceReachable}, Path={result.PathType}, Latency={result.LatencyMs:F1}ms, UDP={result.UdpPortSummary}");
        return result;
    }
}
