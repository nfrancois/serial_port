#Serial Port

[![pub package](http://img.shields.io/pub/v/serial_port.svg)](https://pub.dartlang.org/packages/serial_port)
[![Build Status](https://drone.io/github.com/nfrancois/serial_port/status.png)](https://drone.io/github.com/nfrancois/serial_port/latest)
[![Coverage Status](https://img.shields.io/coveralls/nfrancois/serial_port.svg)](https://coveralls.io/r/nfrancois/serial_port)


SerialPort is a Dart Api to provide access read and write access to serial port.
Sorry, Windows is not (yet) supported.

Inspiration come from [node-serialport](https://github.com/voodootikigod/node-serialport).

## Compilation

### Why ?

Yes, it must be compiled because it's a VM extension, depending of execution platform.

### What I need ?

`gcc`, `make` and `dart` must be in PATH

### How compile it ?

 * Install Dart dependencies

```
pub get
```

* Run `make`, cc files will be compiled, and some dart tests will be launched

Output

```
[SerialPort]> make
rm -rf lib/src/libserial_port*.*
dart bin/serial_port.dart compile
Building project "/Users/nicolasfrancois/Documents/dart-bots/serial_port/lib/src/serial_port.yaml"
Building complete successfully
dart test/test_serial_port.dart
unittest-suite-wait-for-done
PASS: Util Convert bytes to string
PASS: Serial port Detect serial port
PASS: Serial port Open
PASS: Serial port Close
PASS: Serial port Write String
PASS: Serial port Write bytes
PASS: Serial port Read bytes
PASS: Serial port Defaut baudrate 9600
PASS: Serial port Fail with unkwnon portname
PASS: Serial port Fail with unkwnon baudrate
PASS: Serial port Fail when open twice
PASS: Serial port Fail when close and not open
PASS: Serial port Fail when writeString and not open
PASS: Serial port Fail when write and not open

All 14 tests passed.
unittest-suite-success
```

## How use it ?

### Echo


```Dart

import 'package:serial_port/serial_port.dart';
import 'dart:async';

main(){
  var arduino = new SerialPort("/dev/tty.usbmodem1421");
  arduino.onRead.map(BYTES_TO_STRING).listen(print);
  arduino.open().then((_) {
    print("Ctrl-c to close");
    new Timer(new Duration(seconds: 2), () => arduino.writeString("Hello !"));
  });
}

```

```c
void setup(){
  Serial.begin(9600);
}

void loop(){
  while (Serial.available() > 0) {
    Serial.write(Serial.read());
  }
}
```
### List connected serial ports

```Dart

import 'package:serial_port/serial_port.dart';
import 'dart:async';

main(){
  SerialPort.availablePortNames.then((portNames) {
  	print("${portNames.length} devices founded:");
    portNames.forEach((device) => print(">$device"));
  });
}


```

# Nexts developments

* Have a better implementation for writing bytes.
* Wait for `TODO(turnidge): Currently handle_concurrently is ignored`from Dart VM.
* Support serial port communication parameter like (parity, stopbits, FLOWCONTROLS, ...).
