using System.Windows;

namespace HemzPalworldConnectionSetup.Views;

public partial class ConnectInstructionsDialog : Window
{
    private readonly string _serverAddress;
    private readonly string _serverPassword;

    public ConnectInstructionsDialog(string serverAddress, string? serverPassword, bool isPalworld = false)
    {
        InitializeComponent();
        _serverAddress = serverAddress;
        _serverPassword = serverPassword ?? string.Empty;

        if (isPalworld)
        {
            Title = "How to Connect in Palworld";
            TxtDialogTitle.Text = "CONNECTING TO HEMZ PALWORLD";
            PanelPalworldSteps.Visibility = Visibility.Visible;
            PanelMinecraftSteps.Visibility = Visibility.Collapsed;
            TxtPalworldServerAddress.Text = _serverAddress;

            if (!string.IsNullOrWhiteSpace(_serverPassword))
            {
                TxtPalworldServerPassword.Text = _serverPassword;
                BtnCopyPassword.Visibility = Visibility.Visible;
            }
            else
            {
                TxtPalworldServerPassword.Text = "(None configured)";
                BtnCopyPassword.Visibility = Visibility.Collapsed;
            }
        }
        else
        {
            Title = "How to Connect in Minecraft: Java Edition";
            TxtDialogTitle.Text = "CONNECTING TO HEMZ MINECRAFT SERVER";
            PanelPalworldSteps.Visibility = Visibility.Collapsed;
            PanelMinecraftSteps.Visibility = Visibility.Visible;
            TxtMinecraftServerAddress.Text = _serverAddress;
            BtnCopyPassword.Visibility = Visibility.Collapsed;
        }
    }

    private void BtnCopyAddress_Click(object sender, RoutedEventArgs e)
    {
        Clipboard.SetText(_serverAddress);
        MessageBox.Show(this, "Server address copied to clipboard!", "Copied", MessageBoxButton.OK, MessageBoxImage.Information);
    }

    private void BtnCopyPassword_Click(object sender, RoutedEventArgs e)
    {
        if (!string.IsNullOrWhiteSpace(_serverPassword))
        {
            Clipboard.SetText(_serverPassword);
            MessageBox.Show(this, "Server password copied to clipboard!", "Copied", MessageBoxButton.OK, MessageBoxImage.Information);
        }
    }

    private void BtnClose_Click(object sender, RoutedEventArgs e)
    {
        Close();
    }
}
