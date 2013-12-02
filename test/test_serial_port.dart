library test_serial_port;

import 'package:unittest/unittest.dart';
import 'package:serial_port/serial_port.dart';
import 'dart:io';

void main() {
  var dummySerialPort;
  group('Serial port', () {
    setUp(() => dummySerialPort = new File("dummySerialPort.tmp")..createSync());
    tearDown(() => dummySerialPort.deleteSync());
    
    test('Just open', () {
      var serial =  new SerialPort(dummySerialPort.path, 9600);
      serial.onOpen.listen((success) {
        expect(success, isTrue);
        expect(serial.state, SerialPort.OPEN);
      });
	  });

    test('Just close', () {
      var serial =  new SerialPort(dummySerialPort.path, 9600);
      serial.onClose.listen((success) {
        expect(success, isTrue);
        expect(serial.state, SerialPort.CLOSED);
      });
      serial.close();
    });

    test('Just write', () {
      var serial =  new SerialPort(dummySerialPort.path, 9600);
      serial.onOpen.listen((_) => serial.send("Hello"));
      serial.close();
    });

    test('Fail with unkwnon portname', (){
      var serial = new SerialPort("notExist", 9600);
      serial.onError.listen((message){
        expect(message, "Impossible to read portname=notExist");
      });
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