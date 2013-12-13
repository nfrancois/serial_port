// Licence 2

#include <cstring>
#include <stdlib.h>
#include <sstream>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include "include/dart_api.h"
#include "include/dart_native_api.h"


#define DECLARE_DART_RESULT                         \
 Dart_CObject result;                               \
 Dart_CObject resultDetail[2];                      \
 Dart_CObject *resultDetailPtr[2];                  \
 resultDetail[0].type = Dart_CObject_kNull;         \
 resultDetailPtr[0] = &resultDetail[0];             \
 resultDetail[1].type = Dart_CObject_kNull;         \
 resultDetailPtr[1] = &resultDetail[1];             \
 result.type = Dart_CObject_kArray;                 \
 result.value.as_array.length = 2;                  \
 result.value.as_array.values = resultDetailPtr;    \
 Dart_CObject* current;                             \
 current = resultDetail;                            \

// TODO add return
#define RETURN_DART_RESULT                          \
  Dart_PostCObject(reply_port_id, &result);         \
  return;

// TODO add return
#define DART_NATIVE_METHOD                          \
  Dart_PostCObject(reply_port_id, &result);         \
  return;  


#define SET_ERROR(_str)                             \
  current[0].type = Dart_CObject_kString;           \
  current[0].value.as_string = (char *)(_str);

#define SET_RESULT(_typeName, _asType, _value)      \
  current[1].type = _typeName;                      \
  current[1].value._asType = (_value);

#define SET_RESULT_INT(_value)                      \
  SET_RESULT(Dart_CObject_kInt32, as_int32, _value);


#define SET_RESULT_BOOL(_value)                     \
  SET_RESULT(Dart_CObject_kBool, as_bool, _value);    


Dart_Handle NewDartExceptionWithMessage(const char* library_url,
                                        const char* exception_name,
                                        const char* message);
/*
Called the first time a native function with a given name is called,
 to resolve the Dart name of the native function into a C function pointer.
*/
Dart_NativeFunction ResolveName(Dart_Handle name, int argc);

Dart_Handle HandleError(Dart_Handle handle);


enum METHOD_CODE {
  OPEN = 1,
  CLOSE = 2,
  READ = 3,
  WRITE = 4
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

int sendAsync(int64_t tty_fd, const char* data){
  return write(tty_fd, data, strlen(data));
}

void DART_invalid_method(Dart_Port reply_port_id){
  DECLARE_DART_RESULT
  SET_ERROR("Unknow method");
  RETURN_DART_RESULT;
}


void DART_open(Dart_Port reply_port_id, Dart_CObject** argv){
  DECLARE_DART_RESULT;
  // TODO : macro validation nbr arg
  // TODO : get args macro
  const char* portname = argv[0]->value.as_string;
  int64_t baudrate_speed = argv[1]->value.as_int64;
  int64_t databits_nb = argv[2]->value.as_int64;
  
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

void DART_close(Dart_Port reply_port_id, Dart_CObject** argv){
  DECLARE_DART_RESULT;  
  int64_t tty_fd = argv[0]->value.as_int64;

  int value = close(tty_fd);
  if(value <0){
    SET_ERROR("Impossible to close");
    RETURN_DART_RESULT;    
  }
  SET_RESULT_BOOL(true);  
  RETURN_DART_RESULT;  
}

// TODO maybe check type
void dispatch_method_call(Dart_Port send_port_id, Dart_CObject* message){
  Dart_Port reply_port_id = message->value.as_array.values[0]->value.as_send_port;

  int argc = message->value.as_array.length - 1;
  Dart_CObject** argv = message->value.as_array.values + 1;
  int method_code = (int) argv[0]->value.as_int64;
  argv++;
  argc--;

  // TODO check args nb
  switch(method_code){
    case OPEN : 
      DART_open(reply_port_id, argv);
      break;
    case CLOSE:
      DART_close(reply_port_id, argv);
    default:
     DART_invalid_method(reply_port_id);
     break;
  }
  /*
   else if(method_code == WRITE) {
   int64_t tty_fd = argv[0]->value.as_int64;

   // TODO int[]
   const char* data = argv[1]->value.as_string;

   int value = sendAsync(tty_fd, data);

   Dart_CObject dart_result;
   dart_result.type = Dart_CObject_kInt64;
   dart_result.value.as_int64 = value;
   result.value.as_array.values[0] = &dart_result;

  } else if(method_code == READ) {
   int64_t tty_fd = argv[0]->value.as_int64;
   int buffer_size = (int) argv[1]->value.as_int64;
   int8_t buffer[buffer_size];
   fd_set readfs;
   FD_ZERO(&readfs);
   FD_SET(tty_fd, &readfs);
   select(tty_fd+1, &readfs, NULL, NULL, NULL);
   int n =  read(tty_fd, &buffer, sizeof(buffer));
   if(n > 0){

     result.type = Dart_CObject_kArray;
     result.value.as_array.length = n;

     for(int i=0; i<n; i++){
       Dart_CObject* byte = (Dart_CObject*) malloc(sizeof(Dart_CObject_kInt32));
       byte->type = Dart_CObject_kInt32;
       byte->value.as_int32 = buffer[i];
       result.value.as_array.values[i] = byte;
     }

    } else {
      result.type = Dart_CObject_kNull;
    }
  }
   else {

  }
*/

} 

void serialPortServicePort(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_SetReturnValue(arguments, Dart_Null());
  Dart_Port service_port = Dart_NewNativePort("SerialPortServicePort", dispatch_method_call, true);
  if (service_port != ILLEGAL_PORT) {
    Dart_Handle send_port = HandleError(Dart_NewSendPort(service_port));
    Dart_SetReturnValue(arguments, send_port);
  }
  Dart_ExitScope();
}


DART_EXPORT Dart_Handle serial_port_Init(Dart_Handle parent_library) {
  if (Dart_IsError(parent_library)) { return parent_library; }

  Dart_Handle result_code = Dart_SetNativeResolver(parent_library, ResolveName);
  if (Dart_IsError(result_code)) return result_code;


  return Dart_Null();
}

Dart_NativeFunction ResolveName(Dart_Handle name, int argc) {
  // If we fail, we return NULL, and Dart throws an exception.
  if (!Dart_IsString(name)) return NULL;
  Dart_NativeFunction result = NULL;
  Dart_EnterScope();
  const char* cname;
  HandleError(Dart_StringToCString(name, &cname));

  if (strcmp("serialPortServicePort", cname) == 0) result = serialPortServicePort;

  Dart_ExitScope();
  return result;
}

Dart_Handle HandleError(Dart_Handle handle) {
  if (Dart_IsError(handle)) Dart_PropagateError(handle);
  return handle;
}

Dart_Handle NewDartExceptionWithMessage(const char* library_url,
                                        const char* exception_name,
                                        const char* message) {
  // Create a Dart Exception object with a message.
  Dart_Handle type = Dart_GetType(Dart_LookupLibrary(
      Dart_NewStringFromCString(library_url)),
      Dart_NewStringFromCString(exception_name), 0, NULL);

  if (Dart_IsError(type)) {
    Dart_PropagateError(type);
  }
  if (message != NULL) {
    Dart_Handle args[1];
    args[0] = Dart_NewStringFromCString(message);
    if (Dart_IsError(args[0])) {
      Dart_PropagateError(args[0]);
    }
    return Dart_New(type, Dart_Null(), 1, args);
  } else {
    return Dart_New(type, Dart_Null(), 0, NULL);
  }

}
