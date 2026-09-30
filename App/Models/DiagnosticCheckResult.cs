namespace HemzPalworldConnectionSetup.Models;

public enum DiagnosticStatus
{
    Pass,
    Warning,
    Fail,
    Info
}

public class DiagnosticCheckResult
{
    public int StepNumber { get; set; }
    public string Title { get; set; } = string.Empty;
    public DiagnosticStatus Status { get; set; } = DiagnosticStatus.Info;
    public string Details { get; set; } = string.Empty;
    public string Recommendation { get; set; } = string.Empty;

    public string StatusIcon => Status switch
    {
        DiagnosticStatus.Pass => "✔",
        DiagnosticStatus.Warning => "⚠",
        DiagnosticStatus.Fail => "✖",
        _ => "ℹ"
    };

    public string StatusColor => Status switch
    {
        DiagnosticStatus.Pass => "#10B981",     // Emerald Green
        DiagnosticStatus.Warning => "#F59E0B",  // Amber Orange
        DiagnosticStatus.Fail => "#EF4444",     // Crimson Red
        _ => "#9CA3AF"                          // Neutral Gray
    };
}
