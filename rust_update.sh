# into rust code dir.
cd rust_code

# build self machine
cargo build --release

# cp dylib to directory.
cp ./target/release/librust_demo.so ../native/linux_rust_demo.so

# from: target/universal/release/libmy_app_base.a
# to: ios/

# from: target/aarch64-linux-android/release/libmy_app_base.so
# to: android/app/src/main/jniLibs/arm64-v8a/

# from: target/armv7-linux-androideabi/release/libmy_app_base.so
# to: android/app/src/main/jniLibs/armeabi-v7a/

# from: target/i686-linux-android/release/libmy_app_base.so
# to: android/app/src/main/jniLibs/x86/

# back to main dir.
cd ../


