all: clean build

clean:
	rm -rf libserial_port.*	

build: 
	dart build.dart