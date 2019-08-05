#!/bin/sh

set -e

TIMESTAMP=`TZ=UTC date "+%Y-%m-%dT%H-%M-%SZ"`
SYM_DIR=${SYM_DIR:-"/tmp/symbols/${TIMESTAMP}"}

if [ "$1" = "" ] ; then
  exec docker run -it breakpad
  exit $?
fi

for SO_FILE in $@ ; do
  SO_DIR=`dirname ${SO_FILE}`
  SO_NAME=`basename ${SO_FILE}`
  SYM_FILE="${SO_DIR}/${SO_NAME}.sym"
  mkdir -p "${SYM_DIR}"

  docker run --name breakpad --rm -i -v ${SO_DIR}:/home/breakpad/mnt breakpad bash -c "/usr/local/bin/dump_syms /home/breakpad/mnt/${SO_NAME} > /home/breakpad/mnt/${SO_NAME}.sym"

  cp -f "${SYM_FILE}" "${SYM_DIR}"
done

if [ "${SYSTEM_SYMBOLS}" = "1" ] ; then
  DOCKER_ID=`docker ps -q -a -l`
  docker cp ${DOCKER_ID}:/home/breakpad/symbols ${SYM_DIR}
fi

./make_symbols_zip.sh ${SYM_DIR}

