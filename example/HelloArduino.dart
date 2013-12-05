import 'package:serial_port/serial_port.dart';

main(){

  var arduino = new SerialPort("/dev/tty.usbmodemfd131", baudrate : 9600);
  arduino.open().then((_) {
          arduino.onRead.listen(print);
          arduino.send("Hello");
          arduino.close();
        });


}