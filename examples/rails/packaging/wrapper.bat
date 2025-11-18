@echo off

SET RUNNING_PATH=%~dp0
CALL :RESOLVE "%RUNNING_PATH%" ROOT_PATH

:: Tell Bundler where the Gemfile and gems are.
set "BUNDLE_GEMFILE=%ROOT_PATH%\lib\vendor\Gemfile"
set BUNDLE_IGNORE_CONFIG=
set RUBYGEMS_GEMDEPS=
set BUNDLE_APP_CONFIG=
set BUNDLE_FROZEN=1
set PRISM_FFI_BACKEND=false
:: Run the actual app using the bundled Ruby interpreter, with Bundler activated.
cd /d "%ROOT_PATH%\lib\app"
@"%ROOT_PATH%\lib\ruby\bin\ruby.bat" -E UTF-8 -rbundler/setup -I "%ROOT_PATH%\lib\app\lib" "%ROOT_PATH%\lib\app\bin\rails" %*

GOTO :EOF

:RESOLVE
SET %2=%~f1
GOTO :EOF
