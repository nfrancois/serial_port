import 'package:serial_port/serial_port.dart';

main(){

  var arduino = new SerialPort("/dev/tty.usbmodemfd131", baudrate : 9600);
  arduino.open().then((_) {
    print("Ctrl-c to close");
    arduino.onRead.listen(print);
    arduino.write("Hello");
          //arduino.close();
   });


}