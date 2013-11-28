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
	    var successOpen = open(dummySerialPort.path, 9600);
	    expect(successOpen, isTrue);
	    var successClose = close();
	    expect(successClose, isTrue);
	  });

    test('Fail with unkwnon portname', (){
      var successOpen = open('Does not exist', 9600);
      expect(successOpen, isFalse);
    });

   test('Fail with unkwnon baudrate', (){
      try {
        open(dummySerialPort.path, 1);
      } catch(e){
        expect(e, isArgumentError);
        expect(e.message, "Unknown baudrate speed=1");   
      }
      
    });
  });

}