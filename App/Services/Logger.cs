using System;
using System.Diagnostics;
using System.IO;

namespace HemzPalworldConnectionSetup.Services;

public static class Logger
{
    private static readonly object LockObj = new();
    private static string? _logFilePath;

    public static string LogFilePath
    {
        get
        {
            if (_logFilePath == null)
            {
                try
                {
                    string baseDir = AppDomain.CurrentDomain.BaseDirectory;
                    string logDir = Path.Combine(baseDir, "Logs");
                    Directory.CreateDirectory(logDir);
                    _logFilePath = Path.Combine(logDir, "connection.log");
                }
                catch
                {
                    string appData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
                    string fallbackDir = Path.Combine(appData, "HemzPalworldConnection", "Logs");
                    Directory.CreateDirectory(fallbackDir);
                    _logFilePath = Path.Combine(fallbackDir, "connection.log");
                }
            }
            return _logFilePath;
        }
    }

    public static void Initialize(string appVersion)
    {
        Log("================================================================================");
        Log($"APPLICATION STARTUP - Hemz Palworld Connection Setup v{appVersion}");
        Log($"OS Version: {Environment.OSVersion} ({(Environment.Is64BitOperatingSystem ? "64-bit" : "32-bit")})");
        Log($"Runtime: {Environment.Version}");
        Log($"Machine: {Environment.MachineName}");
        Log("================================================================================");
    }

    public static void Log(string message)
    {
        try
        {
            string sanitized = SanitizeMessage(message);
            string timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff");
            string line = $"[{timestamp}] {sanitized}";

            lock (LockObj)
            {
                File.AppendAllText(LogFilePath, line + Environment.NewLine);
            }

            Debug.WriteLine(line);
        }
        catch
        {
            // Ignore logging failures to prevent crashing
        }
    }

    public static void LogError(string context, Exception ex)
    {
        Log($"[ERROR] {context}: {ex.GetType().Name} - {ex.Message}");
        Log($"[TRACE] {ex.StackTrace}");
    }

    public static void OpenLog()
    {
        try
        {
            if (File.Exists(LogFilePath))
            {
                Process.Start(new ProcessStartInfo
                {
                    FileName = LogFilePath,
                    UseShellExecute = true
                });
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"Failed to open log: {ex.Message}");
        }
    }

    /// <summary>
    /// Strictly filters any sensitive patterns from appearing in log entries.
    /// </summary>
    private static string SanitizeMessage(string input)
    {
        if (string.IsNullOrEmpty(input)) return string.Empty;

        // Prevent logging passwords, tskey auth keys, tokens, or invitation URLs
        string sanitized = input;
        sanitized = System.Text.RegularExpressions.Regex.Replace(sanitized, @"(?i)tskey-auth-[a-zA-Z0-9_-]+", "[REDACTED_AUTHKEY]");
        sanitized = System.Text.RegularExpressions.Regex.Replace(sanitized, @"(?i)tskey-k[a-zA-Z0-9_-]+", "[REDACTED_KEY]");
        sanitized = System.Text.RegularExpressions.Regex.Replace(sanitized, @"(?i)(password\s*[:=]\s*)([^\s,""']+)", "$1[REDACTED]");
        sanitized = System.Text.RegularExpressions.Regex.Replace(sanitized, @"(?i)(palworldserverpassword\s*[:=]\s*"")([^""]+)("")", "$1[REDACTED]$3");
        sanitized = System.Text.RegularExpressions.Regex.Replace(sanitized, @"(?i)(tailscaleinviteurl\s*[:=]\s*"")([^""]+)("")", "$1[REDACTED]$3");
        sanitized = System.Text.RegularExpressions.Regex.Replace(sanitized, @"(?i)https?://[^\s""']*tailscale\.com[^\s""']*(?:share|invite|login)[^\s""']*", "[REDACTED_INVITATION_URL]");
        return sanitized;
    }
}
