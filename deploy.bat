@echo off
setlocal

set PROJECT_DIR=E:\ThreeQStudyMachine
set NODE_EXE=D:\Dev\Lang\nojs\node.exe
set HVIGOR_JS=C:\Users\Administrator\.hvigor\project_caches\8bb3cb92567353586222e60791d40041\workspace\node_modules\@ohos\hvigor\bin\hvigor.js
set HDC_EXE=D:\deveco studio\Sdk\hmscore\3.1.0\toolchains\hdc.exe
set TARGET=emulator-5554
set HAP=%PROJECT_DIR%\entry\build\default\outputs\default\entry-default-unsigned.hap
set BUNDLE=com.threeq.studymachine

echo Building ThreeQ...
cd /d "%PROJECT_DIR%"
"%NODE_EXE%" "%HVIGOR_JS%" --mode module -p product=default assembleHap
if errorlevel 1 goto fail

echo Installing ThreeQ to %TARGET%...
"%HDC_EXE%" -t %TARGET% install -r "%HAP%"
if errorlevel 1 goto fail

echo Starting ThreeQ...
"%HDC_EXE%" -t %TARGET% shell aa start -a EntryAbility -b %BUNDLE%
if errorlevel 1 goto fail

echo Done.
goto end

:fail
echo Failed.

:end
pause
