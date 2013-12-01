library serial_port;

import 'dart:async';
import 'dart:isolate';
import 'dart-ext:serial_port';


class SerialPort {

  static const int CONNECTING = 0;
  static const int OPEN = 1;
  static const int CLOSED = 3;
  static const int CLOSING = 2;

  static SendPort _port;

  final String portname;
  final int baudrate;

  final List<StreamController> _openControllers = [];

  int _state;

  int _ttyFd;

  SerialPort(this.portname, this.baudrate){
    _state = CONNECTING;
    //_ttyFd = _open(portname, baudrate);
    _openAsync(portname, baudrate).then((value) {
      _ttyFd = value;
      _state = OPEN;
      _openControllers.forEach((controller) => controller.add(true));
    });
    // TODO on error ?
  }

  // TODO : event ?
  Stream<bool> get onOpen {
    StreamController<bool> controller = new StreamController();
    _openControllers.add(controller);
    return controller.stream;
  }

  void close(){
    _state = CLOSING;
    //_close(_ttyFd);
    _state = CLOSED;
  }

  int get state => _state;

  Future<int> _openAsync(String portname, int baudrate) {
    var completer = new Completer();
    var replyPort = new RawReceivePort();
    var args = new List(3);
    args[0] = portname;
    args[1] = baudrate;
    args[2] = replyPort.sendPort;
    _servicePort.send(args);
    replyPort.handler = (result) {
      replyPort.close();
      if (result != null) {
        completer.complete(result);
      } else {
        completer.completeError(new Exception("FAIL"));
      }
    };
    return completer.future;
  }

  SendPort get _servicePort {
    if (_port == null) {
      _port = _openServicePort();
    }
    return _port;
  }

  SendPort _openServicePort() native "openAsyncServicePort";

}

int	_open(String portname, int baudrateSpeed) native "openSync";

bool _close(int ttyFd) native "closeSync";
