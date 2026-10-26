import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'adapters/simulation_adapter.dart';
import 'adapters/passive_ethernet_discovery.dart';
import 'domain/ethernet_discovery_beacon.dart';
import 'domain/plant_models.dart';
import 'domain/topology_models.dart';
import 'services/event_store.dart';
import 'services/network_summary_importer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planta Fieldbus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff16a1a4),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xff0d1720),
      ),
      home: const PlantConsole(),
    );
  }
}

class PlantConsole extends StatefulWidget {
  const PlantConsole({super.key});

  @override
  State<PlantConsole> createState() => _PlantConsoleState();
}

class _PlantConsoleState extends State<PlantConsole> {
  late final SimulationAdapter _adapter;
  late final JsonEventStore _eventStore;
  final _capturePath = TextEditingController();
  final _events = <PlantEvent>[];
  final _persistedKeys = <String>{};
  StreamSubscription<PlantSnapshot>? _subscription;
  StreamSubscription<EthernetDiscoveryBeacon>? _passiveSubscription;
  PassiveEthernetDiscovery? _passiveDiscovery;
  PlantSnapshot? _snapshot;
  ObservedTopology? _observedTopology;
  EthernetDiscoveryBeacon? _latestBeacon;
  String? _topologyError;
  String? _passiveError;
  var _page = 0;
  var _showPump = true;
  var _showValve = true;
  var _isPassiveListening = false;

  @override
  void initState() {
    super.initState();
    _adapter = SimulationAdapter();
    _eventStore = JsonEventStore(
      File(
        '${Directory.systemTemp.path}${Platform.pathSeparator}planta-fieldbus${Platform.pathSeparator}events.json',
      ),
    );
    _loadHistory();
    _subscription = _adapter.watch().listen(_onSnapshot);
  }

  Future<void> _loadHistory() async {
    try {
      final stored = await _eventStore.read();
      if (!mounted) return;
      setState(() {
        _events.addAll(stored.take(100));
        _persistedKeys.addAll(stored.map(_eventKey));
      });
    } on FormatException {
      // A malformed local cache must never prevent the console from opening.
    }
  }

  void _onSnapshot(PlantSnapshot snapshot) {
    final newEvents = snapshot.events
        .where((event) => _persistedKeys.add(_eventKey(event)))
        .toList();
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _events.insertAll(0, newEvents);
      if (_events.length > 100) _events.removeRange(100, _events.length);
    });
    for (final event in newEvents) {
      unawaited(_eventStore.append(event));
    }
  }

  String _eventKey(PlantEvent event) =>
      '${event.time.toIso8601String()}|${event.severity.name}|${event.message}';

  Future<void> _importTopology() async {
    try {
      final contents = await File(_capturePath.text.trim()).readAsString();
      final imported = NetworkSummaryImporter().importJson(contents);
      if (!mounted) return;
      setState(() {
        _observedTopology = imported;
        _topologyError = null;
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() => _topologyError = 'Não foi possível importar: $error');
      }
    }
  }

  Future<void> _togglePassiveDiscovery() async {
    if (_isPassiveListening) {
      await _passiveSubscription?.cancel();
      await _passiveDiscovery?.stop();
      if (mounted) setState(() => _isPassiveListening = false);
      return;
    }

    try {
      final discovery = PassiveEthernetDiscovery();
      final stream = await discovery.start();
      _passiveDiscovery = discovery;
      _passiveSubscription = stream.listen(
        (beacon) {
          if (mounted) {
            setState(() {
              _latestBeacon = beacon;
              _passiveError = null;
            });
          }
        },
        onError: (Object error) {
          if (mounted) setState(() => _passiveError = '$error');
        },
      );
      if (mounted) setState(() => _isPassiveListening = true);
    } on Object catch (error) {
      if (mounted) setState(() => _passiveError = '$error');
    }
  }

  @override
  void dispose() {
    _capturePath.dispose();
    _subscription?.cancel();
    _passiveSubscription?.cancel();
    _passiveDiscovery?.stop();
    _adapter.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _dashboard(),
      _topology(),
      _history(),
      _designer(),
      _connection(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('PLANTA FIELDBUS'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Chip(
              label: Text('SIMULAÇÃO'),
              avatar: Icon(Icons.circle, color: Colors.amber, size: 12),
            ),
          ),
        ],
      ),
      body: pages[_page],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _page,
        onDestinationSelected: (value) => setState(() => _page = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Operação',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_tree_outlined),
            selectedIcon: Icon(Icons.account_tree),
            label: 'Topologia',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Icon(Icons.design_services_outlined),
            selectedIcon: Icon(Icons.design_services),
            label: 'Designer',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Conexão',
          ),
        ],
      ),
    );
  }

  Widget _dashboard() {
    final level = _snapshot?.tags['level']?.value ?? 0;
    final flow = _snapshot?.tags['flow']?.value ?? 0;
    final pressure = _snapshot?.tags['pressure']?.value ?? 0;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Visão operacional',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        const Text(
          'Perfil FOUNDATION Fieldbus em validação. Dados somente simulados.',
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            leading: Icon(Icons.hub_outlined, color: Colors.tealAccent),
            title: Text('Segmento FOUNDATION Fieldbus — não conectado'),
            subtitle: Text(
              'Aguardando etiqueta da variante e captura passiva Ethernet.',
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _metric(
              'LI-101 • Nível',
              '${level.toStringAsFixed(1)} %',
              Icons.water_drop,
              Colors.lightBlue,
            ),
            _metric(
              'FIT-101 • Vazão',
              '${flow.toStringAsFixed(1)} L/min',
              Icons.water,
              Colors.tealAccent,
            ),
            _metric(
              'PT-101 • Pressão',
              '${pressure.toStringAsFixed(2)} bar',
              Icons.speed,
              Colors.deepPurpleAccent,
            ),
            _metric(
              'TIT-101 • Temperatura',
              '26.4 °C',
              Icons.thermostat_outlined,
              Colors.orangeAccent,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sinótico — malha hidráulica (perfil demonstrativo)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 28,
                    runSpacing: 12,
                    children: [
                      _synopticNode(
                        Icons.water,
                        'TK-101',
                        '${level.toStringAsFixed(1)} %',
                        Colors.lightBlue,
                      ),
                      if (_showPump)
                        _synopticNode(
                          Icons.settings_input_component,
                          'P-101',
                          'simulada',
                          Colors.tealAccent,
                        ),
                      if (_showValve)
                        _synopticNode(
                          Icons.tune,
                          'FV-101',
                          'aberta',
                          Colors.orangeAccent,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Layout demonstrativo editável na aba Designer.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const Icon(Icons.history, color: Colors.tealAccent),
            title: Text('${_events.length} eventos locais'),
            subtitle: const Text(
              'Histórico gravado localmente; nenhum dado é enviado à rede.',
            ),
          ),
        ),
      ],
    );
  }

  Widget _metric(String label, String value, IconData icon, Color color) =>
      SizedBox(
        width: 205,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 18),
                Text(value, style: Theme.of(context).textTheme.headlineSmall),
                Text(label),
              ],
            ),
          ),
        ),
      );

  Widget _synopticNode(IconData icon, String tag, String value, Color color) =>
      SizedBox(
        width: 118,
        child: Column(
          children: [
            Icon(icon, size: 50, color: color),
            Text(tag, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value),
          ],
        ),
      );

  Widget _topology() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text('Topologia', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      const Text(
        'Importa somente o JSON produzido pela análise de PCAP. Não abre conexão nem descobre hosts.',
      ),
      const SizedBox(height: 20),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Importar resumo offline',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _capturePath,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Caminho para network-summary.json',
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _importTopology,
                icon: const Icon(Icons.upload_file),
                label: const Text('Importar sem rede'),
              ),
              if (_topologyError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _topologyError!,
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      _topologyCard(),
    ],
  );

  Widget _topologyCard() {
    final nodes = _observedTopology?.nodes;
    if (nodes == null) {
      return const Card(
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.computer),
              title: Text('Notebook de engenharia'),
              subtitle: Text(
                'Ethernet para controlador ou switch — não conectado',
              ),
            ),
            ListTile(
              leading: Icon(Icons.hub_outlined),
              title: Text('Controlador / bridge — a identificar'),
              subtitle: Text(
                'Modelo e IP serão obtidos pela etiqueta ou PCAPNG',
              ),
            ),
            ListTile(
              leading: Icon(Icons.device_hub),
              title: Text('Segmento FOUNDATION Fieldbus — perfil em validação'),
              subtitle: Text('Hipótese de trabalho; sem comandos ativos'),
            ),
          ],
        ),
      );
    }
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.verified_outlined,
              color: Colors.tealAccent,
            ),
            title: Text('Captura: ${_observedTopology!.captureName}'),
            subtitle: Text(
              '${nodes.length} endpoints observados; hash ${_observedTopology!.captureSha256}',
            ),
          ),
          ...nodes.map(
            (node) => ListTile(
              leading: const Icon(Icons.lan_outlined),
              title: Text(node.label),
              subtitle: const Text(
                'Observado na captura — papel ainda não classificado',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _history() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        'Histórico e alarmes',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 8),
      const Text('Eventos do simulador persistidos somente neste computador.'),
      const SizedBox(height: 20),
      Card(
        child: _events.isEmpty
            ? const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Aguardando eventos do simulador'),
              )
            : Column(children: _events.take(30).map(_eventTile).toList()),
      ),
    ],
  );

  Widget _eventTile(PlantEvent event) {
    final (icon, color) = switch (event.severity) {
      EventSeverity.info => (Icons.info_outline, Colors.lightBlue),
      EventSeverity.warning => (
        Icons.warning_amber_outlined,
        Colors.orangeAccent,
      ),
      EventSeverity.alarm => (Icons.error_outline, Colors.redAccent),
    };
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(event.message),
      subtitle: Text(
        '${event.time.toLocal()} • ${event.severity.name.toUpperCase()}',
      ),
    );
  }

  Widget _designer() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        'Designer do sinótico',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 8),
      const Text(
        'Editor local de elementos demonstrativos. Não altera PLC, tags ou configuração de campo.',
      ),
      const SizedBox(height: 20),
      Card(
        child: Column(
          children: [
            SwitchListTile(
              value: _showPump,
              onChanged: (value) => setState(() => _showPump = value),
              title: const Text('Exibir P-101'),
              subtitle: const Text('Bomba demonstrativa'),
            ),
            SwitchListTile(
              value: _showValve,
              onChanged: (value) => setState(() => _showValve = value),
              title: const Text('Exibir FV-101'),
              subtitle: const Text('Válvula demonstrativa'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Prévia', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 28,
                  runSpacing: 12,
                  children: [
                    _synopticNode(
                      Icons.water,
                      'TK-101',
                      '${(_snapshot?.tags['level']?.value ?? 0).toStringAsFixed(1)} %',
                      Colors.lightBlue,
                    ),
                    if (_showPump)
                      _synopticNode(
                        Icons.settings_input_component,
                        'P-101',
                        'simulada',
                        Colors.tealAccent,
                      ),
                    if (_showValve)
                      _synopticNode(
                        Icons.tune,
                        'FV-101',
                        'aberta',
                        Colors.orangeAccent,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _connection() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text('Conexão', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      const Text('Modo seguro: sem descoberta ativa de rede e sem escrita.'),
      const SizedBox(height: 24),
      const Card(
        child: ListTile(
          leading: Icon(Icons.play_circle_outline, color: Colors.amber),
          title: Text('Simulador local'),
          subtitle: Text('Ativo para desenvolvimento da interface.'),
        ),
      ),
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isPassiveListening
                    ? 'Escuta passiva em execução'
                    : 'Escuta passiva desativada',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              const Text(
                'Escuta somente anúncios UDP já presentes. Não envia datagramas, não abre TCP e não escreve no controlador.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _togglePassiveDiscovery,
                icon: Icon(
                  _isPassiveListening
                      ? Icons.stop_circle_outlined
                      : Icons.hearing,
                ),
                label: Text(
                  _isPassiveListening
                      ? 'Parar escuta'
                      : 'Iniciar escuta passiva',
                ),
              ),
              if (_latestBeacon != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.sensors, color: Colors.tealAccent),
                  title: Text('Firmware ${_latestBeacon!.firmware}'),
                  subtitle: Text(
                    'Identidade anunciada: Monitor ${_latestBeacon!.monitor}',
                  ),
                ),
              if (_passiveError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _passiveError!,
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      const Card(
        child: ListTile(
          leading: Icon(Icons.lock_outline),
          title: Text('Escrita em PLC: bloqueada por projeto.'),
          subtitle: Text(
            'Exige adaptador confirmado, laboratório e autorização explícita.',
          ),
        ),
      ),
    ],
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
