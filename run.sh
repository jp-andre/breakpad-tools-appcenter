#!/bin/sh

set -e

if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
  echo "Extract symbols and prepare symbols.zip file ready to upload to App Center."
  echo "Usage: $0 [-q] [*.so]"
  exit 0
fi

if [ "$1" = "-q" ] ; then
  QUIET=1
  shift
fi

if [ "$1" = "" ] ; then
  [ -z "$QUIET" ] && echo "Entering docker container..." 
  exec docker run -it breakpad
  exit $?
fi

[ -z "$QUIET" ] && echo "Extracting symbols..."
SYM_DIR=${SYM_DIR:-`mktemp -d`}

for SO_FILE in $@ ; do
  SO_DIR=`dirname ${SO_FILE}`
  SO_NAME=`basename ${SO_FILE}`
  SYM_FILE="${SO_DIR}/${SO_NAME}.sym"
  mkdir -p "${SYM_DIR}"

  docker run --name breakpad --rm -i -v ${SO_DIR}:/work/mnt breakpad bash -c "/usr/local/bin/dump_syms /work/mnt/${SO_NAME} > /work/mnt/${SO_NAME}.sym"

  cp -f "${SYM_FILE}" "${SYM_DIR}"
done

[ -z "$QUIET" ] && echo "Preparing zip archive..."
for SYM_FILE in `find ${SYM_DIR} -type f` ; do
  SO_ID=`head -n1 "${SYM_FILE}" |cut -d ' ' -f 4`
  SO_NAME=`head -n1 "${SYM_FILE}" |cut -d ' ' -f 5`
  mkdir -p "${SYM_DIR}/zip/${SO_NAME}/${SO_ID}"
  cp -f "${SYM_FILE}" "${SYM_DIR}/zip/${SO_NAME}/${SO_ID}/"
done

cd "${SYM_DIR}/zip"
zip -q -r "${SYM_DIR}/symbols.zip" *

[ -z "$QUIET" ] && echo "The symbols are ready for upload at:"
echo "${SYM_DIR}/symbols.zip"
