#!/usr/bin/env dart

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

library serial_port.script;

import 'dart:io';
import 'package:ccompile/ccompile.dart';
import 'package:path/path.dart' as pathos;
import '../lib/serial_port.dart';

/// serial_port list
/// serial_port compile
void main(List<String> args){
  if(args.length != 1){
    invalidCommand();
  }
  final command = args[0];
  if(command=="compile"){
    Compiler.main('$scriptDirectory/../lib/src/serial_port.yaml');
  } else if(command=="list") {
    SerialPort.avaiblePortNames.then((List<String> results) => print(results.join("\n")));
  } else {
    invalidCommand();
  }

}

void invalidCommand(){
  stderr.writeln("Invalid command\nUsage:\nserial_port list\nserial_port compile");
  exit(-1);
}

class Compiler {
  static void main(yaml_path) {
    var basePath = Directory.current.path;
    var projectPath = toAbsolutePath(yaml_path, basePath);
    var result = Compiler.buildProject(projectPath, {
        'start': 'Building project "$projectPath"',
        'success': 'Building complete successfully',
        'error': 'Building complete with some errors'});

    exit(result);
  }

  static int buildProject(projectPath, Map messages) {
    var workingDirectory = pathos.dirname(projectPath);
    var message = messages['start'];
    if(!message.isEmpty) {
      print(message);
    }

    var builder = new ProjectBuilder();
    var project = builder.loadProject(projectPath);
    var result = builder.buildAndClean(project, workingDirectory);
    if(result.exitCode == 0) {
      var message = messages['success'];
      if(!message.isEmpty) {
        print(message);
      }
    } else {
      var message = messages['error'];
      if(!message.isEmpty) {
        print(message);
      }
    }

    return result.exitCode == 0 ? 0 : 1;
  }

  static String toAbsolutePath(String path, String base) {
    if(pathos.isAbsolute(path)) {
      return path;
    }

    path = pathos.join(base, path);
    return pathos.absolute(path);
  }

}

String get scriptDirectory {
  return pathos.dirname(Platform.script.path);
}
