library test_serial_port;

import 'package:unittest/unittest.dart';
import 'package:serial_port/serial_port.dart';
import 'dart:io';
import 'dart:math';

void main() {
  File dummySerialPort;
  Random random = new Random();
  group('Serial port', () {
    setUp(() {
      dummySerialPort = new File("dummySerialPort.tmp");
      return dummySerialPort.create();
    });
    tearDown(() => dummySerialPort.delete());

    test('Just open', () {
      var serial =  new SerialPort(dummySerialPort.path, baudrate: 9600);
      serial.open().then((success) {
        expect(success, isTrue);
        //serial.close();
      });
	  });

    /*
    test('Just close', () {
      var serial =  new SerialPort(dummySerialPort.path);
      serial.open().then((_) => serial.close())
                   .then((success) =>  expect(success, isTrue));
    });

    test('Just write', () {
      var serial =  new SerialPort(dummySerialPort.path);
      serial.open().then((_) => serial.write("Hello"))
                   .then((success) {
                      expect(success, isTrue);
                      serial.close();
                   });
    });

    test('Defaut baudrate 9600', () {
      var serial =  new SerialPort(dummySerialPort.path);
      expect(serial.baudrate, 9600);
    });

     test('Fail with unkwnon portname', (){
      var serial = new SerialPort("notExist");
      serial.open().catchError((error) => expect(error, "Cannot open notExist : Invalid access"));
    });

    test('Fail with unkwnon baudrate', (){
      var serial = new SerialPort(dummySerialPort.path, baudrate: 1);
      serial.open().catchError((error) => expect(error, "Cannot open dummySerialPort.tmp : Invalid baudrate"));
    });
    */
  });


}