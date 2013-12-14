// TODO a message header

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

#define RETURN_DART_RESULT                          \
  Dart_PostCObject(reply_port_id, &result);         \
  return;

#define DECLARE_DART_NATIVE_METHOD(method_name)                    \
  void method_name(Dart_Port reply_port_id, Dart_CObject** argv)   \


#define CALL_DART_NATIVE_METHOD(method_name)        \
  method_name(reply_port_id, argv);  


#define SET_ERROR(_str)                             \
  current[0].type = Dart_CObject_kString;           \
  current[0].value.as_string = (char *)(_str);

#define SET_RESULT(_typeName, _asType, _value)      \
  current[1].type = _typeName;                      \
  current[1].value._asType = (_value);

#define SET_RESULT_INT(_value)                      \
  SET_RESULT(Dart_CObject_kInt64, as_int64, _value);


#define SET_RESULT_BOOL(_value)                     \
  SET_RESULT(Dart_CObject_kBool, as_bool, _value);    

// TODO check type
#define GET_INT_ARG(_position)                                         \
  argv[_position]->value.as_int64;                                     \

// TODO check type
#define GET_STRING_ARG(_position)                                      \
  argv[_position]->value.as_string;   

#define UNKNOW_METHOD_CALL    \
  DECLARE_DART_RESULT         \
  SET_ERROR("Unknow method"); \
  RETURN_DART_RESULT;         


#define DISPATCH_METHOD(lib_name)                                                     \
void wrap_dispatch_methods(Dart_Port send_port_id, Dart_CObject* message){            \
  Dart_Port reply_port_id = message->value.as_array.values[0]->value.as_send_port;     \
  int argc = message->value.as_array.length - 1;                                       \
  Dart_CObject** argv = message->value.as_array.values + 1;                            \
  int method_code = (int) argv[0]->value.as_int64;                                     \
  argv++;                                                                              \
  argc--;                                                                              

#define SWITCH_METHOD_CODE                                                             \
  switch(method_code)


#define DECLARE_LIB(lib_name, service_port_name)                                       \
DART_EXPORT Dart_Handle lib_name##_Init(Dart_Handle parent_library) {                  \
  if (Dart_IsError(parent_library)) { return parent_library; }                         \
  Dart_Handle result_code = Dart_SetNativeResolver(parent_library, ResolveName);       \
    if (Dart_IsError(result_code)) return result_code;                                 \
    return Dart_Null();                                                                \
}                                                                                      \
void lib_name##_ServicePort(Dart_NativeArguments arguments) {                           \
  Dart_EnterScope();                                                                   \
  Dart_SetReturnValue(arguments, Dart_Null());                                         \
  Dart_Port service_port = Dart_NewNativePort(#lib_name"_ServicePort", wrap_dispatch_methods, true); \
  if (service_port != ILLEGAL_PORT) {                                                  \
    Dart_Handle send_port = HandleError(Dart_NewSendPort(service_port));               \
    Dart_SetReturnValue(arguments, send_port);                                         \
  }                                                                                    \
  Dart_ExitScope();                                                                    \
}                                                                                      \
Dart_NativeFunction ResolveName(Dart_Handle name, int argc) {                          \
  if (!Dart_IsString(name)) return NULL;                                               \
  Dart_NativeFunction result = NULL;                                                   \
  Dart_EnterScope();                                                                   \
  const char* cname;                                                                   \
  HandleError(Dart_StringToCString(name, &cname));                                     \
  if (strcmp(#service_port_name, cname) == 0) result = lib_name##_ServicePort;    \
  Dart_ExitScope();                                                                    \
  return result;                                                                       \
}                                                                                      \
Dart_Handle HandleError(Dart_Handle handle) {                                          \
  if (Dart_IsError(handle)) Dart_PropagateError(handle);                               \
  return handle;                                                                       \
}                                                                                      \

