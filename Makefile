all: clean build run_test

clean:
	rm -rf lib/src/libserial_port*.*

build:
	dart bin/serial_port.dart compile

run_test:
	dart test/test_serial_port.dart
