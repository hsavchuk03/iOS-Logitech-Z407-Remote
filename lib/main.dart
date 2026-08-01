import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bluetooth_manager.dart';
import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BluetoothManager()..startScan(),
      child: MaterialApp(
        title: 'Logi Z407 Remote',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xFF090B12),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF5F7CFF),
            secondary: Color(0xFF7C91FF),
            surface: Color(0xFF121725),
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<BluetoothManager>();
    final statusColor = switch (manager.status) {
      BleConnectionStatus.connected => Colors.greenAccent,
      BleConnectionStatus.scanning || BleConnectionStatus.connecting => Colors.amberAccent,
      BleConnectionStatus.error => Colors.redAccent,
      _ => Colors.grey,
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Z407 Remote'),
        actions: [
          IconButton(
            onPressed: () => manager.startScan(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF121725),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            manager.status.name.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            manager.status == BleConnectionStatus.connected &&
                                    manager.deviceName != null
                                ? 'Connected to ${manager.deviceName}'
                                : manager.statusMessage,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Volume',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ClipOval(
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1D2435),
                              const Color(0xFF0F1422),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: Colors.white12, width: 2),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 130,
                        child: GestureDetector(
                          onTap: () => manager.sendCommand(LogiConstants.volumeUp),
                          child: Container(
                            color: Colors.transparent,
                            alignment: Alignment.topCenter,
                            padding: const EdgeInsets.only(top: 28),
                            child: const Text('+', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 130,
                        child: GestureDetector(
                          onTap: () => manager.sendCommand(LogiConstants.volumeDown),
                          child: Container(
                            color: Colors.transparent,
                            alignment: Alignment.bottomCenter,
                            padding: const EdgeInsets.only(bottom: 28),
                            child: const Text('−', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.volume_up_rounded, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + / -',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Bass',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: () => manager.sendCommand(LogiConstants.bassDown),
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  const SizedBox(width: 24),
                  const Icon(Icons.graphic_eq_rounded),
                  const SizedBox(width: 24),
                  IconButton.filled(
                    onPressed: () => manager.sendCommand(LogiConstants.bassUp),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () => manager.sendCommand(LogiConstants.prevTrack),
                    icon: const Icon(Icons.skip_previous_rounded),
                    label: const Text('Previous'),
                  ),
                  FilledButton.icon(
                    onPressed: () => manager.sendCommand(LogiConstants.playPause),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Play/Pause'),
                  ),
                  FilledButton.icon(
                    onPressed: () => manager.sendCommand(LogiConstants.nextTrack),
                    icon: const Icon(Icons.skip_next_rounded),
                    label: const Text('Next Track'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Input',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => manager.sendCommand(LogiConstants.inputBluetooth),
                    icon: const Icon(Icons.bluetooth_rounded),
                    label: const Text('Bluetooth'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => manager.sendCommand(LogiConstants.inputAux),
                    icon: const Icon(Icons.cable_rounded),
                    label: const Text('AUX'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => manager.sendCommand(LogiConstants.inputUsb),
                    icon: const Icon(Icons.usb_rounded),
                    label: const Text('USB'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
