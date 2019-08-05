#!/bin/bash

# Pre-requirements:
# - ANDROID_NDK_ROOT points to the NDK root of Android NDK version 20 or similar
# - Breakpad tools are compiled in ~/breakpad/build

PLATFORM_ARCH="x86_64-linux-android i686-linux-android aarch64-linux-android arm-linux-androideabi"
SYMBOLS_ROOT="${HOME}/symbols"
DUMP_SYMS="${HOME}/breakpad/build/src/tools/linux/dump_syms/dump_syms"

check_fail() {
  echo "Some required environment variables are invalid:"
  echo "  ANDROID_NDK_ROOT=${ANDROID_NDK_ROOT}"
  echo "Or dump_syms can not be found at:"
  echo "  ${DUMP_SYMS}"
  exit 1
}

[[ -d "${ANDROID_NDK_ROOT}" ]] || check_fail
[[ -x "${DUMP_SYMS}" ]] || check_fail

for ARCH in ${PLATFORM_ARCH} ; do
  PLATFORM_LIB_ROOT="${ANDROID_NDK_ROOT}/sysroot/usr/lib/${ARCH}"
  PLATFORM_LIB_DIRS=`find "${PLATFORM_LIB_ROOT}" -type d`
  for VERSION_DIR in ${PLATFORM_LIB_DIRS} ; do
    VERSION=`basename ${VERSION_DIR}`
    if [ "${VERSION}" != "${ARCH}" ] ; then
      SO_FILES_COMMON=`find ${PLATFORM_LIB_ROOT} -maxdepth 1 -type f -name "*.so"`
      SO_FILES=`find ${VERSION_DIR} -maxdepth 1 -type f -name "*.so"`
      SYMBOLS_DIR="${SYMBOLS_ROOT}/${ARCH}/android-${VERSION}"
      for SO in ${SO_FILES_COMMON} ${SO_FILES} ; do
        mkdir -p ${SYMBOLS_DIR}
        SO_NAME=`basename ${SO}`
        SYM_FILE="${SYMBOLS_DIR}/${SO_NAME}.sym"
        ${DUMP_SYMS} ${SO} > "${SYM_FILE}"
        [[ "$?" = "0" ]] && echo "DONE: ${SYM_FILE}" || echo "FAIL: ${SYM_FILE}"
      done
    fi
  done
done

