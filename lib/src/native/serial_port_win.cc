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

int selectBaudrate(int baudrate_speed){
  if(baudrate_speed<0){
    return -1;
  }
  return baudrate_speed;
}

int selectDataBits(int databits_nb) {
  if(databits_nb<5 || databits_nb>8){
     return -1;
  }
  return databits_nb;
}

bool testSerialPort(const char* port_name){
  HANDLE handlePort = CreateFile(port_name, GENERIC_READ | GENERIC_WRITE, 0, 0, OPEN_EXISTING,  0, 0);
  if (handlePort != INVALID_HANDLE_VALUE){
    CloseHandle(handlePort);
    return true;
  }
  return false;
}

int openSerialPort(const char* port_name, int baudrate, int databits){
  HANDLE handlePort = CreateFile(port_name, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);
  int tty_fd = _open_osfhandle(reinterpret_cast<intptr_t>(handlePort), _O_TEXT);
  if(tty_fd > 0){
    DCB config;
    config.DCBlength = sizeof(config);
    config.BaudRate = baudrate;
    config.ByteSize = databits;
    SetCommState(handlePort, &config);
    /*
    config.StopBits = ONESTOPBIT;
    config.Parity = PARITY_NONE;
    config.fDtrControl = 0;
    config.fRtsControl = 0;
    */
  }
  return tty_fd;
}

bool closeSerialPort(int tty_fd){
  HANDLE handlePort =  reinterpret_cast<HANDLE>(_get_osfhandle(tty_fd));
  return CloseHandle(handlePort);
}

int readFromSerialPort(int tty_fd, uint8_t* data, int buffer_size){
  DWORD bytes_read = -1;
  HANDLE handlePort =  reinterpret_cast<HANDLE>(_get_osfhandle(tty_fd));
  ReadFile(handlePort, data, buffer_size, &bytes_read, NULL);
  return bytes_read;
}

int writeToSerialPort(int tty_fd, const char* data){
  HANDLE handlePort =  reinterpret_cast<HANDLE>(_get_osfhandle(tty_fd));
  DWORD length = -1;
  WriteFile(handlePort, data,  strlen(data), &length, NULL);
  return length;
}

int writeToSerialPort(int tty_fd, uint8_t byte){
  HANDLE handlePort =  reinterpret_cast<HANDLE>(_get_osfhandle(tty_fd));
  DWORD length = -1;
  WriteFile(handlePort, &byte, sizeof(uint8_t), &length,NULL);
  return length;
}
