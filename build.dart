library ccompile.example.example_build;

import 'dart:io';
import 'package:ccompile/ccompile.dart';
import 'package:path/path.dart' as pathos;

void main(List<String> args) {
  Program.main(args);
}

class Program {
  static void main(List<String> args) {
    var basePath = Directory.current.path;
    var projectPath = toAbsolutePath('serial_port.yaml', basePath);
    var result = Program.buildProject(projectPath, {
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

  static String getRootScriptDirectory() {
    return pathos.dirname(Platform.script);
  }
}
