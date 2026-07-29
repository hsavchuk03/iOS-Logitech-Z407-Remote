import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'constants.dart';

enum BleConnectionStatus { scanning, connecting, connected, disconnected, error }

class BluetoothManager extends ChangeNotifier {
  BluetoothManager({String targetDeviceHint = LogiConstants.defaultDeviceHint})
      : _targetDeviceHint = targetDeviceHint;

  final String _targetDeviceHint;

  BluetoothDevice? _device;
  BluetoothCharacteristic? _commandChar;
  BluetoothCharacteristic? _responseChar;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _responseSubscription;
  Completer<void>? _handshakeCompleter;

  final Queue<List<int>> _pendingWrites = Queue<List<int>>();
  bool _isProcessingQueue = false;

  BleConnectionStatus _status = BleConnectionStatus.disconnected;
  String _statusMessage = 'Disconnected';
  String? _deviceName;

  BleConnectionStatus get status => _status;
  String get statusMessage => _statusMessage;
  String? get deviceName => _deviceName;

  Future<void> startScan({Duration timeout = const Duration(seconds: 8)}) async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;

    _setStatus(BleConnectionStatus.scanning, 'Scanning for Z407…');

    try {
      await FlutterBluePlus.stopScan();
      await FlutterBluePlus.startScan(
        withServices: [Guid(LogiConstants.serviceUuid)],
        timeout: timeout,
        androidUsesFineLocation: true,
      );

      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) async {
          for (final result in results) {
            final device = result.device;
            final label = device.platformName.isNotEmpty ? device.platformName : 'Unknown';
            final matchesHint =
                label.toLowerCase().contains(_targetDeviceHint.toLowerCase()) ||
                label.toLowerCase().contains('z407');

            if (matchesHint) {
              _device = device;
              _deviceName = label;
              _setStatus(BleConnectionStatus.connecting, 'Connecting to $label');
              await _scanSubscription?.cancel();
              _scanSubscription = null;
              unawaited(connectToDevice(device));
              return;
            }
          }
        },
        onError: (_) {
          _setStatus(BleConnectionStatus.error, 'Scan failed');
        },
      );
    } catch (_) {
      _setStatus(BleConnectionStatus.error, 'Scan failed');
    }
  }

  Future<void> connectToDevice([BluetoothDevice? device]) async {
    final target = device ?? _device;
    if (target == null) {
      _setStatus(BleConnectionStatus.disconnected, 'No device available');
      return;
    }

    try {
      await target.connect(autoConnect: false);
      _device = target;
      _deviceName = target.platformName.isNotEmpty ? target.platformName : _deviceName;
      _setStatus(BleConnectionStatus.connecting, 'Handshaking with $_deviceName');

      await _discoverCharacteristics();
      await _performHandshake();

      _setStatus(BleConnectionStatus.connected, 'Connected to $_deviceName');
    } catch (e) {
      _setStatus(BleConnectionStatus.error, 'Connection failed: $e');
    }
  }

  Future<void> _discoverCharacteristics() async {
    if (_device == null) {
      return;
    }

    _commandChar = null;
    _responseChar = null;

    final services = await _device!.discoverServices();
    for (final service in services) {
      if (service.uuid.toString().toLowerCase() != LogiConstants.serviceUuid.toLowerCase()) {
        continue;
      }
      for (final characteristic in service.characteristics) {
        final uuid = characteristic.uuid.toString().toLowerCase();
        if (uuid == LogiConstants.commandCharacteristicUuid.toLowerCase()) {
          _commandChar = characteristic;
        } else if (uuid == LogiConstants.responseCharacteristicUuid.toLowerCase()) {
          _responseChar = characteristic;
        }
      }
    }

    if (_commandChar == null || _responseChar == null) {
      throw Exception('Z407 control characteristics not found');
    }
  }

  // The speaker requires a two-step handshake after connecting, or it will
  // terminate the connection after a few seconds. See constants.dart for the
  // byte sequences and their source.
  Future<void> _performHandshake() async {
    final commandChar = _commandChar;
    final responseChar = _responseChar;
    if (commandChar == null || responseChar == null) {
      throw Exception('Z407 control characteristics not found');
    }

    _handshakeCompleter = Completer<void>();

    await _responseSubscription?.cancel();
    await responseChar.setNotifyValue(true);
    _responseSubscription = responseChar.onValueReceived.listen(_handleResponse);

    await commandChar.write(LogiConstants.handshakeInitiate, withoutResponse: true);

    await _handshakeCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('Z407 handshake timed out'),
    );
  }

  void _handleResponse(List<int> data) {
    if (_bytesEqual(data, LogiConstants.handshakeInitiateResponse)) {
      unawaited(_commandChar?.write(LogiConstants.handshakeAcknowledge, withoutResponse: true));
    } else if (_bytesEqual(data, LogiConstants.handshakeConnectedResponse)) {
      final completer = _handshakeCompleter;
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }
    }
  }

  bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  Future<void> sendCommand(List<int> payload) async {
    _pendingWrites.add(List<int>.from(payload));
    if (_isProcessingQueue) {
      return;
    }

    _isProcessingQueue = true;
    try {
      while (_pendingWrites.isNotEmpty) {
        final nextPayload = _pendingWrites.removeFirst();
        await _writePayload(nextPayload);
        await Future<void>.delayed(const Duration(milliseconds: 120));
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  Future<void> _writePayload(List<int> payload) async {
    if (_device == null) {
      await connectToDevice();
      return;
    }

    final connectionState = await _device!.connectionState.first;
    if (connectionState != BluetoothConnectionState.connected || _commandChar == null) {
      await connectToDevice();
    }

    if (_commandChar == null) {
      _setStatus(BleConnectionStatus.disconnected, 'Device unavailable');
      return;
    }

    try {
      await _commandChar!.write(payload, withoutResponse: true);
    } catch (e) {
      _setStatus(BleConnectionStatus.error, 'Write failed: $e');
      debugPrint('BLE write failed: $e');
    }
  }

  Future<void> disconnect() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await _responseSubscription?.cancel();
    _responseSubscription = null;
    await FlutterBluePlus.stopScan();

    if (_device != null) {
      try {
        await _device!.disconnect();
      } catch (_) {}
    }

    _device = null;
    _commandChar = null;
    _responseChar = null;
    _setStatus(BleConnectionStatus.disconnected, 'Disconnected');
  }

  void _setStatus(BleConnectionStatus status, String message) {
    _status = status;
    _statusMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _responseSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }
}
