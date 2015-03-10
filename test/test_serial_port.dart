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


void main() {

  group('Util', (){

    test('Convert bytes to string', (){
      expect(BYTES_TO_STRING([72, 101, 108, 108, 111]), "Hello");
    });

  });

  group('Serial port', () {

    String portName;

    setUp(() {
      return Directory.systemTemp.createTemp('serial_port_test').then((testDir){
        portName = "${testDir.path}/tty-usb-device-${new Random().nextInt(99999999)}";
        return new File(portName).create();
      });
    });

    test('Detect serial port', (){
      SerialPort.availablePortNames.then((names){
        // Not easy to have test for all Platform. The minimal requirement is nothing detected
        expect(names, isNotNull);
      });
    });

    test('Open', () {
      var serial =  new SerialPort(portName, baudrate: 9600);
      serial.open().then(expectAsync((_) {
        expect(serial.fd!=-1, true);
        expect(serial.isOpen, true);
        serial.close();
      }));
	  });

    test('Close', () {
      var serial =  new SerialPort(portName);
      serial.open().then((_) => serial.close())
                   .then(expectAsync((success) {
                      expect(serial.fd, -1);
                      expect(serial.isOpen, false);
      }));
    });

    test('Write String', () {
      var serial =  new SerialPort(portName);
      serial.open().then((_) => serial.writeString("Hello"))
                   .then(expectAsync((success) {
                      expect(success, isNull);
                      serial.close();
                   }));
    });

    test('Write bytes', () {
      var serial =  new SerialPort(portName);
      serial.open().then((_) => serial.write([72, 101, 108, 108, 111]))
                   .then(expectAsync((success) {
                      expect(success, true);
                      serial.close();
                   }));
    });

    test('Read bytes', (){
      var serial =  new SerialPort(portName);

      final t = new Timer(new Duration(seconds: 2), () {
        if(serial.isOpen){
          serial.close();
        }
        fail('event not fired in time');
      });

      serial.open().then((_) {
        serial.onRead.first.then(expectAsync((List<int> bytes) {
          t.cancel();
          serial.close();
          expect(bytes, "Hello".codeUnits);
        }));

      });

      new File(portName).writeAsStringSync("Hello");

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
      serial.open().catchError((error) => expect(error, "Cannot open ${portName} : Invalid baudrate"));
    });

    test('Fail when open twice', (){
      var serial =  new SerialPort(portName);
      serial.open().then((_) {
        serial.open().catchError((error) => expect(error, "${portName} is yet open"));
      }).then((_) => serial.close());
    });


    test('Fail when close and not open', (){
      var serial =  new SerialPort(portName);
      serial.close().catchError((error) => expect(error, "${portName} is not open"));
    });

    test('Fail when writeString and not open', (){
      var serial =  new SerialPort(portName);
      serial.writeString("Hello").catchError((error) => expect(error, "${portName} is not open"));
    });

    test('Fail when write and not open', (){
      var serial =  new SerialPort(portName);
      serial.write("Hello".codeUnits).catchError((error) => expect(error, "${portName} is not open"));
    });

 });

}
