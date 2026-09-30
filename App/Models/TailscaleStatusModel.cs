using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace HemzPalworldConnectionSetup.Models;

public class TailscaleStatusResponse
{
    [JsonPropertyName("Version")]
    public string? Version { get; set; }

    [JsonPropertyName("BackendState")]
    public string? BackendState { get; set; }

    [JsonPropertyName("AuthURL")]
    public string? AuthURL { get; set; }

    [JsonPropertyName("Self")]
    public TailscaleNodeInfo? Self { get; set; }

    [JsonPropertyName("Peer")]
    public Dictionary<string, TailscalePeerInfo>? Peer { get; set; }
}

public class TailscaleNodeInfo
{
    [JsonPropertyName("ID")]
    public string? ID { get; set; }

    [JsonPropertyName("HostName")]
    public string? HostName { get; set; }

    [JsonPropertyName("DNSName")]
    public string? DNSName { get; set; }

    [JsonPropertyName("TailscaleIPs")]
    public List<string>? TailscaleIPs { get; set; }

    [JsonPropertyName("Online")]
    public bool Online { get; set; }
}

public class TailscalePeerInfo
{
    [JsonPropertyName("ID")]
    public string? ID { get; set; }

    [JsonPropertyName("HostName")]
    public string? HostName { get; set; }

    [JsonPropertyName("DNSName")]
    public string? DNSName { get; set; }

    [JsonPropertyName("TailscaleIPs")]
    public List<string>? TailscaleIPs { get; set; }

    [JsonPropertyName("Online")]
    public bool Online { get; set; }

    [JsonPropertyName("CurAddr")]
    public string? CurAddr { get; set; }

    [JsonPropertyName("Relay")]
    public string? Relay { get; set; }

    [JsonPropertyName("ShareeNode")]
    public bool? ShareeNode { get; set; }
}

public class TailscalePingResult
{
    public bool Success { get; set; }
    public bool IsDirect { get; set; }
    public string PathType { get; set; } = "UNKNOWN"; // DIRECT, RELAYED / DERP, PEER RELAY, or UNREACHABLE
    public double LatencyMs { get; set; }
    public string Message { get; set; } = string.Empty;
}
