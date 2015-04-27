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

#include "native_helper.h"
#include "include/dart_api.h"
#include "include/dart_native_api.h"

DECLARE_DART_NATIVE_METHOD(native_test_port);

DECLARE_DART_NATIVE_METHOD(native_open);

DECLARE_DART_NATIVE_METHOD(native_close);

DECLARE_DART_NATIVE_METHOD(native_read);

DECLARE_DART_NATIVE_METHOD(native_write);

DECLARE_DART_NATIVE_METHOD(native_write_byte);
