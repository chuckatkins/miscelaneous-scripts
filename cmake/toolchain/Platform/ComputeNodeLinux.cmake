# Compute Node Linux doesn't quite work the same as native Linux so all of this
# needs to be custom.  We use the variables defined through Cray's environment
# modules to set up the right paths for things.

if(NOT CMAKE_SYSTEM_VERSION)
  if(NOT DEFINED ENV{XTOS_VERSION})
    message(FATAL_ERROR "The CMAKE_SYSTEM_VERSION variable is not set and the XTOS_VERSION environment variable is not defined.  The ComputeNodeLinux CMake platform module either requires it to be manually set or the XTOS_VERSION environment variable to be available. This usually means that the necessary PrgEnv-* module is not loaded")
  else()
    set(CMAKE_SYSTEM_VERSION "$ENV{XTOS_VERSION}")
  endif()
endif()

set(CMAKE_SHARED_LIBRARY_PREFIX "lib")
set(CMAKE_SHARED_LIBRARY_SUFFIX ".so")
set(CMAKE_STATIC_LIBRARY_PREFIX "lib")
set(CMAKE_STATIC_LIBRARY_SUFFIX ".a")

set(CMAKE_FIND_LIBRARY_PREFIXES "lib")

# Normally this sort of logic would belong in the toolchain file but the
# order things get loaded in cause anything set here to override the toolchain
# so we'll explicitly check for static compiler options in order to specify
# whether or not the platform will support it
if("$ENV{CRAYPE_LINK_TYPE}" STREQUAL "dynamic")
  set_property(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS TRUE)
  set(CMAKE_FIND_LIBRARY_SUFFIXES ".so" ".a")
else()
  set_property(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS FALSE)
  set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
endif()

# Make sure we have the appropriate environment loaded
if(NOT DEFINED ENV{SYSROOT_DIR})
  message(FATAL_ERROR "The SYSROOT_DIR environment variable is not defined but the ComputeNodeLinux CMake platform module requires it. This usually means that the necessary PrgEnv-* module is not loaded")
endif()

# Set up system search paths that CMake will use to look for libraries and
# include files.  These will be the standard UNIX search paths but rooted
# in the SYSROOT of the computes nodes.
include(Platform/UnixPaths)
set(CMAKE_FIND_ROOT_PATH "$ENV{SYSROOT_DIR}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
