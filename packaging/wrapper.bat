@echo off

SET RUNNING_PATH=%~dp0
CALL :RESOLVE "%RUNNING_PATH%" ROOT_PATH

set BUNDLE_IGNORE_CONFIG=
set RUBYGEMS_GEMDEPS=
set BUNDLE_APP_CONFIG=

:: Run the actual app using the bundled Ruby interpreter, with Bundler activated.
@"%ROOT_PATH%\lib\ruby\bin\ruby.bat" "%ROOT_PATH%\lib\app\hello.rb" %*

GOTO :EOF

:RESOLVE
SET %2=%~f1
GOTO :EOF
