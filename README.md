# breakpad-tools
Install and run [Google breakpad](https://chromium.googlesource.com/breakpad/breakpad/) tools using Docker for Android NDK.

## Description
These tools help running Breakpad's tool `dump_syms` on all platforms using Docker.
The scripts can be used to prepare a Zip file for upload to [App Center](https://appcenter.ms) for symbolication.

## Requirements
Docker should be installed and running.

## Usage
1. Prepare the docker container by running the following command.
This can take a few minutes, and will use a lot of disk space (over 5Gb):
```bash
./build.sh
```

2. To extract symbols and prepare a Zip file for upload to App Center:
```bash
./run.sh <path_to_android_ndk_app>/app/build/intermediates/ndkBuild/debug/obj/local/*/*.so
```
Pass all `.so` files as argument to `run.sh` and a file `symbols.zip` will be created automatically.

3. (Bonus) To enter the docker container, which contains all breakpad tools (`dump_syms`, `minidump_stackwalk`, etc...):
```bash
./run.sh
```

## Known problems
System symbols from a running Android device are not extracted by the `breakpad` client.
This means we can't get any meaningful information unless we integrate the symbol extraction in the SDK itself.

