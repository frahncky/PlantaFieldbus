import 'dart:async';

import 'package:flutter/material.dart';

import 'adapters/simulation_adapter.dart';
import 'domain/plant_models.dart';

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
  StreamSubscription<PlantSnapshot>? _subscription;
  PlantSnapshot? _snapshot;
  var _page = 0;

  @override
  void initState() {
    super.initState();
    _adapter = SimulationAdapter();
    _subscription = _adapter.watch().listen((snapshot) {
      if (mounted) setState(() => _snapshot = snapshot);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _adapter.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_dashboard(), _topology(), _history(), _connection()];
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMAR PD3 — FIELDBUS'),
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
          'Perfil PD3-302 / FOUNDATION Fieldbus em validação. Dados somente simulados.',
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
                  'Sinótico — malha hidráulica PD3 (perfil demonstrativo)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.water,
                          size: 82,
                          color: Colors.lightBlue,
                        ),
                        Text(
                          'TK-101   ${level.toStringAsFixed(1)} %',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Text(
                          'P-101 em operação • FV-101 aberta • FIT-101 estável',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Card(
          child: ListTile(
            leading: Icon(Icons.check_circle_outline, color: Colors.tealAccent),
            title: Text('Simulador iniciado'),
            subtitle: Text(
              'Eventos e histórico serão persistidos localmente na próxima etapa.',
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

  Widget _topology() => _pageBody(
    'Topologia',
    'Perfil PD3-302 demonstrativo. A topologia real será criada pela captura passiva.',
    const [
      ListTile(
        leading: Icon(Icons.computer),
        title: Text('Notebook de engenharia'),
        subtitle: Text('Ethernet para controlador ou switch — não conectado'),
      ),
      ListTile(
        leading: Icon(Icons.hub_outlined),
        title: Text('Controlador / bridge — a identificar'),
        subtitle: Text('Modelo e IP serão obtidos pela etiqueta ou PCAPNG'),
      ),
      ListTile(
        leading: Icon(Icons.device_hub),
        title: Text('Segmento FOUNDATION Fieldbus — perfil PD3-302'),
        subtitle: Text('Hipótese de trabalho; sem comandos ativos'),
      ),
    ],
  );

  Widget _history() => _pageBody(
    'Histórico',
    'Persistência local será adicionada sem depender da planta.',
    const [
      ListTile(
        leading: Icon(Icons.info_outline),
        title: Text('Sem dados históricos'),
        subtitle: Text(
          'O simulador hoje alimenta apenas a visualização atual.',
        ),
      ),
    ],
  );

  Widget _connection() => _pageBody(
    'Conexão',
    'Modo seguro: sem descoberta ativa de rede e sem escrita.',
    const [
      ListTile(
        leading: Icon(Icons.play_circle_outline, color: Colors.amber),
        title: Text('Simulador local'),
        subtitle: Text('Ativo para desenvolvimento da interface.'),
      ),
      ListTile(
        leading: Icon(Icons.lock_outline),
        title: Text('Escrita em PLC: bloqueada por projeto.'),
        subtitle: Text(
          'Exige adaptador confirmado, laboratório e autorização explícita.',
        ),
      ),
    ],
  );

  Widget _pageBody(String title, String subtitle, List<Widget> children) =>
      ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(subtitle),
          const SizedBox(height: 24),
          Card(child: Column(children: children)),
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
