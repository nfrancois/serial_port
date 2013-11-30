library test_serial_port;

import 'package:unittest/unittest.dart';
import 'package:serial_port/serial_port.dart';
import 'dart:io';

// TODO : test with unnitest
// TODO : setup & tear down

void check(bool condition, String message) {
  if (!condition) {
    throw new StateError(message);
  }
}

void main() {
  var dummySerialPort;
  group('Serial port', () {
    setUp(() => dummySerialPort = new File("dummySerialPort.tmp")..createSync());
    tearDown(() => dummySerialPort.deleteSync());
    
    test('Just open and close', () {
      var serial =  new SerialPort(dummySerialPort.path, 9600);
      expect(serial.state, SerialPort.OPEN);
      serial.close();
      expect(serial.state, SerialPort.CLOSED);
	  });

    test('Fail with unkwnon portname', (){
      try {
        new SerialPort("notExist", 9600);  
      } catch(e){
        expect(e, isException);
        expect(e.message, "Impossible to read portname=notExist");   
      }
    });

   test('Fail with unkwnon baudrate', (){
      try {
        new SerialPort(dummySerialPort.path, 1);
      } catch(e){
        expect(e, isArgumentError);
        expect(e.message, "Unknown baudrate speed=1");   
      }
      
    });
  });

}