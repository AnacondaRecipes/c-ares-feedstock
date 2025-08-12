:: cmd
@echo on
echo "Building %PKG_NAME%."

set CMAKE_CONFIG=Release

:: Isolate the build.
mkdir build_%CMAKE_CONFIG%
pushd build_%CMAKE_CONFIG%

if "%PKG_NAME:~-6%" == "static" (
  set CARES_STATIC=ON
  set CARES_SHARED=OFF
) else (
  set CARES_STATIC=OFF
  set CARES_SHARED=ON
)

echo "Generating the build files..."
cmake -G"NMake Makefiles" ^
      -DCARES_STATIC:BOOL=%CARES_STATIC% ^
      -DCARES_SHARED:BOOL=%CARES_SHARED% ^
      -DCMAKE_BUILD_TYPE:STRING=%CMAKE_CONFIG% ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCARES_BUILD_TESTS=ON ^
      "%SRC_DIR%"

echo "Installing..."
cmake --build . --config Release --target install
if errorlevel 1 exit /b 1

echo "Testing..."
ctest --output-on-failure
if errorlevel 1 exit /b 1
popd

echo "Error free exit!"
exit 0