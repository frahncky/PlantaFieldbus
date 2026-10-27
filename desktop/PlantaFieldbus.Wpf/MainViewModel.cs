using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace PlantaFieldbus.Wpf;

/// <summary>Dados demonstrativos locais; não abre sockets e não comanda a planta.</summary>
public sealed class MainViewModel : INotifyPropertyChanged
{
    private string _topologyStatus = "Nenhuma captura importada.";
    private string _discoveryStatus = "Escuta passiva desativada.";

    public ObservableCollection<TagView> Tags { get; } =
    [
        new("Temperatura", "42,8", "°C"),
        new("Vazão", "12,4", "L/min"),
        new("Nível", "68", "%"),
    ];

    public ObservableCollection<string> Events { get; } =
    [
        "Simulação local iniciada.",
        "Adaptadores reais permanecem indisponíveis.",
        "Nenhum comando foi enviado à rede industrial.",
    ];

    public ObservableCollection<TopologyNodeView> ObservedNodes { get; } = [];

    public ObservableCollection<AdapterStatusView> Adapters { get; } =
    [
        new("OPC", "Aguardando confirmação de protocolo"),
        new("Modbus TCP", "Aguardando confirmação de protocolo"),
        new("HSE", "Aguardando confirmação de protocolo"),
    ];

    public string TopologyStatus
    {
        get => _topologyStatus;
        private set
        {
            if (_topologyStatus == value) return;
            _topologyStatus = value;
            OnPropertyChanged();
        }
    }

    public string DiscoveryStatus
    {
        get => _discoveryStatus;
        private set
        {
            if (_discoveryStatus == value) return;
            _discoveryStatus = value;
            OnPropertyChanged();
        }
    }

    public void SetDiscoveryActive() => DiscoveryStatus = "Escuta passiva em execução na porta UDP 4987.";

    public void SetDiscoveryInactive() => DiscoveryStatus = "Escuta passiva desativada.";

    public void ReportBeacon(DiscoveryBeacon beacon)
    {
        DiscoveryStatus = $"Anúncio recebido: {beacon.SourceAddress} · DF51 v{beacon.Firmware} · Monitor {beacon.Monitor}";
        Events.Insert(0, "Anúncio UDP de identidade recebido passivamente.");
    }

    /// <summary>Lê o JSON gerado pelo analisador offline; não acessa a rede.</summary>
    public void LoadNetworkSummary(string contents)
    {
        using var document = JsonDocument.Parse(contents);
        var root = document.RootElement;
        var capture = root.TryGetProperty("capture", out var captureValue)
            ? captureValue.GetString() ?? "captura desconhecida"
            : "captura desconhecida";
        var hash = root.TryGetProperty("sha256", out var hashValue)
            ? hashValue.GetString() ?? string.Empty
            : string.Empty;

        var addresses = new SortedSet<string>(StringComparer.Ordinal);
        if (root.TryGetProperty("ip_endpoints", out var endpointLines) && endpointLines.ValueKind == JsonValueKind.Array)
        {
            foreach (var line in endpointLines.EnumerateArray())
            {
                foreach (Match match in Regex.Matches(line.GetString() ?? string.Empty, @"\b(?:\d{1,3}\.){3}\d{1,3}\b"))
                    addresses.Add(match.Value);
            }
        }

        ObservedNodes.Clear();
        foreach (var address in addresses)
            ObservedNodes.Add(new TopologyNodeView(address, "Endpoint observado na captura"));

        var shortHash = hash.Length >= 12 ? hash[..12] : hash;
        TopologyStatus = $"{capture} · {ObservedNodes.Count} endpoint(s) · hash {shortHash}";
        Events.Insert(0, "Resumo de captura importado localmente.");
    }

    public event PropertyChangedEventHandler? PropertyChanged;

    private void OnPropertyChanged([CallerMemberName] string? propertyName = null) =>
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
}

public sealed record TagView(string Label, string Value, string Unit);

public sealed record TopologyNodeView(string Address, string Description);
public sealed record AdapterStatusView(string Name, string Status);
