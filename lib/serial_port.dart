library serial_port;

import 'dart:async';
import 'dart:isolate';
import 'dart-ext:serial_port';


class SerialPort {

  final String portname;
  final int baudrate;

  int _ttyFd;

  SerialPort(this.portname, this.baudrate){
    _ttyFd = _open(portname, baudrate);	
  }

  void close(){
    _close(_ttyFd);
  }

}

int	_open(String portname, int baudrateSpeed) native "nativeOpen";

bool _close(int ttyFd) native "nativeClose";
