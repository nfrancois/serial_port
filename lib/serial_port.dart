library serial_port;

import 'dart:async';
import 'dart:isolate';
import 'dart-ext:serial_port';


class SerialPort {

  static const int CONNECTING = 0;
  static const int OPEN = 1;
  static const int CLOSED = 3;
  static const int CLOSING = 2;

  static const List<int> AUTHORIZED_BAUDATE_SPEED =  const [50, 75, 110, 134, 150, 200, 300, 600, 1200, 1800, 2400, 4800, 9600, 19200, 38400, 57600, 115200, 230400];

  static SendPort _port;

  final String portname;
  final int baudrate;

  final List<StreamController> _openControllers = [];
  final List<StreamController> _errorControllers = [];
  final List<StreamController> _closeControllers = [];

  // TODO fail state ?
  int _state;

  int _ttyFd;

  SerialPort(this.portname, this.baudrate){
    _state = CONNECTING;
    if(!AUTHORIZED_BAUDATE_SPEED.contains(baudrate)){
      throw new ArgumentError("Unknown baudrate speed=$baudrate");
    }
    _openAsync(portname, baudrate);
  }

  Stream<bool> get onOpen {
    StreamController<bool> controller = new StreamController();
    _openControllers.add(controller);
    return controller.stream;
  }

  Stream<String> get onError {
    StreamController<String> controller = new StreamController();
    _errorControllers.add(controller);
    return controller.stream;
  }

  Stream<bool> get onClose {
    StreamController<bool> controller = new StreamController();
    _closeControllers.add(controller);
    return controller.stream;
  }

  void close(){
    // TODO check OPEN
    _state = CLOSING;
    var replyPort = new RawReceivePort();
    var args = new List(3);
    args[0] = replyPort.sendPort;
    args[1] = "close";
    args[2] = _ttyFd;
    _servicePort.send(args);
    replyPort.handler = (result) {
      replyPort.close();
      if (result != null) {
        _closeControllers.forEach((controller) => controller.add(true));
        _state = CLOSED;
      }
    };
  }

  void send(String data){
    // TODO check OPEN
    _state = CLOSING;
    var replyPort = new RawReceivePort();
    var args = new List(4);
    args[0] = replyPort.sendPort;
    args[1] = "send";
    args[2] = _ttyFd;
    args[3] = data;
    _servicePort.send(args);
    replyPort.handler = (result) {
      replyPort.close();
      if (result != null) {
        if(result < 0){
          _errorControllers.forEach((controller) => controller.add("Cannot write data=$data on serial port $nameport"));
        }
      }
    };
  }

  int get state => _state;

  void _openAsync(String portname, int baudrate) {
    var replyPort = new RawReceivePort();
    var args = new List(4);
    args[0] = replyPort.sendPort;
    args[1] = "open";
    args[2] = portname;
    args[3] = baudrate;
    _servicePort.send(args);
    replyPort.handler = (result) {
      replyPort.close();
      if (result != null) {
        if(result > 0){
          _ttyFd = result;
          _state = OPEN;
          _openControllers.forEach((controller) => controller.add(true));
        } else {
          _errorControllers.forEach((controller) => controller.add("Impossible to read portname=$portname"));
        }
      }
    };
  }

  SendPort get _servicePort {
    if (_port == null) {
      _port = _newServicePort();
    }
    return _port;
  }

  SendPort _newServicePort() native "serialPortServicePort";

}
