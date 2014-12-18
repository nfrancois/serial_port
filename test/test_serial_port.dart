library test_serial_port;

import 'package:unittest/unittest.dart';
import 'package:serial_port/serial_port.dart';
import 'dart:io';
import 'dart:math';
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

void main() {
  File dummySerialPort;
  Random random = new Random();
  group('Util', (){
    test('Convert bytes to string', (){
      expect(BYTES_TO_STRING([72, 101, 108, 108, 111]), "Hello");
    });
  });
  group('Serial port', () {
    setUp(() {
      dummySerialPort = new File("dummySerialPort.tmp");
      return dummySerialPort.create();
    });
    tearDown(() => dummySerialPort.delete());

    test('Open', () {
      var serial =  new SerialPort(dummySerialPort.path, baudrate: 9600);
      serial.open().then((_) {
        expect(serial.fd!=-1, isTrue);
        expect(serial.isOpen, isTrue);
        serial.close();
      });
	  });


    test('Close', () {
      var serial =  new SerialPort(dummySerialPort.path);
      serial.open().then((_) => serial.close())
                   .then((success) {
                      expect(serial.fd==-1, isTrue);
                      expect(serial.isOpen, isFalse);
      });
    });

     test('Write String', () {
      var serial =  new SerialPort(dummySerialPort.path);
      serial.open().then((_) => serial.writeString("Hello"))
                   .then((success) {
                      expect(success, isNull);
                      serial.close();
                   });
    });

    test('Write bytes', () {
      var serial =  new SerialPort(dummySerialPort.path);
      serial.open().then((_) => serial.write([72, 101, 108, 108, 111]))
                   .then((success) {
                      expect(success, isTrue);
                      serial.close();
                   });
    });

    test('Read bytes', (){
      var serial =  new SerialPort(dummySerialPort.path);
      dummySerialPort.writeAsStringSync("Hello");
      serial.open().then((_){
        serial.onRead.first.then((List<int> bytes) {
          expect(bytes, "Hello".codeUnits);
          serial.close();
        });
      });
    });

    /*
    test('Read bytes', (){
      var serial =  new SerialPort(dummySerialPort.path);
      serial.open().then((_){
        serial.onRead.first.then((List<int> bytes) {
          expect(bytes, "Hello".codeUnits);
          serial.close();
        });
        dummySerialPort..writeAsStringSync("Hello");
      });
    });
    */

    test('Defaut baudrate 9600', () {
      var serial =  new SerialPort(dummySerialPort.path);
      expect(serial.baudrate, 9600);
    });

     test('Fail with unkwnon portname', (){
      var serial = new SerialPort("notExist");
      serial.open().catchError((error) => expect(error, "Cannot open notExist : Invalid access"));
    });

    test('Fail with unkwnon baudrate', (){
      var serial = new SerialPort(dummySerialPort.path, baudrate: 1);
      serial.open().catchError((error) => expect(error, "Cannot open dummySerialPort.tmp : Invalid baudrate"));
    });

 });


}
