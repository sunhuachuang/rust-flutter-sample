import 'dart:ffi';
import 'dart:io';
import 'dart:io' show Platform;
import 'dart:isolate';

import 'package:ffi/ffi.dart';

String _platformPath(String name, {String path}) {
  if (path == null) path = "./native/";
  //if (path == null) path = "";
  if (Platform.isAndroid) return path + "android_" + name + ".so";
  if (Platform.isLinux) return path + "linux_" + name + ".so";
  if (Platform.isMacOS) return path + "mac_" + name + ".dylib";
  if (Platform.isWindows) return path + "windows_" + name + ".dll";
  print(path);
  throw Exception("Platform not implemented");
}

DynamicLibrary dlopenPlatformSpecific(String name, {String path}) {
  String fullPath = _platformPath(name, path: path);
  return DynamicLibrary.open(fullPath);
}

typedef ffi_test_hello = Void Function();
typedef dart_test_hello = void Function();

typedef ffi_test_add = Int32 Function(Int32 a, Int32 b);
typedef dart_test_add = int Function(int a, int b);

typedef ffi_test_string = Pointer<Utf8> Function(Pointer<Utf8> name, Pointer<Utf8> say);
typedef dart_test_string = Pointer<Utf8> Function(Pointer<Utf8> name, Pointer<Utf8> say);

typedef ffi_test_daemon = Void Function();
typedef dart_test_daemon = void Function();

class Native {
  final DynamicLibrary dylib = dlopenPlatformSpecific("rust_demo");

  void testHello() {
    dylib.lookup<NativeFunction<ffi_test_hello>>('test_hello').asFunction<dart_test_hello>()();
  }

  int testAdd(int a, int b) {
    final fn = dylib.lookup<NativeFunction<ffi_test_add>>('test_add').asFunction<dart_test_add>();
    return fn(a, b);
  }

  String testString(String name, String say) {
    final newUserFunc =
    dylib.lookup<NativeFunction<ffi_test_string>>('test_string').asFunction<dart_test_string>();
    final wordsPointer = newUserFunc(Utf8.toUtf8(name), Utf8.toUtf8(say));
    return Utf8.fromUtf8(wordsPointer);
  }

  void testDaemon() async {
    ReceivePort isolateToMainStream = ReceivePort();
    Isolate myIsolateInstance = await Isolate.spawn(daemonProcess, isolateToMainStream.sendPort);
  }

  static void daemonProcess(SendPort isolateToMainStream) {
    final DynamicLibrary dylib = dlopenPlatformSpecific("rust_demo"); // static function
    final fn = dylib.lookup<NativeFunction<ffi_test_daemon>>('test_listen').asFunction<dart_test_daemon>();
    fn();
  }
}
