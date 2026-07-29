import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:logi_z407_remote/bluetooth_manager.dart';
import 'package:logi_z407_remote/main.dart';

void main() {
  testWidgets('Home page renders the Z407 controls', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<BluetoothManager>(
        create: (_) => BluetoothManager(),
        child: const MaterialApp(home: HomePage()),
      ),
    );

    expect(find.text('Z407 Remote'), findsOneWidget);
    expect(find.text('Volume'), findsOneWidget);
    expect(find.text('Bass'), findsOneWidget);
    expect(find.text('Input'), findsOneWidget);
    expect(find.text('Play/Pause'), findsOneWidget);
    expect(find.text('Bluetooth'), findsOneWidget);
    expect(find.text('AUX'), findsOneWidget);
    expect(find.text('USB'), findsOneWidget);
  });
}
