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

int64_t openAsync(const char* portname, int64_t baudrate_speed){
  // Open serial port
  speed_t baudrate;

  switch(baudrate_speed){
    // TODO baudrate 0 ? B0
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
    // TODO if LINUX case 4000000: baudrate = B4000000; break;

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

int sendAsync(int64_t tty_fd, const char* data){
  return write(tty_fd, data, strlen(data));
}

void startReading(Dart_Port reply_port_id, int64_t tty_fd, int64_t buffer_size){
  // TODO buffer size
  //int buffer_size = 1;
  Dart_CObject result;
  //result.type = Dart_CObject_kArray;
  result.type = Dart_CObject_kString;
  fd_set readfs;
  char buffer[buffer_size];
  while (1){
    FD_ZERO(&readfs);
    FD_SET(tty_fd, &readfs);
    select(tty_fd+1, &readfs, NULL, NULL, NULL);
    if(read(tty_fd,&buffer,buffer_size)>0){
      // Send data via open port
      //Dart_CObject *bufferPtr[buffer_size];
      //bufferPtr[0] = &buffer[1];
      //result.type = Dart_CObject_kArray;
      //result.value.as_array.length = buffer_size;
      //result.value.as_array.values = buffer;
      result.value.as_string = buffer;
      Dart_PostCObject(reply_port_id, &result);
    }
  }
}


// TODO maybe check type
//   result.type = Dart_CObject_kNull;
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

   closeAsync(tty_fd);

   result.type = Dart_CObject_kBool;
   result.value.as_bool = true;
 } else  if (strcmp("send", name) == 0) {
   int64_t tty_fd = argv[0]->value.as_int64;
   const char* data = argv[1]->value.as_string;

   int value = sendAsync(tty_fd, data);

   result.type = Dart_CObject_kInt64;
   result.value.as_int64 = value;
 } else  if (strcmp("read", name) == 0) {
   int64_t tty_fd = argv[0]->value.as_int64;
   // TODO arg buffer_size
   int64_t buffer_size = 1;

    startReading(reply_port_id, tty_fd, buffer_size);
 } else {
    // TODO
    printf("ERROR :Unknow function\n");
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
