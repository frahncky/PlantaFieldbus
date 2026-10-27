namespace PlantaFieldbus.Wpf;

/// <summary>
/// Contrato para futuras fontes de dados. Implementações reais devem ser somente
/// leitura e só podem ser habilitadas após validação de protocolo.
/// </summary>
public interface IPlantAdapter
{
    string DisplayName { get; }
    bool IsReadOnly { get; }
    AdapterAvailability Availability { get; }
    IAsyncEnumerable<PlantSnapshot> WatchAsync(CancellationToken cancellationToken);
}

public enum AdapterAvailability
{
    Available,
    AwaitingProtocolEvidence,
}

public sealed class UnavailableAdapter(string displayName) : IPlantAdapter
{
    public string DisplayName { get; } = displayName;
    public bool IsReadOnly => true;
    public AdapterAvailability Availability => AdapterAvailability.AwaitingProtocolEvidence;

    public async IAsyncEnumerable<PlantSnapshot> WatchAsync(
        [System.Runtime.CompilerServices.EnumeratorCancellation] CancellationToken cancellationToken)
    {
        await Task.CompletedTask;
        if (cancellationToken.IsCancellationRequested)
            yield break;
        throw new NotSupportedException($"{DisplayName} aguarda evidência de protocolo antes de ser habilitado.");
    }
}

public sealed record PlantTag(string Id, string Label, double Value, string Unit, DateTimeOffset ObservedAt);
public sealed record PlantSnapshot(IReadOnlyDictionary<string, PlantTag> Tags, DateTimeOffset ObservedAt);
