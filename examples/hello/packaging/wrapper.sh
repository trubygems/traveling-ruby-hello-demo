#!/bin/sh
set -e

SOURCE="$0"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  TARGET="$(readlink "$SOURCE")"
  START="$( echo "$TARGET" | cut -c 1 )"
  if [ "$START" = "/" ]; then
    SOURCE="$TARGET"
  else
    DIR="$( dirname "$SOURCE" )"
    SOURCE="$DIR/$TARGET" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  fi
done
RDIR="$( dirname "$SOURCE" )"
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Figure out where this script is located.
LIBDIR="$(cd "$DIR" && cd lib && pwd)"

unset BUNDLE_IGNORE_CONFIG
unset RUBYGEMS_GEMDEPS
unset BUNDLE_APP_CONFIG

# Run the actual app using the bundled Ruby interpreter, with Bundler activated.
exec "$LIBDIR/ruby/bin/ruby" "$LIBDIR/app/hello.rb" "$@"