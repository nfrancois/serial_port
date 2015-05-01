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

#include <cstring>
#include <stdlib.h>
#include <sstream>
#include <stdio.h>
#include <fcntl.h>
#include "serial_port.h"


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

DART_EXT_DISPATCH_METHOD()
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

DART_EXT_DECLARE_LIB(serial_port, serialPortServicePort)
