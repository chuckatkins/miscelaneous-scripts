if(NOT _QNX_TOOLCHAIN)
  message(FATAL_ERROR "The QNX-common-ToolChain is for internal use only by the architecture specific QNX toolchain files.")
endif()
if(NOT DEFINED ENV{QNX_HOST})
  message(FATAL_ERROR "QNX_HOST environment variable is not defined.")
endif()
if(NOT DEFINED ENV{QNX_TARGET})
  message(FATAL_ERROR "QNX_TARGET environment variable is not defined.")
endif()

set(CMAKE_SYSTEM_NAME QNX)

set(CMAKE_C_COMPILER "$ENV{QNX_HOST}/usr/bin/qcc${CMAKE_EXECUTABLE_SUFFIX}")
set(CMAKE_C_FLAGS   "-w9 -V${_QNX_QCC_ARCH}" CACHE STRING "C Flags"   FORCE)

set(CMAKE_CXX_COMPILER "$ENV{QNX_HOST}/usr/bin/QCC${CMAKE_EXECUTABLE_SUFFIX}")
set(CMAKE_CXX_FLAGS "-w9 -V${_QNX_QCC_ARCH}_cpp" CACHE STRING "C++ Flags" FORCE)

set(_CMAKE_TOOLCHAIN_LOCATION   "$ENV{QNX_HOST}/usr/bin")
set(_CMAKE_TOOLCHAIN_PREFIX     "${_QNX_BINUTILS}-")

set(CMAKE_FIND_ROOT_PATH "$ENV{QNX_TARGET}" "$ENV{QNX_TARGET}/${_QNX_SYSROOT}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
