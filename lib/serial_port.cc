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

Dart_Handle NewDartExceptionWithMessage(const char* library_url,
                                        const char* exception_name,
                                        const char* message);
/*
Called the first time a native function with a given name is called,
 to resolve the Dart name of the native function into a C function pointer.
*/
Dart_NativeFunction ResolveName(Dart_Handle name, int argc);

Dart_Handle HandleError(Dart_Handle handle);

void openSync(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle portname_object = HandleError(Dart_GetNativeArgument(arguments, 0));
  Dart_Handle baudrate_speed_object = HandleError(Dart_GetNativeArgument(arguments, 1));

  // TODO exception with Dart_ThrowException
  //if (!Dart_IsString(portname_object)) return NULL;
  //if (!Dart_IsInteger(baudrate_speed_object)) return NULL;
  const char* portname;
  int64_t baudrate_speed;
  HandleError(Dart_StringToCString(portname_object, &portname));
  HandleError(Dart_IntegerToInt64(baudrate_speed_object, &baudrate_speed));
  
  speed_t baudrate;

  switch(baudrate_speed){
    case 50: baudrate = B50; break;
    case 75: baudrate = B75; break;
    case 110: baudrate = B110; break;
    case 134: baudrate = B134; break;
    case 150: baudrate = B150; break;
    case 200: baudrate = B200; break;
    case 300: baudrate = B300; break;
    case 600: baudrate = B600; break;
    case 1200: baudrate = B1200; break;
    case 1800: baudrate = B1800; break;
    case 2400: baudrate = B2400; break;
    case 4800: baudrate = B4800; break;
    case 9600: baudrate = B9600; break;
    case 19200: baudrate = B19200; break;
    case 38400: baudrate = B38400; break;
    case 57600: baudrate = B57600; break;
    case 115200: baudrate = B115200; break;
    case 230400: baudrate = B230400; break;
    default:
      std::stringstream ss;
      ss << "Unknown baudrate speed=" << baudrate_speed;
      Dart_Handle error = NewDartExceptionWithMessage("dart:core", "ArgumentError", ss.str().c_str());
      if (Dart_IsError(error)) Dart_PropagateError(error);
      Dart_ThrowException(error);  
      return;
  }
 
  struct termios tio;
  memset(&tio, 0, sizeof(tio));
  tio.c_iflag=0;
  tio.c_oflag=0;
  tio.c_cflag=CS8|CREAD|CLOCAL;
  tio.c_lflag=0;
  tio.c_cc[VMIN]=1;
  tio.c_cc[VTIME]=5;

  int tty_fd = open(portname, O_RDWR | O_NONBLOCK); 
  if(tty_fd < 0){
    std::stringstream ss;
    ss << "Impossible to read portname=" << portname;    
    Dart_Handle error = NewDartExceptionWithMessage("dart:io", "FileSystemException", ss.str().c_str());
    if (Dart_IsError(error)) Dart_PropagateError(error);
    Dart_ThrowException(error);
    return;
  }

  cfsetospeed(&tio, baudrate);
  cfsetispeed(&tio, baudrate);
  tcsetattr(tty_fd, TCSANOW, &tio);
   
  Dart_SetReturnValue(arguments, HandleError(Dart_NewInteger(tty_fd)));
  Dart_ExitScope();
}

void closeSync(Dart_NativeArguments arguments){
  int64_t tty_fd;

  Dart_Handle tty_fd_object = HandleError(Dart_GetNativeArgument(arguments, 0));
  HandleError(Dart_IntegerToInt64(tty_fd_object, &tty_fd));

  close(tty_fd);
}

int64_t openAsync(const char* portname, int64_t baudrate_speed){
  // Open serial port
  speed_t baudrate;

  switch(baudrate_speed){
    case 50: baudrate = B50; break;
    case 75: baudrate = B75; break;
    case 110: baudrate = B110; break;
    case 134: baudrate = B134; break;
    case 150: baudrate = B150; break;
    case 200: baudrate = B200; break;
    case 300: baudrate = B300; break;
    case 600: baudrate = B600; break;
    case 1200: baudrate = B1200; break;
    case 1800: baudrate = B1800; break;
    case 2400: baudrate = B2400; break;
    case 4800: baudrate = B4800; break;
    case 9600: baudrate = B9600; break;
    case 19200: baudrate = B19200; break;
    case 38400: baudrate = B38400; break;
    case 57600: baudrate = B57600; break;
    case 115200: baudrate = B115200; break;
    case 230400: baudrate = B230400; break;
  }

  struct termios tio;
  memset(&tio, 0, sizeof(tio));
  tio.c_iflag=0;
  tio.c_oflag=0;
  tio.c_cflag=CS8|CREAD|CLOCAL;
  tio.c_lflag=0;
  tio.c_cc[VMIN]=1;
  tio.c_cc[VTIME]=5;

  int tty_fd = open(portname, O_RDWR | O_NONBLOCK);
  if(tty_fd > 0) {
    cfsetospeed(&tio, baudrate);
    cfsetispeed(&tio, baudrate);
    tcsetattr(tty_fd, TCSANOW, &tio);
  }
  return tty_fd;
}

void closeAsync(int64_t tty_fd){
  close(tty_fd);
}

void wrappedOpenAsyncService(Dart_Port dest_port_id, Dart_CObject* message) {
  Dart_Port reply_port_id = ILLEGAL_PORT;
  if (message->type == Dart_CObject_kArray && message->value.as_array.length == 3) {
    // Use .as_array and .as_int32 to access the data in the Dart_CObject.
    Dart_CObject* param0 = message->value.as_array.values[0];
    Dart_CObject* param1 = message->value.as_array.values[1];
    Dart_CObject* param2 = message->value.as_array.values[2];
    if (param0->type == Dart_CObject_kString && param1->type == Dart_CObject_kInt32 && param2->type == Dart_CObject_kSendPort) {
      const char* portname = param0->value.as_string;
      int64_t baudrate_speed = param1->value.as_int64;
      reply_port_id = param2->value.as_send_port;

      int64_t tty_fd = openAsync(portname, baudrate_speed);

      Dart_CObject result;
      result.type = Dart_CObject_kInt64;
      result.value.as_int64 = tty_fd;
      Dart_PostCObject(reply_port_id, &result);
      return;
    }
  }
  Dart_CObject result;
  result.type = Dart_CObject_kNull;
  Dart_PostCObject(reply_port_id, &result);
}

// TODO maybe check type
void wrappedSerialPortServicePort(Dart_Port send_port_id, Dart_CObject* message){
 Dart_Port reply_port_id = message->value.as_array.values[0]->value.as_send_port;
 Dart_CObject result;
 int argc = message->value.as_array.length - 1;                        \
 Dart_CObject** argv = message->value.as_array.values + 1;
 char *name = argv[0]->value.as_string;
 argv++;
 argc--;
 // TODO replace by switch
 if (strcmp("open", name) == 0) {
   //Dart_CObject* param0 = message->value.as_array.values[0];
   //Dart_CObject* param1 = message->value.as_array.values[1];
   const char* portname = argv[0]->value.as_string;
   int64_t baudrate_speed = argv[1]->value.as_int64;

   int64_t tty_fd = openAsync(portname, baudrate_speed);

   result.type = Dart_CObject_kInt64;
   result.value.as_int64 = tty_fd;
 } else  if (strcmp("close", name) == 0) {
   int64_t tty_fd = argv[0]->value.as_int64;

   close(tty_fd);

   result.type = Dart_CObject_kBool;
   result.value.as_bool = true;
 }
 Dart_PostCObject(reply_port_id, &result);
}

void serialPortServicePort(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_SetReturnValue(arguments, Dart_Null());
  Dart_Port service_port = Dart_NewNativePort("SerialPortServicePort", wrappedSerialPortServicePort, true);
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

  if (strcmp("openSync", cname) == 0) result = openSync;
  if (strcmp("closeSync", cname) == 0) result = closeSync;
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
