// Copyright (c) 2014, Nicolas François
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of serial_port;

// TODO STOPBITS,PARITY, FLOWCONTROLS

class SerialPort {

  // TODO wait for enum
  static const int _TEST_PORT = 0;
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

  /// List all avaible port names
  static Future<List<String>> get avaiblePortNames {
    final Completer<List<String>> completer = new Completer();
    _systemPortNames.then((List<String> portnames) {
       final Iterable<List<bool>> areAvaibles = portnames.map(_isAvaiblePortName);
       Future.wait(areAvaibles).then((avaibility){
         completer.complete(avaibility.where((p) => p.isAvaible).map((p) => p.portname).toList());
       });
    });
    return completer.future;
  }

  /// List of potential portname depending for OS.
  static Future<List<String>> get _systemPortNames {
    var portNamesWildCart;
    if(Platform.isMacOS) {
      portNamesWildCart = "/dev/tty.*";
    } else if(Platform.isLinux){
      portNamesWildCart = "/dev/ttyS*";
    } else {
      throw new UnsupportedError("Cannot find serial port for this OS");
    }
    return Process.run('/bin/sh', ['-c', 'ls $portNamesWildCart'])
                  .then((ProcessResult results) => results.stdout
                                                          .split('\n')
                                                          .where((String name) => name.isNotEmpty)
                                                          .toList());
  }

  /// Ask to system if port name is avaible
  static Future<_PortNameAvailability> _isAvaiblePortName(String portname){
    final replyPort = new ReceivePort();
    final completer = new Completer<_PortNameAvailability>();
    _servicePort.send([replyPort.sendPort, _TEST_PORT, portname, portname]);
    replyPort.first.then((List result) {
      if (result[0] == null) {
        completer.complete(new _PortNameAvailability(portname, result[1]));
      } else {
        completer.complete(new _PortNameAvailability(portname, false));
      }
    });
    return completer.future;
  }

  /// Open the connection with serial port.
  Future<bool> open() {
    if(_ttyFd != -1){
      throw new StateError("$portname is yet open.");
    }
    final replyPort = new ReceivePort();
    final completer = new Completer<bool>();
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

  /// Close the connection.
  Future<bool> close(){
    _checkOpen();
    final completer = new Completer<bool>();
    final replyPort = new ReceivePort();
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

  /// Write as a string
  Future<bool> writeString(String data){
    _checkOpen();
    final completer = new Completer<bool>();
    final replyPort = new ReceivePort();
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

  /// Write bytes
  Future<bool> write(List<int> bytes){
    final writes = bytes.map((byte) => _writeOneByte(byte));
    return Future.wait(writes, eagerError: true).then((_) => true);
  }

  Future<bool> _writeOneByte(int byte){
    _checkOpen();
    final completer = new Completer<bool>();
    final replyPort = new ReceivePort();
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

  /// Read data send from the serial port
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

  static SendPort get _servicePort {
    if (_port == null) {
      _port = _newServicePort();
    }
    return _port;
  }

  static SendPort _newServicePort() native "serialPortServicePort";

}

/// Wrap a portname and it avaible result;
class _PortNameAvailability {
  final String portname;
  final bool isAvaible;

  _PortNameAvailability(this.portname, this.isAvaible);
}
