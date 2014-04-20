import 'package:serial_port/serial_port.dart';

main(){
  var arduino = new SerialPort("/dev/tty.usbmodem1411", baudrate : 9600);
  arduino.open().then((_) {
    print("Ctrl-c to close");
    arduino.onRead.map((data) => new String.fromCharCodes(data)).listen(print);
   });
}
