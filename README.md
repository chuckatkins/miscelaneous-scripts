This is a colleciton of miscelaneous scripts that I happen to come up with
and find useful.  Below is a brief summary of each.

As for licensing, I'm placing them all under the public domain.  This
basically means that you can do whatever you want with it.  If you happen to
find it useful though and want to use any of them in a project, I'd appreciate
a brief mention :-)

* scripts: Miscelaneous shell-ish scripts for things
  * set_dpi.sh : Dynamically compute and set the real DPI of all connected monitors using xrandr.

* cmake:  Miscelaneous CMake things
  * toolchain :  CMake cross-compiling toolchain files
    * QNX-common-ToolChain.cmake: Common to all QNX toolchain files
    * QNX-armv7le-ToolChain.cmake: Cross compiling to QNX on ARMv7
    * QNX-x86-ToolChain.cmake: Cross compiling to QNX on x86
  * adios : CMake things for the ADIOS library
    * titan : CMake files for building ADIOS on Titan
      * configure.gnu : Shell script to configure ADIOS with CMake and GCC
      * configure.intel : Shell script to configure ADIOS with CMake and Intel
      * configure.pgi : Shell script to configure ADIOS with CMake PGI
