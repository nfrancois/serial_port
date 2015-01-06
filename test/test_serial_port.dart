// Copyright (c) 2014, Nicolas François
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library test_serial_port;

import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:serial_port/serial_port.dart';
import 'package:unittest/vm_config.dart';
import 'package:mockable_filesystem/mock_filesystem.dart';

void main() {

  useVMConfiguration();

  group('Util', (){

    test('Convert bytes to string', (){
      expect(BYTES_TO_STRING([72, 101, 108, 108, 111]), "Hello");
    });

  });

  group('Serial port', () {

    File portNameFile;
    String portName;

    setUp(() {
      fileSystem = new MockFileSystem();
      fileSystem.getDirectory("/dev").createSync();
      portName = "/dev/tty-usb-device-${new Random().nextInt(99999999)}";
      portNameFile = fileSystem.getFile(portName);
      return portNameFile.create();
    });

    test('Detect serial port', (){
      SerialPort.avaiblePortNames.then((names){
        // Not easy to have test for all Plateform. The minimal requiment is nothing detected
        expect(names, isNotNull);
      });
    });

    test('Open', () {
      var serial =  new SerialPort(portNameFile.path, baudrate: 9600);
      serial.open().then((_) {
        expect(serial.fd!=-1, isTrue);
        expect(serial.isOpen, isTrue);
        serial.close();
      });
	  });


    test('Close', () {
      var serial =  new SerialPort(portName);
      serial.open().then((_) => serial.close())
                   .then((success) {
                      expect(serial.fd==-1, isTrue);
                      expect(serial.isOpen, isFalse);
      });
    });

     test('Write String', () {
      var serial =  new SerialPort(portName);
      serial.open().then((_) => serial.writeString("Hello"))
                   .then((success) {
                      expect(success, isNull);
                      serial.close();
                   });
    });

    test('Write bytes', () {
      var serial =  new SerialPort(portName);
      serial.open().then((_) => serial.write([72, 101, 108, 108, 111]))
                   .then((success) {
                      expect(success, isTrue);
                      serial.close();
                   });
    });

    test('Read bytes', (){
      var serial =  new SerialPort(portName);

      final t = new Timer(new Duration(seconds: 1), () {
        print("fail");
        print("${serial.fd}");
        if(serial.isOpen){
          serial.close();
        }
        fail('event not fired in time');
      });

      serial.open().then((_) {
        serial.onRead.first.then((List<int> bytes) {
          serial.close();
          t.cancel();
          expect(bytes, "Hello".codeUnits);
        });

      });

      portNameFile.writeAsStringSync("Hello");

    });

    test('Defaut baudrate 9600', () {
      var serial =  new SerialPort(portName);
      expect(serial.baudrate, 9600);
    });

     test('Fail with unkwnon portname', (){
      var serial = new SerialPort("notExist");
      serial.open().catchError((error) => expect(error, "Cannot open notExist : Invalid access"));
    });

    test('Fail with unkwnon baudrate', (){
      var serial = new SerialPort(portName, baudrate: 1);
      serial.open().catchError((error) => expect(error, "Cannot open dummySerialPort.tmp : Invalid baudrate"));
    });

    test('Fail when open twice', (){
      var serial =  new SerialPort(portName);
      serial.open().then((_) {
        serial.open().catchError((error) => expect(error, "${portNameFile.path} is yet open"));
      }).then((_) => serial.close());
    });


    test('Fail when close and not open', (){
      var serial =  new SerialPort(portName);
      serial.close().catchError((error) => expect(error, "${portNameFile.path} is not open"));
    });

    test('Fail when writeString and not open', (){
      var serial =  new SerialPort(portName);
      serial.writeString("Hello").catchError((error) => expect(error, "${portNameFile.path} is not open"));
    });

    test('Fail when write and not open', (){
      var serial =  new SerialPort(portName);
      serial.write("Hello".codeUnits).catchError((error) => expect(error, "${portNameFile.path} is not open"));
    });

 });


}
