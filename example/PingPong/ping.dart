import 'package:serial_port/serial_port.dart';

main(){
  var arduino = new SerialPort("/dev/tty.usbmodemfd121", baudrate : 9600);
  arduino.open().then((_) {
    //print("Ctrl-c to close");
    /*
    arduino..onRead.listen((line) {
              if(line == "pong"){
                print("Receive pong");
                arduino.write("ping");
              }
             })
    */
    arduino.write("ping").then((s)=> print("OWrite peration=$s") ).catchError((e) => "Something wrong $e");

  });
}