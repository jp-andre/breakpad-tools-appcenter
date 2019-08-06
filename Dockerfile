FROM debian

WORKDIR /work
RUN apt-get update && apt-get install -y git python wget zip build-essential
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
RUN mkdir breakpad && cd breakpad && /work/depot_tools/fetch breakpad
RUN cd breakpad/src && ./configure && make -j4 && make install