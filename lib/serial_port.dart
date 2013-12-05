library serial_port;

import 'dart:async';
import 'dart:isolate';
import 'dart-ext:serial_port';

class SerialPort {


  static const List<int> AUTHORIZED_BAUDATE_SPEED =  const [50, 75, 110, 134, 150, 200, 300, 600, 1200, 1800, 2400, 4800, 9600, 19200, 38400, 57600, 115200, 230400, 4000000];

  final String portname;
  final int baudrate;

  final List<StreamController> _onReadControllers = [];
  RawReceivePort _readPort  = null;

  int _ttyFd = -1;

  SerialPort(this.portname, {this.baudrate : 9600}){
    if(!AUTHORIZED_BAUDATE_SPEED.contains(baudrate)){
      throw new ArgumentError("Unknown baudrate speed=$baudrate");
    }
  }

  Future<bool> close(){
    // TODO check OPEN
    var completer = new Completer<bool>();
    var replyPort = new ReceivePort();
    _servicePort.send([replyPort.sendPort, "close", _ttyFd]);
    replyPort.first.then((result) {
      if (result != null) {
          _ttyFd = -1;
          completer.complete(true);
      } else {
        completer.completeError("Unexpected error when closing");
      }
    });
    return completer.future;
  }

  // TODO rename sendString
  // TODO send with List<int>
  Future<bool> send(String data){
    // TODO check OPEN
    var completer = new Completer<bool>();
    var replyPort = new ReceivePort();
    _servicePort.send([replyPort.sendPort, "send", _ttyFd, data]);
    replyPort.first.then((result) {
      if (result != null) {
        if(result >= 0){
          completer.complete(true);
        } else {
          completer.completeError("Impossible to write.");
        }
      } else {
        completer.completeError("Unexpected error when writing");
      }
    });
    return completer.future;
  }

  Future<bool> open() {
    var replyPort = new ReceivePort();
    var completer = new Completer<bool>();
    _servicePort.send([replyPort.sendPort, "open", portname, baudrate, 256]);
    replyPort.first.then((result) {
      if (result != null) {
        if(result >= 0){
          _ttyFd = result;
          _read();
           completer.complete(true);
        } else {
          completer.completeError("Cannot open portname=$portname");
        }
      } else {
        completer.completeError("Unexpected error when opening");
      }
    });
    return completer.future;
  }

  Stream<String> get onRead {
    StreamController<String> controller = new StreamController();
    _onReadControllers.add(controller);
    return controller.stream;
  }

  void _read(){
    _readPort = new RawReceivePort();
    _servicePort.send([_readPort.sendPort, "read", _ttyFd]);
    _readPort.handler = (result) {
      _closeReadPort();
      if(result != null){
        _onReadControllers.forEach((c) => c.add(new String.fromCharCodes(result)));
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
