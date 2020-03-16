import "lib/native.dart";

void main() {
  // Example:
  // Open the dynamic library
  final native = Native();

  native.testHello();

  final result = native.testAdd(3, 2);
  print("Add Result: ${result}");

  final say = native.testString("sun", "hello");
  print("Receive say: ${say}");

  //native.testDaemon();
}
