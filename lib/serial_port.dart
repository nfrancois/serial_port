library serial_port;

import 'dart:async';
import 'dart:isolate';
import 'dart-ext:serial_port';


class SerialPort {

  static const int CONNECTING = 0;
  static const int OPEN = 1;
  static const int CLOSED = 3;
  static const int CLOSING = 2;

  final String portname;
  final int baudrate;

  int _state;

  int _ttyFd;

  SerialPort(this.portname, this.baudrate){
    _state = CONNECTING;
    _ttyFd = _open(portname, baudrate);
    _state = OPEN;
  }

  void close(){
    _state = CLOSING;
    _close(_ttyFd);
    _state = CLOSED;
  }

  int get state => _state;

//Stream<Event> onOpen(){
//  WebSocket
//}

}

int	_open(String portname, int baudrateSpeed) native "nativeOpen";

bool _close(int ttyFd) native "nativeClose";
