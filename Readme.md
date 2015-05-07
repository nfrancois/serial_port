#Serial Port

[![pub package](http://img.shields.io/pub/v/serial_port.svg)](https://pub.dartlang.org/packages/serial_port)
[![Build Status](https://drone.io/github.com/nfrancois/serial_port/status.png)](https://drone.io/github.com/nfrancois/serial_port/latest)
[![Build status](https://ci.appveyor.com/api/projects/status/btsc9dnff8445ff2?svg=true)](https://ci.appveyor.com/project/nfrancois/serial-port)
[![Coverage Status](https://img.shields.io/coveralls/nfrancois/serial_port.svg)](https://coveralls.io/r/nfrancois/serial_port)


SerialPort is a Dart Api to provide access read and write access to serial port.

Inspiration come from [node-serialport](https://github.com/voodootikigod/node-serialport).

## Compilation

### Why ?

Yes, it must be compiled because it's a VM extension, depending of execution platform.

### What I need ?

* `gcc`, `make` and `dart` must be in PATH 
* `DARK_SDK` environment_variable

### How compile it ?

 * Install Dart dependencies

```
pub get
```

* Run `bin/serial_port.dart compile`, cc files will be compiled, and some dart tests will be launched

Output

```
> pub run grinder:grinder compile
```

## How use it ?

### Echo

```Dart

import 'package:serial_port/serial_port.dart';
import 'dart:async';

main() async {
  var arduino = new SerialPort("/dev/tty.usbmodem1421");
  arduino.onRead.map(BYTES_TO_STRING).listen(print);
  await arduino.open();
  // Wait a little bit before sending data
  new Timer(new Duration(seconds: 2), () => arduino.writeString("Hello !"));
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

main() async {
  final portNames = await SerialPort.availablePortNames;
  print("${portNames.length} devices found:");
  portNames.forEach((device) => print(">$device"));
}


```

# Nexts developments

* Have a better implementation for writing bytes.
* Wait for `TODO(turnidge): Currently handle_concurrently is ignored`from Dart VM.
* Support serial port communication parameter like (FLOWCONTROLS, ...).
