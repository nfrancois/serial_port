part of serial_port;

// TODO STOPBITS,PARITY, FLOWCONTROLS

class SerialPort {

  // TODO wait for enum
  static const int _OPEN_METHOD = 1;
  static const int _CLOSE_METHOD = 2;
  static const int _READ_METHOD = 3;
  static const int _WRITE_METHOD = 4;
  static const int _WRITE_BYTE_METHOD = 5;

  static const int _EOL = 10;

  final String portname;
  final int baudrate;
  final int databits;

  final List<StreamController<List<int>>> _onReadControllers = [];
  RawReceivePort _readPort  = null;

  int _ttyFd = -1;

  SerialPort(this.portname, {this.baudrate : 9600, this.databits: 8});

  Future<bool> open() {
    if(_ttyFd != -1){
      throw new StateError("$portname is yet open.");
    }
    var replyPort = new ReceivePort();
    var completer = new Completer<bool>();
    _servicePort.send([replyPort.sendPort, _OPEN_METHOD, portname, baudrate, databits]);
    replyPort.first.then((List result) {
      if (result[0] == null) {
        _ttyFd = result[1];
        _read();
        completer.complete(true);
      } else {
        completer.completeError("Cannot open $portname : ${result[0]}");
      }
    });
    return completer.future;
  }

  /// Getter for open connection
  bool get isOpen => _ttyFd != -1;

  /// Getter for file descriptor (just for debug)
  int get fd => _ttyFd;

  Future<bool> close(){
    _checkOpen();
    var completer = new Completer<bool>();
    var replyPort = new ReceivePort();
    _servicePort.send([replyPort.sendPort, _CLOSE_METHOD, _ttyFd]);
    replyPort.first.then((List result) {
      if (result[0] == null) {
        _ttyFd = -1;
        completer.complete(true);
      } else {
        completer.completeError("Cannot close $portname : ${result[0]}");
      }
    });
    return completer.future;
  }

  // TODO rename sendString ?
  Future<bool> writeString(String data){
    _checkOpen();
    var completer = new Completer<bool>();
    var replyPort = new ReceivePort();
    _servicePort.send([replyPort.sendPort, _WRITE_METHOD, _ttyFd, data]);
    replyPort.first.then((result) {
      if (result[0] == null) {
        completer.complete(true);
      } else {
        completer.completeError("Cannot write in $portname : ${result[0]}");
      }
    });
    return completer.future;
  }

  Future<bool> write(List<int> bytes){
    // TODO have a real c implementation for send by bytes
    final writes = bytes.map((byte) => _writeOneByte(byte));
    return Future.wait(writes, eagerError: true).then((_) => true);
  }

  Future<bool> _writeOneByte(int byte){
    _checkOpen();
    var completer = new Completer<bool>();
    var replyPort = new ReceivePort();
    _servicePort.send([replyPort.sendPort, _WRITE_BYTE_METHOD, _ttyFd, byte]);
    replyPort.first.then((result) {
      if (result[0] == null) {
        completer.complete(true);
      } else {
        completer.completeError("Cannot write in $portname : ${result[0]}");
      }
    });
    return completer.future;
  }

  Stream<List<int>> get onRead {
    StreamController<String> controller = new StreamController();
    _onReadControllers.add(controller);
    return controller.stream;
  }

  void _read(){
    _readPort = new RawReceivePort();
    _servicePort.send([_readPort.sendPort, _READ_METHOD, _ttyFd, 256]);
    _readPort.handler = (List<int> result) {
      _closeReadPort();
      // TODO when  result[0] != null
      if(result[0] == null && result[1] != null){
        _onReadControllers.forEach((c) => c.add(result[1]));
      }
      // Continue to read
      if(_ttyFd != -1){
        _read();
      }
    };
  }

  void _closeReadPort(){
    if(_readPort != null){
      _readPort.close();
      _readPort = null;
    }
  }

  void _checkOpen(){
    if(_ttyFd == -1){
      throw new StateError("$portname is not open.");
    }
  }

  // Communication with native part

  static SendPort _port;

  SendPort get _servicePort {
    if (_port == null) {
      _port = _newServicePort();
    }
    return _port;
  }

  SendPort _newServicePort() native "serialPortServicePort";

}
