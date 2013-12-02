import 'package:serial_port/serial_port.dart';

main(){

  var arduino = new SerialPort("/dev/tty.usbmodemfd131", 9600);
  arduino..onError.listen((message) {
          print("ERROR: $message");
        })
         ..onOpen.listen((_) {
          arduino.send("Hello");
          arduino.close();
        });


}