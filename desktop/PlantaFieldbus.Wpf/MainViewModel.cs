using System.Collections.ObjectModel;

namespace PlantaFieldbus.Wpf;

/// <summary>Dados demonstrativos locais; não abre sockets e não comanda a planta.</summary>
public sealed class MainViewModel
{
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
}

public sealed record TagView(string Label, string Value, string Unit);
