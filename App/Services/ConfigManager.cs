using System;
using System.IO;
using System.Reflection;
using System.Text.Json;
using HemzPalworldConnectionSetup.Models;

namespace HemzPalworldConnectionSetup.Services;

public class UserSettings
{
    public bool RememberPassword { get; set; } = false;
    public string CustomPalworldExePath { get; set; } = string.Empty;
}

public static class ConfigManager
{
    private static ConnectionConfig? _currentConfig;
    private static UserSettings? _userSettings;

    public static ConnectionConfig Current => _currentConfig ??= LoadConfig();
    public static UserSettings Settings => _userSettings ??= LoadUserSettings();

    public static ConnectionConfig LoadConfig()
    {
        string baseDir = AppDomain.CurrentDomain.BaseDirectory;
        string configPath1 = Path.Combine(baseDir, "Config", "connection.json");
        string configPath2 = Path.Combine(baseDir, "connection.json");

        string? foundPath = null;
        string? jsonContent = null;

        if (File.Exists(configPath1))
        {
            foundPath = configPath1;
            Logger.Log($"Loading configuration from file: {configPath1}");
            jsonContent = File.ReadAllText(configPath1);
        }
        else if (File.Exists(configPath2))
        {
            foundPath = configPath2;
            Logger.Log($"Loading configuration from file: {configPath2}");
            jsonContent = File.ReadAllText(configPath2);
        }

        var options = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true,
            ReadCommentHandling = JsonCommentHandling.Skip,
            AllowTrailingCommas = true
        };

        if (foundPath != null)
        {
            ConnectionConfig? config;
            try
            {
                config = JsonSerializer.Deserialize<ConnectionConfig>(jsonContent!, options);
            }
            catch (Exception ex)
            {
                Logger.LogError($"Error deserializing configuration file '{foundPath}'", ex);
                throw new InvalidOperationException($"Malformed configuration file '{foundPath}': {ex.Message}", ex);
            }

            if (config == null)
            {
                throw new InvalidOperationException($"Configuration file '{foundPath}' is empty or invalid.");
            }

            config.Validate();
            Logger.Log($"Loaded config from '{foundPath}': AppName='{config.AppName}', ServerName='{config.ServerName}', Port={config.ServerPort}, Device='{config.ServerDeviceName}'");
            return config;
        }

        // External configuration file not found, try embedded resource
        Logger.Log("External connection.json not found; attempting to load embedded resource...");
        try
        {
            var assembly = Assembly.GetExecutingAssembly();
            using var stream = assembly.GetManifestResourceStream("HemzPalworldConnectionSetup.Resources.connection.json");
            if (stream != null)
            {
                using var reader = new StreamReader(stream);
                jsonContent = reader.ReadToEnd();
                if (!string.IsNullOrWhiteSpace(jsonContent))
                {
                    var embeddedConfig = JsonSerializer.Deserialize<ConnectionConfig>(jsonContent, options);
                    if (embeddedConfig != null)
                    {
                        embeddedConfig.Validate();
                        Logger.Log("Successfully loaded and validated embedded default configuration.");
                        return embeddedConfig;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Logger.LogError("Failed to load embedded connection.json resource", ex);
        }

        Logger.Log("[WARN] Using hardcoded fallback configuration.");
        var fallback = new ConnectionConfig();
        fallback.Validate();
        return fallback;
    }

    private static string GetUserSettingsPath()
    {
        string appData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
        string folder = Path.Combine(appData, "HemzPalworldConnection");
        Directory.CreateDirectory(folder);
        return Path.Combine(folder, "user_settings.json");
    }

    public static UserSettings LoadUserSettings()
    {
        try
        {
            string path = GetUserSettingsPath();
            if (File.Exists(path))
            {
                string json = File.ReadAllText(path);
                var settings = JsonSerializer.Deserialize<UserSettings>(json);
                if (settings != null) return settings;
            }
        }
        catch (Exception ex)
        {
            Logger.LogError("Failed to read user_settings.json", ex);
        }
        return new UserSettings();
    }

    public static void SaveUserSettings(UserSettings settings)
    {
        try
        {
            _userSettings = settings;
            string path = GetUserSettingsPath();
            string json = JsonSerializer.Serialize(settings, new JsonSerializerOptions { WriteIndented = true });
            File.WriteAllText(path, json);
            Logger.Log("Saved user settings successfully.");
        }
        catch (Exception ex)
        {
            Logger.LogError("Failed to save user_settings.json", ex);
        }
    }
}
