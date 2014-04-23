import 'package:serial_port/serial_port.dart';

main(){
  var arduino = new SerialPort("/dev/tty.usbmodem1411");
  arduino.open().then((_) {
    print("Ctrl-c to close");
    arduino.onRead.map(BYTES_TO_STRING).listen(print);
   });
}
