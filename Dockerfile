FROM debian AS prep-stage

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y htop vim git python curl wget sudo zip build-essential

RUN useradd -ms /bin/bash breakpad
RUN echo "breakpad ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER breakpad
WORKDIR /home/breakpad


FROM prep-stage AS build-stage

ADD install_breakpad.sh extract_system_symbols.sh ./
RUN ./install_breakpad.sh

# We need this file at build time, so can't just mount it. :(
# https://dl.google.com/android/repository/android-ndk-r20-linux-x86_64.zip
ADD android-ndk-r20-linux-x86_64.zip ./
RUN unzip android-ndk-r20-linux-x86_64.zip

RUN mkdir -p breakpad/build
WORKDIR /home/breakpad/breakpad/build

ENV ANDROID_NDK_ROOT=/home/breakpad/android-ndk-r20/toolchains/llvm/prebuilt/linux-x86_64/
RUN ../src/configure
RUN make -j4
RUN sudo make install


# This step extracts system symbols for all versions supported by the installed NDK.
# But these files don't match the ones running on actual devices. So we need to extract
# the symbols from the devices themselves. This includes emulators.
#FROM build-stage AS symbols-stage
#WORKDIR /home/breakpad
#RUN ./extract_system_symbols.sh


FROM build-stage AS final-stage

WORKDIR /home/breakpad
#COPY --from=build-stage /home/breakpad/symbols /home/breakpad/symbols
COPY --from=build-stage /usr/local /usr/local

