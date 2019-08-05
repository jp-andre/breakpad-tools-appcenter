#!/bin/bash

SYM_DIR="$1"
[[ -d "${SYM_DIR}" ]] || exit 1

for SYM_FILE in `find ${SYM_DIR} -type f` ; do
  SO_ID=`head -n1 "${SYM_FILE}" |cut -d ' ' -f 4`
  SO_NAME=`head -n1 "${SYM_FILE}" |cut -d ' ' -f 5`
  mkdir -p "${SYM_DIR}/zip/${SO_NAME}/${SO_ID}"
  cp -f "${SYM_FILE}" "${SYM_DIR}/zip/${SO_NAME}/${SO_ID}/"
done

cd "${SYM_DIR}/zip"
zip -r "${SYM_DIR}/symbols.zip" *

echo "The symbols are ready at:"
echo "  ${SYM_DIR}/symbols.zip"

