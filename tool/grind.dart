import 'package:grinder/grinder.dart';
import 'dart:io';

main(args) => grind(args);

@Task('Compile extension as native library')
compile() => new PubApp.local('ccompile:ccompile').run(['lib/src/serial_port.yaml']);

@Task('Run tests')
test() => Tests.runCliTests(testFile: "serial_port_test.dart");

@Task('Calculate test coverage')
coverage(){
  final token = Platform.environment["SERIAl_PORT_COVERALLS_TOKEN"];
  new PubApp.local('dart_coveralls').run(['report',"--exclude-test-files", "test/serial_port_test.dart", "--token=$token", "--retry 2"]);
}

/*
TODO currenty fail because ccompile exit
@DefaultTask('Combine tasks for continous integration')
@Depends('compile', 'test')
make(){
  // Nothing to declare here
}
*/

