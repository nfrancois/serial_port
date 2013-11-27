library test_serial_port;

import 'package:unittest/unittest.dart';
import 'package:unittest/matcher.dart' as m;
import '../lib/serial_port.dart';
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
  });

}