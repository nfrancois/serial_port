// Copyright (c) 2014-2015, Nicolas François
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


#include <io.h>
#include <fcntl.h>
#include <stdio.h>
#include <windows.h>
#include "include/dart_api.h"
#include "include/dart_native_api.h"
#include "native_helper.h"

DECLARE_DART_NATIVE_METHOD(native_test_port){
  DECLARE_DART_RESULT;
  const char* portname = GET_STRING_ARG(0);

  bool valid = false;
  HANDLE handlePort = CreateFile(portname, GENERIC_READ | GENERIC_WRITE, 0, 0, OPEN_EXISTING,  0, 0);

  if (handlePort != INVALID_HANDLE_VALUE){
    valid = true;
    CloseHandle(handlePort);
  }

  SET_RESULT_BOOL(valid);

  RETURN_DART_RESULT;

}

DECLARE_DART_NATIVE_METHOD(native_open){
  DECLARE_DART_RESULT;
  const char* portname = GET_STRING_ARG(0);
  int baudrate_speed = GET_INT_ARG(1);
  int databits_nb = GET_INT_ARG(2);

  if(baudrate_speed<0){
     SET_ERROR("Invalid baudrate");
  }

  if(databits_nb<5 || databits_nb>8){
     SET_ERROR("Invalid databits");
  }
  
  HANDLE handlePort = CreateFile(portname, GENERIC_READ | GENERIC_WRITE, 0, 0, OPEN_EXISTING, 0, 0);
  
  int tty_fd = _open_osfhandle(reinterpret_cast<intptr_t>(handlePort), _O_TEXT);

  if(tty_fd < 0){
    // TODO errno
    SET_ERROR("Invalid access");
  } else {

  DCB config;
  config.DCBlength = sizeof(config);
  GetCommState(handlePort, &config);
  config.BaudRate = baudrate_speed;
  config.ByteSize = databits_nb;

  /*   
    config.StopBits = ONESTOPBIT;
    config.Parity = PARITY_NONE; 
    config.ByteSize = DATABITS_8;
    config.fDtrControl = 0;
    config.fRtsControl = 0;
  */
    SET_RESULT_INT(tty_fd);
  }
  RETURN_DART_RESULT;
}

DECLARE_DART_NATIVE_METHOD(native_close){
  DECLARE_DART_RESULT;
  int64_t tty_fd = GET_INT_ARG(0);
  
  HANDLE handlePort =  reinterpret_cast<HANDLE>(_get_osfhandle(tty_fd));
  
  bool isClose = CloseHandle(handlePort); 
  
  if(!isClose){
    SET_ERROR("Impossible to close");
    RETURN_DART_RESULT;        
  }

  RETURN_DART_RESULT;
}

DECLARE_DART_NATIVE_METHOD(native_read){
  DECLARE_DART_RESULT;
  
  int64_t tty_fd = GET_INT_ARG(0);
  int buffer_size = (int) GET_INT_ARG(1);
  HANDLE handlePort = reinterpret_cast<HANDLE>(_get_osfhandle(tty_fd));
  DWORD bytes_read = -1;
  uint8_t *data;
  //char *buffer = reinterpret_cast<char*>malloc(buffer_size * sizeof(char));
  //char buffer[255];

  uint8_t* buffer;
  buffer = reinterpret_cast<uint8_t *>(malloc(buffer_size * sizeof(uint8_t)));

  ReadFile(handlePort, buffer, buffer_size, &bytes_read, NULL);
  if(bytes_read){
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

DECLARE_DART_NATIVE_METHOD(native_write){
  DECLARE_DART_RESULT;
  int64_t tty_fd = GET_INT_ARG(0);
  const char* data = GET_STRING_ARG(1);

  HANDLE handlePort =  reinterpret_cast<HANDLE>(_get_osfhandle(tty_fd));
   
  DWORD length = -1;   
  WriteFile(handlePort, data,  strlen(data), &length,NULL);

  if(length <0){
    SET_ERROR("Impossible to write");
    RETURN_DART_RESULT;
  }

  SET_RESULT_INT(length);

  RETURN_DART_RESULT;
}

DECLARE_DART_NATIVE_METHOD(native_write_byte){
  DECLARE_DART_RESULT;
  int64_t tty_fd = GET_INT_ARG(0);
  int8_t byte = GET_INT_ARG(1);

  HANDLE handlePort =  reinterpret_cast<HANDLE>(_get_osfhandle(tty_fd));
  DWORD length = -1;
  WriteFile(handlePort, &byte, sizeof(uint8_t), &length,NULL);

    if(length <0){
      SET_ERROR("Impossible to write");
      RETURN_DART_RESULT;
    }
  SET_RESULT_BOOL(false);

  RETURN_DART_RESULT;
}