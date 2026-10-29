using System.IO;
using System.Net.Sockets;
using System.Text.Json;
using System.Windows;
using Microsoft.Win32;

namespace PlantaFieldbus.Wpf;

public partial class MainWindow : Window
{
    private readonly MainViewModel _viewModel = new();
    private PassiveDiscovery? _discovery;
    private CancellationTokenSource? _discoveryCancellation;

    public MainWindow()
    {
        InitializeComponent();
        DataContext = _viewModel;
    }

    private async void ToggleDiscovery_Click(object sender, RoutedEventArgs e)
    {
        if (_discovery is not null)
        {
            await StopDiscoveryAsync();
            return;
        }

        try
        {
            _discovery = new PassiveDiscovery();
            _discoveryCancellation = new CancellationTokenSource();
            _viewModel.SetDiscoveryActive();
            DiscoveryButton.Content = "Parar escuta passiva";
            _ = _discovery.ListenAsync(
                beacon => Dispatcher.Invoke(() => _viewModel.ReportBeacon(beacon)),
                _discoveryCancellation.Token);
        }
        catch (Exception exception) when (exception is SocketException or UnauthorizedAccessException)
        {
            await StopDiscoveryAsync();
            MessageBox.Show(this, $"Não foi possível iniciar a escuta passiva:\n{exception.Message}", "Escuta passiva", MessageBoxButton.OK, MessageBoxImage.Warning);
        }
    }

    private async Task StopDiscoveryAsync()
    {
        _discoveryCancellation?.Cancel();
        _discoveryCancellation?.Dispose();
        _discoveryCancellation = null;
        if (_discovery is not null) await _discovery.DisposeAsync();
        _discovery = null;
        _viewModel.SetDiscoveryInactive();
        DiscoveryButton.Content = "Iniciar escuta passiva";
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

    private void ExportTechnicalReport_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new SaveFileDialog
        {
            Title = "Exportar relatório técnico local",
            FileName = $"planta-evidencias-{DateTime.Now:yyyyMMdd-HHmm}.txt",
            Filter = "Relatório de texto (*.txt)|*.txt",
            OverwritePrompt = true,
        };

        if (dialog.ShowDialog(this) != true) return;

        try
        {
            File.WriteAllText(dialog.FileName, _viewModel.BuildTechnicalReport());
            MessageBox.Show(this, "Relatório salvo localmente. Nenhuma comunicação com a planta foi realizada.", "Relatório técnico", MessageBoxButton.OK, MessageBoxImage.Information);
        }
        catch (Exception exception) when (exception is IOException or UnauthorizedAccessException)
        {
            MessageBox.Show(this, $"Não foi possível salvar o relatório:\n{exception.Message}", "Relatório técnico", MessageBoxButton.OK, MessageBoxImage.Warning);
        }
    }

    protected override async void OnClosed(EventArgs e)
    {
        await StopDiscoveryAsync();
        base.OnClosed(e);
    }
}
