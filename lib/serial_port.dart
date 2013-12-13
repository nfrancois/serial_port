library serial_port;

import 'dart:async';
import 'dart:isolate';
import 'dart-ext:serial_port';

// TODO STOPBITS,PARITY, FLOWCONTROLS

class SerialPort {

  static const int _OPEN_METHOD = 1;
  static const int _CLOSE_METHOD = 2;
  static const int _READ_METHOD = 3;
  static const int _WRITE_METHOD = 4;

  static const int _EOL = 10;

  final String portname;
  final int baudrate;
  final int databits;

  final List<StreamController> _onReadControllers = [];
  RawReceivePort _readPort  = null;

  int _ttyFd = -1;

  final StringBuffer _lineBuffer = new StringBuffer();


  SerialPort(this.portname, {this.baudrate : 9600, this.databits: 8});

  Future<bool> open() {
    print("open 1");
    var replyPort = new ReceivePort();
    var completer = new Completer<bool>();
    _servicePort.send([replyPort.sendPort, _OPEN_METHOD, portname, baudrate, databits]);
    replyPort.first.then((List result) {
      if (result[0] == null) {
        _ttyFd = result[1];
        //_read();
        completer.complete(true);
      } else {
        completer.completeError("Cannot open $portname : ${result[0]}");
      }
    });
    return completer.future;
  }

  Future<bool> close(){
    print("close 1");
    // TODO check OPEN
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

  // TODO rename sendString
  // TODO send with List<int>
  Future<bool> write(String data){
    // TODO check OPEN
    var completer = new Completer<bool>();
    var replyPort = new ReceivePort();
    _servicePort.send([replyPort.sendPort, _WRITE_METHOD, _ttyFd, data]);
    replyPort.first.then((result) {
      if (result[1].isEmpty) {
        completer.complete(true);
      } else {
        completer.completeError("Cannot write in $portname : ${result[1]}");
      }
    });
    return completer.future;
  }

  // TODO Stream a List<int>

  Stream<String> get onRead {
    StreamController<String> controller = new StreamController();
    _onReadControllers.add(controller);
    return controller.stream;
  }

  void _read(){
    _readPort = new RawReceivePort();
    _servicePort.send([_readPort.sendPort, _READ_METHOD, _ttyFd, 256]);
    _readPort.handler = (List<int> result) {
      _closeReadPort();
      if(result != null){
        result.forEach((byte) {
          _lineBuffer.write(new String.fromCharCode(byte));
          if(byte == _EOL){
            _onReadControllers.forEach((c) => c.add(_lineBuffer.toString()));
            _lineBuffer.clear();
          }
        });
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
