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
        "DF51 confirmado por anúncio passivo e ARP.",
        "Conectividade IP validada uma vez; nenhum comando foi enviado.",
        "Adaptadores reais permanecem indisponíveis.",
    ];

    public ObservableCollection<TopologyNodeView> ObservedNodes { get; } = [];

    public ObservableCollection<AdapterStatusView> Adapters { get; } =
    [
        new("OPC", "Aguardando confirmação de protocolo"),
        new("Modbus TCP", "Aguardando confirmação de protocolo"),
        new("HSE", "Aguardando confirmação de protocolo"),
    ];

    public ObservableCollection<PanelSignalView> PanelSignals { get; } =
    [
        new("Painel ligado", "Observado", "Indicador verde aceso na fotografia do painel.", "#39D9BA"),
        new("Emergência", "Não confirmado", "Lente vermelha visível; estado elétrico ainda não foi lido.", "#F2B84B"),
        new("Temperatura alta", "Não confirmado", "Aguardando identificação do canal de entrada.", "#F2B84B"),
        new("Nível baixo", "Não confirmado", "Aguardando identificação do canal de entrada.", "#F2B84B"),
        new("Sirene", "Não confirmado", "Som e comando não foram acionados.", "#F2B84B"),
    ];

    public ObservableCollection<InventoryItemView> Inventory { get; } =
    [
        new("Controlador", "DF51 — controlador DFI302 confirmado", "1 Ethernet de 10 Mbps e 4 canais FOUNDATION Fieldbus H1."),
        new("Identidade Ethernet", "MAC 00:30:5C:01:05:52", "UDP 4987 em broadcast, firmware 3.7.5 e Monitor 3302."),
        new("Rack de E/S", "Módulos presentes — modelo pendente", "Fotografar etiquetas frontais e bornes na próxima visita."),
        new("Painel", "2 bombas, emergência, sirene e alarmes", "Mapeamento entre botoeira e E/S ainda pendente."),
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
public sealed record PanelSignalView(string Label, string State, string Detail, string Accent);
public sealed record InventoryItemView(string Category, string Value, string Detail);
