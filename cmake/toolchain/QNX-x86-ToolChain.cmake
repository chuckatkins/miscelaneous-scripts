set(_QNX_QCC_ARCH  gcc_ntox86)
set(_QNX_BINUTILS  ntox86)
set(_QNX_SYSROOT   x86)
set(_QNX_TOOLCHAIN TRUE)

get_filename_component(_QNX_TOOL_FILE "${CMAKE_CURRENT_LIST_FILE}" REALPATH)
get_filename_component(_QNX_TOOL_DIR  "${_QNX_TOOL_FILE}" DIRECTORY)
include("${_QNX_TOOL_DIR}/QNX-common-ToolChain.cmake")
