library serial_port;

import 'dart:async';
import 'dart:isolate';
import 'dart-ext:serial_port';

// TODO inspiration WebSocket
class SerialPort {

	static SendPort _port;
	
	final String device;
	final int baudrate;

	SerialPort(this.device, this.baudrate);

	// TODO private
	bool open() native "SystemOpen";

	bool close() native "SystemClose";


	//Future<bool open();

	//Future<bool close();

	//Stream onOpen();
	//Stream onClose();
	/*

	Stream<String> onData();

	SendPort get _servicePort {
    	if (_port == null) {
      	_port = _newServicePort();
    	}
    	return _port;
  	}

	SendPort _newServicePort() native "SerialPort_ServicePort";
	*/
}