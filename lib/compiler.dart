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

library serial_port.compiler;

import 'dart:io';
import 'package:ccompile/ccompile.dart';
import 'package:path/path.dart' as pathos;

const DESCRIPTOR_PATH = "lib/src/serial_port.yaml";

void compile() {
  var basePath = Directory.current.path;
  var projectPath = toAbsolutePath(DESCRIPTOR_PATH, basePath);
  var result = buildProject(projectPath, {
      'start': 'Building project "$projectPath"',
      'success': 'Building complete successfully',
      'error': 'Building complete with some errors'});

  exit(result);
}

int buildProject(projectPath, Map messages) {
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

String toAbsolutePath(String path, String base) {
  if(pathos.isAbsolute(path)) {
    return path;
  }

  path = pathos.join(base, path);
  return pathos.absolute(path);
}
