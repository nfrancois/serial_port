#!/bin/sh

COVERALLS_PATH=~/.pub-cache/bin/dart_coveralls

if [ ! -d ~/.pub-cache/bin ] || [ ! -f  ~/.pub-cache/bin/dart_coveralls ]
then
    echo "coveralls is not installed"
    pub global activate dart_coveralls
fi

#export PATH="$PATH":"~/.pub-cache/bin"

~/.pub-cache/bin/dart_coveralls report --exclude-test-files  test/test_serial_port.dart --token=$SERIAl_PORT_COVERALLS_TOKEN