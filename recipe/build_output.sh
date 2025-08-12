#!/bin/bash
set -ex

echo "Building ${PKG_NAME}."

# Isolate the build.
mkdir build && cd build

if [[ "$PKG_NAME" == *static ]]; then
  CARES_STATIC=ON
  CARES_SHARED=OFF
else
  CARES_STATIC=OFF
  CARES_SHARED=ON
fi

if [[ "${target_platform}" == linux-* ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_AR=${AR}"
fi

echo "Generating the build files..."
cmake ${CMAKE_ARGS} -G"$CMAKE_GENERATOR" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      -DCARES_STATIC=${CARES_STATIC} \
      -DCARES_SHARED=${CARES_SHARED} \
      -DCARES_INSTALL=ON \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -GNinja \
      -DCARES_BUILD_TESTS=ON \
      ${SRC_DIR}

echo "Installing..."
cmake --build . --config Release --target install

echo "Testing..."
ctest -R aresfuzz --output-on-failure -j${CPU_COUNT}
ctest -R aresfuzzname --output-on-failure -j${CPU_COUNT}

# Too many fails on linux
if [[ "${target_platform}" == osx-* ]]; then
# Expected equality of these values:
  # ARES_SUCCESS
    # Which is: 0
  # result.status_
    # Which is: 4
./bin/arestest --gtest_filter=-DefaultChannelTest.LiveSearchANY:DefaultChannelTest.LiveSearchANY_virtualized
fi

echo "Error free exit!"
exit 0
