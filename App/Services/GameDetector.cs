using System;
using System.IO;
using System.Diagnostics;
using System.Text.RegularExpressions;
using Microsoft.Win32;

namespace HemzPalworldConnectionSetup.Services;

public static class GameDetector
{
    public static string? DetectMinecraft(string? configuredHint = null)
    {
        // 1. User settings custom path
        var custom = ConfigManager.Settings.CustomMinecraftExePath;
        if (!string.IsNullOrWhiteSpace(custom) && (File.Exists(custom) || Directory.Exists(custom)))
        {
            return custom;
        }

        // 2. Known desktop & start menu shortcuts
        string[] shortcutDirs =
        [
            Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory),
            Environment.GetFolderPath(Environment.SpecialFolder.CommonDesktopDirectory),
            Environment.GetFolderPath(Environment.SpecialFolder.StartMenu),
            Environment.GetFolderPath(Environment.SpecialFolder.CommonStartMenu)
        ];

        string[] searchPatterns =
        [
            "*Minecraft*.lnk",
            "*Prism*.lnk",
            "*Modrinth*.lnk",
            "*CurseForge*.lnk",
            "*TLauncher*.lnk",
            "*Lunar*.lnk",
            "*Badlion*.lnk"
        ];

        foreach (var dir in shortcutDirs)
        {
            if (Directory.Exists(dir))
            {
                foreach (var pat in searchPatterns)
                {
                    try
                    {
                        var files = Directory.GetFiles(dir, pat, SearchOption.AllDirectories);
                        if (files.Length > 0)
                        {
                            Logger.Log($"Found Minecraft launcher shortcut: {files[0]}");
                            return files[0];
                        }
                    }
                    catch { }
                }
            }
        }

        // 3. Known executable paths
        string[] commonPaths =
        [
            @"C:\Program Files (x86)\Minecraft Launcher\MinecraftLauncher.exe",
            @"C:\XboxGames\Minecraft Launcher\Content\Minecraft.exe",
            @"C:\Program Files\PrismLauncher\prismlauncher.exe",
            @"C:\Program Files\Modrinth App\Modrinth App.exe",
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), ".minecraft")
        ];

        foreach (var path in commonPaths)
        {
            if (File.Exists(path) || Directory.Exists(path))
            {
                Logger.Log($"Found Minecraft at: {path}");
                return path;
            }
        }

        return null;
    }

    public static string? DetectPalworld(string? configuredHint = null)
    {
        return PalworldDetector.DetectPalworldExecutable(configuredHint);
    }

    public static bool LaunchGame(string gamePath)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(gamePath)) return false;

            if (File.Exists(gamePath))
            {
                var psi = new ProcessStartInfo
                {
                    FileName = gamePath,
                    UseShellExecute = true,
                    WorkingDirectory = Path.GetDirectoryName(gamePath) ?? string.Empty
                };
                Process.Start(psi);
                return true;
            }

            if (Directory.Exists(gamePath))
            {
                Process.Start(new ProcessStartInfo { FileName = gamePath, UseShellExecute = true });
                return true;
            }

            return false;
        }
        catch (Exception ex)
        {
            Logger.LogError($"Failed to launch game: {gamePath}", ex);
            return false;
        }
    }
}
