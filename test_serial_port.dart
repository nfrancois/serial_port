library test_serial_port;

import 'serial_port.dart';
import 'dart:io';

// TODO : test with unnitest
// TODO : setup & tear down

void check(bool condition, String message) {
  if (!condition) {
    throw new StateError(message);
  }
}

void main() {
  //var successOpen = open("/dev/tty.usbmodemfd131", 9600);
  var dummySerialPort = new File("dummySerialPort.tmp")..createSync();
  var successOpen = open(dummySerialPort.path, 9600);
  check(successOpen == true, "Should open");
  var successClose = close();
  check(successOpen == true, "Should close");
}