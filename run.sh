#!/bin/sh

set -e

TIMESTAMP=`TZ=UTC date "+%Y-%m-%dT%H-%M-%SZ"`
SYM_DIR=${SYM_DIR:-/tmp/symbols/${TIMESTAMP}}

if [ "$1" = "" ] ; then
  exec docker run -it breakpad
  exit $?
fi

for SO_FILE in $@ ; do
  SO_DIR=`dirname ${SO_FILE}`
  SO_NAME=`basename ${SO_FILE}`
  SYM_FILE="${SO_DIR}/${SO_NAME}.sym"
  mkdir -p "${SYM_DIR}"

  docker run --name breakpad --rm -i -v ${SO_DIR}:/work/mnt breakpad bash -c "/usr/local/bin/dump_syms /work/mnt/${SO_NAME} > /work/mnt/${SO_NAME}.sym"

  cp -f "${SYM_FILE}" "${SYM_DIR}"
done

for SYM_FILE in `find ${SYM_DIR} -type f` ; do
  SO_ID=`head -n1 "${SYM_FILE}" |cut -d ' ' -f 4`
  SO_NAME=`head -n1 "${SYM_FILE}" |cut -d ' ' -f 5`
  mkdir -p "${SYM_DIR}/zip/${SO_NAME}/${SO_ID}"
  cp -f "${SYM_FILE}" "${SYM_DIR}/zip/${SO_NAME}/${SO_ID}/"
done

cd "${SYM_DIR}/zip"
zip -r "${SYM_DIR}/symbols.zip" *

echo "The symbols are ready for upload at:"
echo "  ${SYM_DIR}/symbols.zip"