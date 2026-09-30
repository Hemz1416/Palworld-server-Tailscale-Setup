using System;
using System.Text.RegularExpressions;

namespace HemzPalworldConnectionSetup.Models;

public class ConnectionConfig
{
    public string AppName { get; set; } = "Hemz Palworld Connection Setup";
    public string ServerName { get; set; } = "Hemz Palworld";
    public int ServerPort { get; set; } = 8211;
    public string ServerDeviceName { get; set; } = "hemz";
    public string ServerMagicDnsName { get; set; } = "";
    public string ServerTailscaleIp { get; set; } = "";
    public string TailscaleInviteUrl { get; set; } = "";
    public string PalworldServerPassword { get; set; } = "";
    public string PalworldExecutableHint { get; set; } = "";
    public int ConnectionTimeoutSeconds { get; set; } = 30;

    public void Validate()
    {
        if (ServerPort < 1 || ServerPort > 65535)
        {
            throw new InvalidOperationException($"Invalid ServerPort: {ServerPort}. Port must be between 1 and 65535.");
        }

        if (ConnectionTimeoutSeconds <= 0)
        {
            throw new InvalidOperationException($"Invalid ConnectionTimeoutSeconds: {ConnectionTimeoutSeconds}. Must be greater than 0.");
        }

        if (!string.IsNullOrWhiteSpace(TailscaleInviteUrl))
        {
            if (!Uri.TryCreate(TailscaleInviteUrl, UriKind.Absolute, out var uri) ||
                uri.Scheme != Uri.UriSchemeHttps ||
                !uri.Host.EndsWith("tailscale.com", StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException($"Invalid TailscaleInviteUrl: '{TailscaleInviteUrl}'. Must be an absolute HTTPS URL on tailscale.com.");
            }
        }

        if (!string.IsNullOrWhiteSpace(ServerMagicDnsName))
        {
            if (!Regex.IsMatch(ServerMagicDnsName, @"^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$") ||
                ServerMagicDnsName.Contains(' ') || ServerMagicDnsName.Contains('!'))
            {
                throw new InvalidOperationException($"Invalid ServerMagicDnsName: '{ServerMagicDnsName}'. Must be a valid DNS hostname.");
            }
        }
    }
}

