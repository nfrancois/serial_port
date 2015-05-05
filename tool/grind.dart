import 'package:grinder/grinder.dart';

main(args) => grind(args);

@Task('Compile extension as native library')
compile() => new PubApp.local('ccompile:ccompile').run(['lib/src/serial_port.yaml']);

@Task('Run tests')
test() => Tests.runCliTests(testFile: "serial_port_test.dart");

@Task('Calculate test coverage')
coverage() =>
  new PubApp.local('dart_coveralls')
            .run(['report', '--exclude-test-files', 'test/test_serial_port.dart', r'--token $SERIAL_PORT_COVERALLS_TOKEN', '--retry 2']);

/*
TODO currenty fail because ccompile exit
@DefaultTask('Combine tasks for continous integration')
@Depends('compile', 'test')
make(){
  // Nothing to declare here
}
*/

