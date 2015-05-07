import 'package:grinder/grinder.dart';
import 'dart:io';


main(args) => grind(args);

@Task('Compile extension as native library')
compile() => new PubApp.local('ccompile:ccompile').run(['lib/src/serial_port.yaml']);

@Task('Run tests')
test() => Tests.runCliTests(testFile: "serial_port_test.dart");

@Task('Calculate test coverage')
coverage() =>
  new PubApp.local('dart_coveralls')
            .run(['report', '--exclude-test-files', 'test/test_serial_port.dart', r'--token $SERIAL_PORT_COVERALLS_TOKEN', '--retry 2']);


@Task("Analyze lib source code")
analyse() => Analyzer.analyzeFiles(["lib/serial_port.dart", "lib/cli.dart"], fatalWarnings: true); 


@DefaultTask('Combine tasks for continous integration')
@Depends('compile', 'test', 'analyse')
make(){
  // Nothing to declare here
}


@Task()
fmt() => DartFmt.dryRun("lib") 