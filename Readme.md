#SerialPort


SerialPort is a Dart Api to provide access for reading and reading with serial port.

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
dart build.dart
Building project "/Users/nicolasfrancois/Documents/SerialPort/lib/src/serial_port.yaml"
Building complete successfully
dart test/test_serial_port.dart
unittest-suite-wait-for-done
PASS: Serial port Just open
PASS: Serial port Just close
PASS: Serial port Just write
PASS: Serial port Defaut baudrate 9600
PASS: Serial port Fail with unkwnon portname
PASS: Serial port Fail with unkwnon baudrate

All 6 tests passed.
unittest-suite-success
```

## How use it ?

// TODO


# Current development

* Use byte array instead of string to write on serial port.
* Wait for `TODO(turnidge): Currently handle_concurrently is ignored`from Dart VM.
* Support serial port communication parameter like node-serialport.

