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
}
