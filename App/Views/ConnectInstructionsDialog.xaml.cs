using System.Windows;

namespace HemzPalworldConnectionSetup.Views;

public partial class ConnectInstructionsDialog : Window
{
    private readonly string _serverAddress;
    private readonly string _serverPassword;

    public ConnectInstructionsDialog(string serverAddress, string serverPassword)
    {
        InitializeComponent();
        _serverAddress = serverAddress;
        _serverPassword = serverPassword;

        TxtServerAddress.Text = _serverAddress;
        if (!string.IsNullOrWhiteSpace(_serverPassword))
        {
            TxtServerPassword.Text = _serverPassword;
            BtnCopyPassword.Visibility = Visibility.Visible;
        }
        else
        {
            TxtServerPassword.Text = "(None configured)";
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
