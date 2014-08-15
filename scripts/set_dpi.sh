#!/bin/bash
# Author: Chuck Atkins
# Contact: chuck atkins at gee mail dot com

# The purpose of this script is to extract dimensions from the currently
# connected monitors, compute the real DPI of each connected display, then
# dynamically set the real dpi of each display based on these calculations.

# This is performed by querying xrandr to retrieve both the pixel and physical
# dimensions.  Since xrandr reports these in milimeters, the physical
# dimensions are scaled to inches with a factor of 25.4.  The new computed
# "real" DPI values are then used to generate teh correct options to pass back
# to xrandr to set the DPI for each monitor in the X server 

XRANDROPTS="$(xrandr | awk '
  BEGIN{mm2in=25.4}                      # milimeters to inches
  $2 == "connected" && $3 ~ /[0-9].*/ {  # Only connected monitors
    Output=$1;                           # Display output port
    patsplit($3,ResPx,/[1-9][0-9]*/);    # Extract pixel dimensions
    match($(NF-2),/[1-9][0-9]*/,ResMmX); # Extract physical X size
    match($NF,/[1-9][0-9]*/,ResMmY);     # Extract physical Y size
    DPIx=ResPx[1]/(ResMmX[0]/mm2in);     # Compute dpi using pixels,
    DPIy=ResPx[2]/(ResMmY[0]/mm2in);     # millimeters, inch scale
    printf("--output %s --dpi %sx%s ",Output,DPIx,DPIy)
  }
')"

echo Calling: xrandr ${XRANDROPTS}
xrandr ${XRANDROPTS}
