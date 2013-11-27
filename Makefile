all: clean build test

clean:
	rm -rf libserial_port.*	

build:
	dart build.dart

test:
	dart test_serial_port.dart 
