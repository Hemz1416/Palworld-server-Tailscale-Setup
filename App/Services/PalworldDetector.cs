using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text.RegularExpressions;
using Microsoft.Win32;

namespace HemzPalworldConnectionSetup.Services;

public static class PalworldDetector
{
    public static string? DetectPalworldExecutable(string? configuredHint = null)
    {
        // 1. Check user-configured custom path from settings
        var customPath = ConfigManager.Settings.CustomPalworldExePath;
        if (!string.IsNullOrWhiteSpace(customPath) && File.Exists(customPath))
        {
            Logger.Log($"Found Palworld from user settings: {customPath}");
            return customPath;
        }

        // 2. Check hint from connection.json
        if (!string.IsNullOrWhiteSpace(configuredHint) && File.Exists(configuredHint))
        {
            Logger.Log($"Found Palworld from connection hint: {configuredHint}");
            return configuredHint;
        }

        // 3. Known disk locations
        string[] commonPaths =
        [
            @"H:\Games\Pirated\Palworld\Palworld.exe",
            @"H:\Games\Pirated\Palworld\Pal\Binaries\Win64\Palworld-Win64-Shipping.exe",
            @"C:\Program Files (x86)\Steam\steamapps\common\Palworld\Palworld.exe",
            @"D:\SteamLibrary\steamapps\common\Palworld\Palworld.exe",
            @"E:\SteamLibrary\steamapps\common\Palworld\Palworld.exe",
            @"H:\SteamLibrary\steamapps\common\Palworld\Palworld.exe",
            @"C:\Games\Palworld\Palworld.exe",
            @"D:\Games\Palworld\Palworld.exe"
        ];

        foreach (var path in commonPaths)
        {
            if (File.Exists(path))
            {
                Logger.Log($"Found Palworld executable at common path: {path}");
                return path;
            }
        }

        // 4. Check Steam Registry & Library Folders
        try
        {
            using var key = Registry.CurrentUser.OpenSubKey(@"Software\Valve\Steam");
            if (key?.GetValue("SteamPath") is string steamPath)
            {
                steamPath = steamPath.Replace('/', '\\');
                string defaultPalworld = Path.Combine(steamPath, "steamapps", "common", "Palworld", "Palworld.exe");
                if (File.Exists(defaultPalworld))
                {
                    Logger.Log($"Found Palworld via Steam registry: {defaultPalworld}");
                    return defaultPalworld;
                }

                // Check libraryfolders.vdf
                string vdfPath = Path.Combine(steamPath, "steamapps", "libraryfolders.vdf");
                if (File.Exists(vdfPath))
                {
                    string vdfContent = File.ReadAllText(vdfPath);
                    var matches = Regex.Matches(vdfContent, @"""path""\s+""([^""]+)""");
                    foreach (Match m in matches)
                    {
                        string libraryFolder = m.Groups[1].Value.Replace(@"\\", @"\");
                        string candidate = Path.Combine(libraryFolder, "steamapps", "common", "Palworld", "Palworld.exe");
                        if (File.Exists(candidate))
                        {
                            Logger.Log($"Found Palworld in Steam library: {candidate}");
                            return candidate;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Logger.LogError("Error checking Steam registry for Palworld", ex);
        }

        // 5. Check Desktop and Start Menu shortcuts
        string[] shortcutDirs =
        [
            Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory),
            Environment.GetFolderPath(Environment.SpecialFolder.CommonDesktopDirectory),
            Environment.GetFolderPath(Environment.SpecialFolder.StartMenu),
            Environment.GetFolderPath(Environment.SpecialFolder.CommonStartMenu)
        ];

        foreach (var dir in shortcutDirs)
        {
            if (Directory.Exists(dir))
            {
                try
                {
                    var shortcuts = Directory.GetFiles(dir, "*Palworld*.lnk", SearchOption.AllDirectories);
                    if (shortcuts.Length > 0)
                    {
                        Logger.Log($"Found Palworld shortcut: {shortcuts[0]}");
                        return shortcuts[0]; // Can be launched via ShellExecute
                    }
                }
                catch { }
            }
        }

        Logger.Log("Palworld executable could not be detected automatically.");
        return null;
    }

    public static bool LaunchGame(string gamePath)
    {
        try
        {
            Logger.Log($"Launching Palworld: {gamePath}");
            var psi = new ProcessStartInfo
            {
                FileName = gamePath,
                UseShellExecute = true,
                WorkingDirectory = Path.GetDirectoryName(gamePath) ?? string.Empty
            };
            Process.Start(psi);
            return true;
        }
        catch (Exception ex)
        {
            Logger.LogError($"Failed to launch Palworld from {gamePath}", ex);
            return false;
        }
    }
}
