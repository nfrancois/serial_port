import 'package:grinder/grinder.dart';
import 'dart:io';
import 'package:serial_port/compiler.dart' as compiler;

main(args) => grind(args);

@Task('Clean compiled library')
clean() {
  final libs = new FileSet.fromDir(new Directory("lib/src/"), pattern: "libserial_port*.*");
  libs.files.forEach((File lib) => lib.delete());
}

@Task('Compile extension as native library')
@Depends(clean)
compile() => compiler.compile();

@Task('Run tests')
test() => new PubApp.local('test').run(['test/serial_port_test.dart']);

@Task('Calculate test coverage')
coverage(){
  final token = Platform.environment["SERIAl_PORT_COVERALLS_TOKEN"];
  new PubApp.local('dart_coveralls').run(['report',"--exclude-test-files", "test/serial_port_test.dart", "--token=$token", "--retry 2"]);
}

@DefaultTask('Combine tasks for continous integration')
@Depends('compile', 'test')
make(){
  // Nothing to declare here
}

