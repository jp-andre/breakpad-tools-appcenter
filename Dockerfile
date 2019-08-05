FROM debian AS build-stage

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y htop vim git python curl wget sudo zip build-essential

RUN useradd -ms /bin/bash breakpad
RUN echo "breakpad ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER breakpad
WORKDIR /home/breakpad

ADD install_breakpad.sh ./
RUN ./install_breakpad.sh

# We need this file at build time, so can't just mount it. :(
# https://dl.google.com/android/repository/android-ndk-r20-linux-x86_64.zip
ADD android-ndk-r20-linux-x86_64.zip ./
RUN unzip android-ndk-r20-linux-x86_64.zip

RUN mkdir -p breakpad/build
WORKDIR /home/breakpad/breakpad/build

ENV ANDROID_NDK_ROOT=/home/breakpad/android-ndk-r20/toolchains/llvm/prebuilt/linux-x86_64/
#RUN ../src/configure --host=arm-linux-android-eabi --prefix=/home/breakpad/ndk-arm
RUN ../src/configure
RUN make -j4

FROM build-stage

