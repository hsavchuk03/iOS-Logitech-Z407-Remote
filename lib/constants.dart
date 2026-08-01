class LogiConstants {
  static const String serviceUuid = '0000fdc2-0000-1000-8000-00805f9b34fb';
  static const String commandCharacteristicUuid =
      'c2e758b9-0e78-41e0-b0cb-98a593193fc5';
  static const String responseCharacteristicUuid =
      'b84ac9c6-29c5-46d4-bba1-9d534784330f';

  // Connection handshake (required after connecting, or the speaker drops
  // the connection after a few seconds). See:
  // https://github.com/freundTech/logi-z407-reverse-engineering/blob/main/doc/Protocol.md
  static const List<int> handshakeInitiate = [0x84, 0x05];
  static const List<int> handshakeAcknowledge = [0x84, 0x00];
  static const List<int> handshakeInitiateResponse = [0xd4, 0x05, 0x01];
  static const List<int> handshakeAckResponse = [0xd4, 0x00, 0x01];
  static const List<int> handshakeConnectedResponse = [0xd4, 0x00, 0x03];

  // Audio control
  static const List<int> bassUp = [0x80, 0x00];
  static const List<int> bassDown = [0x80, 0x01];
  static const List<int> volumeUp = [0x80, 0x02];
  static const List<int> volumeDown = [0x80, 0x03];

  // Playback control
  static const List<int> playPause = [0x80, 0x04];
  static const List<int> nextTrack = [0x80, 0x05];
  static const List<int> prevTrack = [0x80, 0x06];

  // Source switching
  static const List<int> inputBluetooth = [0x81, 0x01];
  static const List<int> inputAux = [0x81, 0x02];
  static const List<int> inputUsb = [0x81, 0x03];
}
