using System.IO;
using System.Text.Json;
using System.Windows;
using Microsoft.Win32;

namespace PlantaFieldbus.Wpf;

public partial class MainWindow : Window
{
    private readonly MainViewModel _viewModel = new();

    public MainWindow()
    {
        InitializeComponent();
        DataContext = _viewModel;
    }

    private void ImportNetworkSummary_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFileDialog
        {
            Title = "Importar resumo de captura passiva",
            Filter = "Resumo de rede (network-summary*.json)|network-summary*.json|Arquivos JSON (*.json)|*.json",
            CheckFileExists = true,
            Multiselect = false,
        };

        if (dialog.ShowDialog(this) != true) return;

        try
        {
            _viewModel.LoadNetworkSummary(File.ReadAllText(dialog.FileName));
        }
        catch (Exception exception) when (exception is IOException or UnauthorizedAccessException or JsonException)
        {
            MessageBox.Show(this, $"Não foi possível importar o resumo:\n{exception.Message}", "Importação offline", MessageBoxButton.OK, MessageBoxImage.Warning);
        }
    }
}
