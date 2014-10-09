// Copyright (c) 2014, Nicolas François
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

#include <cstring>
#include <stdlib.h>
#include <sstream>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include "include/dart_api.h"
#include "include/dart_native_api.h"
#include "native_helper.h"

Dart_NativeFunction ResolveName(Dart_Handle name, int argc, bool *auto_setup_scope);

Dart_Handle HandleError(Dart_Handle handle);


enum METHOD_CODE {
  TEST_PORT = 0,
  OPEN = 1,
  CLOSE = 2,
  READ = 3,
  WRITE = 4,
  WRITE_BYTE = 5 // TODO delete with the real write by bytes implementation.
};

int selectBaudrate(int baudrate_speed){
  switch(baudrate_speed){
    // TODO baudrate 0 ? B0
    case 50: return B50; break;
    case 75: return B75; break;
    case 110: return B110; break;
    case 134: return B134; break;
    case 150: return B150; break;
    case 200: return B200; break;
    case 300: return B300; break;
    case 600: return B600; break;
    case 1200: return B1200; break;
    case 1800: return B1800; break;
    case 2400: return B2400; break;
    case 4800: return B4800; break;
    case 9600: return B9600; break;
    case 19200: return B19200; break;
    case 38400: return B38400; break;
    case 57600: return B57600; break;
    case 115200: return B115200; break;
    case 230400: return B230400; break;
    #ifdef B460800
    case 460800: return B460800;break;
    #endif
    #ifdef B500000
    case 500000: return B500000; break;
    #endif
    #ifdef B576000
    case 576000: return B576000; break;
    #endif
    #ifdef B921600
    case 921600: return B921600; break;
    #endif
    #ifdef B1000000
    case 1000000: return B1000000; break;
    #endif
    #ifdef B1152000
    case 1152000: return B1152000; break;
    #endif
    #ifdef B1500000
    case 1500000: return B1500000; break;
    #endif
    #ifdef B2000000
    case 2000000: return B2000000; break;
    #endif
    #ifdef B2500000
    case 2500000: return B2500000; break;
    #endif
    #ifdef B3000000
    case 3000000: return B3000000; break;
    #endif
    #ifdef B3500000
    case 3500000: return B3500000; break;
    #endif
    #ifdef B4000000
    case 4000000: return B4000000; break;
    #endif
    #ifdef B7200
    case 7200: return B7200; break;
    #endif
    #ifdef B14400
    case 14400: return B14400; break;
    #endif
    #ifdef B28800
    case 28800: return B28800; break;
    #endif
    #ifdef B76800
    case 76800: return B76800; break;
    #endif
    default: return -1;
  }
}

int selectDataBits(int dataBits) {
  switch (dataBits) {
    case 5: return CS5;
    case 6: return CS6;
    case 7: return CS7;
    case 8: return CS8;
    default: return -1;
  }
}

DECLARE_DART_NATIVE_METHOD(native_test_port){
  DECLARE_DART_RESULT;
  const char* portname = GET_STRING_ARG(0);

  bool valid = false;
  int tty_fd = open(portname, O_RDONLY|O_NONBLOCK);

  if (tty_fd>0){
    valid = true;
  	close(tty_fd);
  }
  SET_RESULT_BOOL(valid);

  RETURN_DART_RESULT;

}

DECLARE_DART_NATIVE_METHOD(native_open){
  DECLARE_DART_RESULT;
  // TODO : macro validation nbr arg
  // TODO : get args macro
  const char* portname = GET_STRING_ARG(0);
  int64_t baudrate_speed = GET_INT_ARG(1);
  int64_t databits_nb = GET_INT_ARG(2);

  int baudrate = selectBaudrate(baudrate_speed);
  if(baudrate == -1){
     SET_ERROR("Invalid baudrate");
     RETURN_DART_RESULT;
  }

  int databits = selectDataBits(databits_nb);
  if(databits == -1) {
     SET_ERROR("Invalid databits");
     RETURN_DART_RESULT;
  }

  int tty_fd = open(portname, O_RDWR | O_NOCTTY | O_NONBLOCK);

  if(tty_fd < 0){
    // TODO errno
    SET_ERROR("Invalid access");
  }
  struct termios tio;
  memset(&tio, 0, sizeof(tio));
  tio.c_iflag=0;
  tio.c_oflag= IGNPAR;
  tio.c_cflag= databits | CREAD | CLOCAL | HUPCL;
  tio.c_lflag=0;
  tio.c_cc[VMIN]=1;
  tio.c_cc[VTIME]=0;
  cfsetospeed(&tio, baudrate);
  cfsetispeed(&tio, baudrate);
  tcflush(tty_fd, TCIFLUSH);
  tcsetattr(tty_fd, TCSANOW, &tio);
  SET_RESULT_INT(tty_fd);

  RETURN_DART_RESULT;
}

DECLARE_DART_NATIVE_METHOD(native_close){
  DECLARE_DART_RESULT;
  int64_t tty_fd = GET_INT_ARG(0);

  int value = close(tty_fd);
  if(value <0){
    // TODO errno
    SET_ERROR("Impossible to close");
    RETURN_DART_RESULT;
  }
  SET_RESULT_BOOL(true);

  RETURN_DART_RESULT;
}

DECLARE_DART_NATIVE_METHOD(native_write){
  DECLARE_DART_RESULT;

  int64_t tty_fd = GET_INT_ARG(0);

  // TODO int[]
  const char* data = GET_STRING_ARG(1);

  int value = write(tty_fd, data, strlen(data));
  if(value <0){
    // TODO errno
    SET_ERROR("Impossible to close");
    RETURN_DART_RESULT;
  }
  SET_RESULT_INT(value);

  RETURN_DART_RESULT;
}

DECLARE_DART_NATIVE_METHOD(native_write_byte){
  DECLARE_DART_RESULT;
  int64_t tty_fd = GET_INT_ARG(0);
  int8_t byte = GET_INT_ARG(1);

  int value = write(tty_fd, &byte, sizeof(int8_t));
  if(value <0){
    // TODO errno
    SET_ERROR("Impossible to close");
    RETURN_DART_RESULT;
  }
  SET_RESULT_INT(value);

  RETURN_DART_RESULT;
}

DECLARE_DART_NATIVE_METHOD(native_read){
  DECLARE_DART_RESULT;

  int64_t tty_fd = GET_INT_ARG(0);

  int buffer_size = (int) GET_INT_ARG(1);

  uint8_t *buffer, *data;
  int bytes_read;
  //int8_t buffer[buffer_size];
  // TODO when concurrency (wait for read)
  //fd_set readfs;
  //FD_ZERO(&readfs);
  //FD_SET(tty_fd, &readfs);
  //select(tty_fd+1, &readfs, NULL, NULL, NULL);
  buffer = reinterpret_cast<uint8_t *>(malloc(buffer_size * sizeof(uint8_t)));
  bytes_read = read(static_cast<int>(tty_fd), buffer, static_cast<int>(buffer_size));

  //bytes_read =  read(tty_fd, &buffer, sizeof(buffer));
  if(bytes_read > 0){
    // TODO SET_INT_ARRAY_RESULT;
    data = reinterpret_cast<uint8_t *>(malloc(bytes_read * sizeof(uint8_t)));
    memcpy(data, buffer, bytes_read);
    free(buffer);

    current[1].type = Dart_CObject_kTypedData;
    current[1].value.as_typed_data.type = Dart_TypedData_kUint8;
    current[1].value.as_typed_data.values = data;
    current[1].value.as_typed_data.length = bytes_read;

  }
  RETURN_DART_RESULT;
}

DISPATCH_METHOD()
  SWITCH_METHOD_CODE {
    case TEST_PORT:
      CALL_DART_NATIVE_METHOD(native_test_port);
      break;
    case OPEN :
      CALL_DART_NATIVE_METHOD(native_open);
      break;
    case CLOSE:
      CALL_DART_NATIVE_METHOD(native_close);
      break;
    case READ:
      CALL_DART_NATIVE_METHOD(native_read);
      break;
    case WRITE:
      CALL_DART_NATIVE_METHOD(native_write);
      break;
    case WRITE_BYTE:
      CALL_DART_NATIVE_METHOD(native_write_byte);
      break;
    default:
     UNKNOW_METHOD_CALL;
     break;
  }
}

DECLARE_LIB(serial_port, serialPortServicePort)
