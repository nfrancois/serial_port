library serial_port;

import 'dart:async';
import 'dart:isolate';
import 'dart-ext:serial_port';

class SerialPort {

  // TODO : Review state
  static const int CONNECTING = 0;
  static const int OPEN = 1;
  static const int CLOSED = 3;
  static const int CLOSING = 2;

  static const List<int> AUTHORIZED_BAUDATE_SPEED =  const [50, 75, 110, 134, 150, 200, 300, 600, 1200, 1800, 2400, 4800, 9600, 19200, 38400, 57600, 115200, 230400, 4000000];

  final String portname;
  final int baudrate;

  // TODO fail state ?
  int _state;

  int _ttyFd;

  SerialPort(this.portname, {this.baudrate : 9600}){
    _state = CONNECTING;
    if(!AUTHORIZED_BAUDATE_SPEED.contains(baudrate)){
      throw new ArgumentError("Unknown baudrate speed=$baudrate");
    }
  }

  Future<bool> close(){
    // TODO check OPEN
    _state = CLOSING;
    var completer = new Completer<bool>();
    var replyPort = new RawReceivePort();
    _servicePort.send([replyPort.sendPort, "close", _ttyFd]);
    replyPort.handler = (result) {
      replyPort.close();
      if (result != null) {
        // TODO return value ?
        _state = CLOSED;
        completer.complete(true);
      } else {
        completer.completeError("Unexpected error");
      }
    };
    return completer.future;
  }

  // TODO rename sendString
  // TODO send with List<int>
  // TODO Future
  Future<bool> send(String data){
    // TODO check OPEN
    var completer = new Completer<bool>();
    var replyPort = new RawReceivePort();
    _servicePort.send([replyPort.sendPort, "send", _ttyFd, data]);
    replyPort.handler = (result) {
      replyPort.close();
      if (result != null) {
        if(result >= 0){
          completer.complete(true);
        } else {
          completer.completeError("Impossible to write.");
        }
      } else {
        completer.completeError("Unexpected error");
      }
    };
    return completer.future;
  }

  Future<bool> open() {
    var replyPort = new RawReceivePort();
    var completer = new Completer<bool>();
    _servicePort.send([replyPort.sendPort, "open", portname, baudrate]);
    replyPort.handler = (result) {
      replyPort.close();
      if (result != null) {
        if(result >= 0){
          _state = OPEN;
          completer.complete(true);
        } else {
          completer.completeError("Cannot open portname=$portname");
        }
      } else {
        completer.completeError("Unexpected error");
      }
    };
    return completer.future;
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
