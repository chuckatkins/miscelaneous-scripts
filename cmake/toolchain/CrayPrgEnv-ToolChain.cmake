# Make sure we can find the ComputeNodeLinux Platform file since it's not
# shipped with CMake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

set(CMAKE_SYSTEM_NAME ComputeNodeLinux)

# Make sure we have the appropriate environment loaded
if(NOT DEFINED ENV{ASYNCPE_DIR})
  message(FATAL_ERROR "The ASYNCPE_DIR environment variable is not defined but the CrayPrgEnv toolchain module requires it.  This usually means that the necessary PrgEnv-* module is not loaded")
endif()

# Explicitly use the cray compiler wrappers from the PrgEnv-* module
set(CMAKE_C_COMPILER       "$ENV{ASYNCPE_DIR}/bin/cc")
set(CMAKE_CXX_COMPILER     "$ENV{ASYNCPE_DIR}/bin/CC")
set(CMAKE_Fortran_COMPILER "$ENV{ASYNCPE_DIR}/bin/ftn")

# These shouldn't really be necessary since the Cray compiler drivers pay
# attention to the environment variables but this will force the options
# into the generated build files so even if the environment changes after
# configure, the correct commands will still get called.
if(DEFINED ENV{CRAYPE_COMPILE_TARGET})
  set(_CRAY_TARGET_OPTS "--target=$ENV{CRAYPE_COMPILE_TARGET}")
endif()
if("$ENV{CRAYPE_LINK_TYPE}" STREQUAL "dynamic")
  set(_CRAY_LINK_OPTS "-dynamic")
else() # Explicit or implicit static
  set(_CRAY_LINK_OPTS "-static")
endif()

set(CMAKE_C_FLAGS       "${_CRAY_TARGET} ${_CRAY_LINK}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS     "${_CRAY_TARGET} ${_CRAY_LINK}" CACHE STRING "" FORCE)
set(CMAKE_Fortran_FLAGS "${_CRAY_TARGET} ${_CRAY_LINK}" CACHE STRING "" FORCE)

# Guide the search for binutils. These can't be auto-detected because of
# the forced CMAKE_FIND_ROOT_PATH_MODE_* variables so we explicitly tell
# the CMakeFindBinUtils module to search in the host's directories
set(_CMAKE_TOOLCHAIN_LOCATION /usr/bin)
