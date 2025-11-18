#!/bin/sh
set -eu

detected_os=`uname -sm`
echo detected_os = "$detected_os"
BINARY_OS="${BINARY_OS:-}"
BINARY_ARCH="${BINARY_ARCH:-}"
FILE_EXT="${FILE_EXT:-}"

if [ "$BINARY_OS" = "" ] || [ "$BINARY_ARCH" = "" ]; then
    case "$detected_os" in
    'Darwin arm64')
        BINARY_OS=macos
        BINARY_ARCH=arm64
        ;;
    'Darwin x86' | 'Darwin x86_64' | "Darwin"*)
        BINARY_OS=macos
        BINARY_ARCH=x86_64
        ;;
    Linux\ aarch64* | Linux\ arm64*)
        BINARY_OS=linux
        BINARY_ARCH=arm64
        if ldd /bin/ls >/dev/null 2>&1; then
            ldd_output=`ldd /bin/ls`
            case "$ldd_output" in
                *musl*) BINARY_OS=linux-musl ;;
            esac
        fi
        ;;
    'Linux x86_64' | "Linux"*)
        BINARY_OS=linux
        BINARY_ARCH=x86_64
        if ldd /bin/ls >/dev/null 2>&1; then
            ldd_output=`ldd /bin/ls`
            case "$ldd_output" in
                *musl*) BINARY_OS=linux-musl ;;
            esac
        fi
        ;;
    MINGW64*ARM64*)
        BINARY_OS=windows
        BINARY_ARCH=arm64
        ;;
    Windows* | MINGW64*)
        BINARY_OS=windows
        BINARY_ARCH=x86_64
        ;;
    *)
        echo "Sorry, os not determined"
        exit 1
        ;;
    esac
fi
echo BINARY_OS = "$BINARY_OS"
echo BINARY_ARCH = "$BINARY_ARCH"
if [ "$BINARY_OS" != "windows" ]; then PATH_SEPERATOR=/; else PATH_SEPERATOR=\\; fi
PATH_TO_BIN=.${PATH_SEPERATOR}examples${PATH_SEPERATOR}${APP_NAME:-pkg}${PATH_SEPERATOR}pkg${PATH_SEPERATOR}test-app${PATH_SEPERATOR}

tools="lib${PATH_SEPERATOR}ruby${PATH_SEPERATOR}bin${PATH_SEPERATOR}ruby ${APP_NAME:-hello}"

for tool in $tools; do
  echo testing $tool
  if [ "$BINARY_OS" = "windows" ]; then FILE_EXT=.bat; else FILE_EXT=""; fi
  if [ "$tool" = "lib${PATH_SEPERATOR}ruby${PATH_SEPERATOR}bin${PATH_SEPERATOR}ruby" ] || [ "$tool" = "pact_broker" ] || [ "$tool" = "rails" ]; then test_cmd="--version"; else test_cmd=""; fi
  echo executing ${tool}${FILE_EXT}
  ${PATH_TO_BIN}${tool}${FILE_EXT} $test_cmd
done

# test the pact broker by starting and publishing a pact
if [ -f "${PATH_TO_BIN}pact_broker${FILE_EXT}" ]; then

    if [ "$BINARY_OS" = "windows" ]; then
    ${PATH_TO_BIN}pact_broker${FILE_EXT} -P broker.pid &
    else
    ${PATH_TO_BIN}pact_broker${FILE_EXT} -D -P broker.pid
    fi

    for i in {1..30}; do
    if curl -s http://localhost:9292/ >/dev/null; then
        break
    fi
    sleep 1
    done

    ${PATH_TO_BIN}pact_broker${FILE_EXT} client publish ${PATH_TO_BIN}lib/app/*.json --broker-base-url http://localhost:9292/ --consumer-app-version 1.0.0

    if [ "$BINARY_OS" = "windows" ]; then
    taskkill //F //PID "$(cat broker.pid)"
    else
    kill $(cat broker.pid)
    fi
fi

# test a new rails app by starting it, and making a http request
if [ -f "${PATH_TO_BIN}rails${FILE_EXT}" ]; then

    if [ "$BINARY_OS" = "windows" ]; then
    ${PATH_TO_BIN}rails${FILE_EXT} server --pid rails.pid &
    else
    ${PATH_TO_BIN}rails${FILE_EXT} server --daemon --pid rails.pid
    fi

    for i in {1..30}; do
    if curl -s http://localhost:3000/ >/dev/null; then
        break
    fi
    sleep 1
    done

    curl -s http://localhost:3000/

    if [ "$BINARY_OS" = "windows" ]; then
    taskkill //F //PID "$(cat rails.pid)"
    else
    kill $(cat rails.pid)
    fi
fi