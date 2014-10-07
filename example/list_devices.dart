import 'package:serial_port/serial_port.dart';
import 'dart:async';

main(){
  SerialPort.avaiblePortNames.then((portnames) {
  	print("${portnames.length} devices founded:");
    portnames.forEach((device) => print(">$device"));
  });
}
