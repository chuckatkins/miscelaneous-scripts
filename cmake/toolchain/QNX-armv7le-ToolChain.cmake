set(_QNX_QCC_ARCH  gcc_ntoarmv7le)
set(_QNX_BINUTILS  ntoarmv7)
set(_QNX_SYSROOT   armle-v7)
set(_QNX_TOOLCHAIN TRUE)

get_filename_component(_QNX_TOOL_FILE "${CMAKE_CURRENT_LIST_FILE}" REALPATH)
get_filename_component(_QNX_TOOL_DIR  "${_QNX_TOOL_DIR}" DIRECTORY)
include("${_QNX_TOOL_DIR}/QNX-common-ToolChain.cmake")
