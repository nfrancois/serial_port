library test_serial_port;

import 'package:unittest/unittest.dart';
import 'package:serial_port/serial_port.dart';
import 'dart:io';
import 'dart:math';

void main() {
  var dummySerialPort;
  var random = new Random();
  group('Serial port', () {
    setUp(() {
      //dummySerialPort = new File("dummySerialPort-${random.nextInt(999)}.tmp").createSync();
      dummySerialPort = new File("dummySerialPort.tmp");
      return dummySerialPort.create();
    });
    tearDown(() => dummySerialPort.delete());


    test('Just open', () {
      var serial =  new SerialPort(dummySerialPort.path, baudrate: 9600);
      serial.open().then((success) {
        expect(success, isTrue);
        serial.close();
      });
	  });

    test('Just close', () {
      var serial =  new SerialPort(dummySerialPort.path);
      serial.open().then((_) => serial.close())
                   .then((success) =>  expect(success, isTrue));
    });

    test('Defaut baudrate 9600', () {
      var serial =  new SerialPort(dummySerialPort.path);
      expect(serial.baudrate, 9600);
    });

    test('Just write', () {
      var serial =  new SerialPort(dummySerialPort.path);
      serial.open().then((_) => serial.send("Hello"))
                   .then((success) {
                      expect(success, isTrue);
                      serial.close();
                   });
    });

    test('Fail with unkwnon portname', (){
      var serial = new SerialPort("notExist");
      serial.open().catchError((error) => expect(error, "Cannot open portname=notExist"));
    });

    test('Fail with unkwnon baudrate', (){
      try {
        new SerialPort(dummySerialPort.path, baudrate: 1);
      } catch(e){
        expect(e, isArgumentError);
        expect(e.message, "Unknown baudrate speed=1");
      }
    });

  });


}