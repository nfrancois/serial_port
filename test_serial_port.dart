library test_serial_port;

import 'serial_port.dart';

void main() {
  var successOpen = open("/dev/tty.usbmodemfd131", 9600);
  
  print(successOpen);
}