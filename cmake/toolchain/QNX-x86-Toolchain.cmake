set(CMAKE_SYSTEM_NAME QNX)

set(CMAKE_C_COMPILER "$ENV{QNX_HOST}/usr/bin/qcc${CMAKE_EXECUTABLE_SUFFIX}")
set(CMAKE_C_FLAGS   "-w9 -Vgcc_ntox86" CACHE STRING "C Flags"   FORCE)

set(CMAKE_CXX_COMPILER "$ENV{QNX_HOST}/usr/bin/QCC${CMAKE_EXECUTABLE_SUFFIX}")
set(CMAKE_CXX_FLAGS "-w9 -Vgcc_ntox86_cpp" CACHE STRING "C++ Flags" FORCE)


set(_CMAKE_TOOLCHAIN_LOCATION   "$ENV{QNX_HOST}/usr/bin")
set(_CMAKE_TOOLCHAIN_PREFIX     "ntox86-")

set(CMAKE_FIND_ROOT_PATH "$ENV{QNX_TARGET}" "$ENV{QNX_TARGET}/x86")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
