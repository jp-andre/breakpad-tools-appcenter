#!/bin/sh

cd `dirname $0`

NDK="android-ndk-r20-linux-x86_64.zip"
URL="https://dl.google.com/android/repository/${NDK}"
SHA="8665fc84a1b1f0d6ab3b5fdd1e30200cc7b9adff"

if [ ! -e "${NDK}" ] ; then
  echo "DOCKER BUILD: Downloading android-ndk, this can take a while..."
  wget ${URL}
fi

echo "${SHA} ${NDK}" | sha1sum -c -

docker build -t breakpad-system .
