using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.RegularExpressions;

namespace PlantaFieldbus.Wpf;

/// <summary>
/// Recebe somente anúncios UDP já presentes na rede. Esta classe nunca envia
/// datagramas, não varre hosts e não implementa leitura ou escrita de PLC.
/// </summary>
public sealed class PassiveDiscovery : IAsyncDisposable
{
    private readonly UdpClient _socket;

    public PassiveDiscovery(int port = 4987)
    {
        _socket = new UdpClient();
        _socket.Client.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.ReuseAddress, true);
        _socket.Client.Bind(new IPEndPoint(IPAddress.Any, port));
    }

    public async Task ListenAsync(Action<DiscoveryBeacon> onBeacon, CancellationToken cancellationToken)
    {
        while (!cancellationToken.IsCancellationRequested)
        {
            var datagram = await _socket.ReceiveAsync(cancellationToken);
            var beacon = DiscoveryBeacon.TryParse(datagram.Buffer, datagram.RemoteEndPoint);
            if (beacon is not null) onBeacon(beacon);
        }
    }

    public ValueTask DisposeAsync()
    {
        _socket.Dispose();
        return ValueTask.CompletedTask;
    }
}

public sealed record DiscoveryBeacon(string SourceAddress, string Firmware, string Monitor)
{
    public static DiscoveryBeacon? TryParse(byte[] payload, IPEndPoint sender)
    {
        var text = Encoding.Latin1.GetString(payload);
        var firmware = Regex.Match(text, @"DF51V([0-9]+(?:\.[0-9]+)*)");
        var monitor = Regex.Match(text, @"Monitor\s+([0-9]+)");
        return firmware.Success && monitor.Success
            ? new DiscoveryBeacon(sender.Address.ToString(), firmware.Groups[1].Value, monitor.Groups[1].Value)
            : null;
    }
}
