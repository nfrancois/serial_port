#!/usr/bin/env dart

// Copyright (c) 2014-2015, Nicolas François
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

library serial_port.script;

import 'dart:io';
import 'package:serial_port/cli.dart' deferred as cli;
import 'package:serial_port/compiler.dart' deferred as compiler;

// TODO add a compilation checker

/// Command list tools for serial port api
/// serial_port list
/// serial_port compile
void main(List<String> args) async {
  if(args.length != 1){
    invalidCommand();
  }
  final command = args[0];
  if(command=="compile"){
    await compiler.loadLibrary();
    compiler.compile();
  } else if(command=="list") {
    await cli.loadLibrary();
    cli.list();
  } else {
    invalidCommand();
  }

}

void invalidCommand(){
  stderr.writeln("Invalid command\nUsage:\nserial_port list\nserial_port compile");
  exit(-1);
}
