#!/usr/bin/env python
# Author: Chuck Atkins
# Contact: chuck atkins at gee mail dot com

# The purpose of this script is to adjust the scaling factors of multiple
# monitors to presenty the appearance of a consistent resolution across all
# displays.  It does this by using xrandr to querey the dimensions of the
# largest iphysical display and set all others to thier native resolutions with
# appropriate scale factors to match the largest display.

import math
import re
import subprocess

# Turn all the monitors on and reset to the native resolution with scale = 1
outputs = []
xrandr_args = ['xrandr']
prg = re.compile('^(\w+) connected')
for line in subprocess.check_output(['xrandr']).split('\n'):
    res = prg.search(line)
    if res:
        output = res.group(1)
        outputs.append(output)
        xrandr_args.extend(['--output', output, '--auto', '--scale', '1.0x1.0'])
print 'Resetting to the native resolutions on all connected displays:'
print '  '+' '.join(xrandr_args)
print
subprocess.check_call(xrandr_args)

# Grab screen dimensions
screen_map = {}
mm_d_max = 0.0;
prg = re.compile('^(\w+) connected (\d+)x(\d+)[+-](\d+)[+-](\d+).* (\d+)mm x (\d+)mm')
for line in subprocess.check_output(['xrandr']).split('\n'):
    res = prg.search(line)
    if res:
        output = res.group(1)

        # Extract screen dimensions
        px_x, px_y, mm_x, mm_y = map(int, res.group(2,3,6,7))
        screen_map[output] = (px_x, px_y, mm_x, mm_y)

        # Determine the largest physical screen
        mm_d = math.sqrt(mm_x*mm_x+mm_y*mm_y)
        if mm_d > mm_d_max:
            mm_d_max = mm_d
            output_max = output

# Determine DPI of the largest screen
px_x, px_y, mm_x, mm_y = screen_map[output_max]
dpmm_x_max = float(px_x)/mm_x
dpmm_y_max = float(px_y)/mm_y

xrandr_args = ['xrandr', '--dpi', '%(x)fx%(y)f'%{'x':dpmm_x_max*25.4,'y':dpmm_y_max*25.4}]
for output in outputs:
    px_x, px_y, mm_x, mm_y = screen_map[output]

    # Scale all other screens to the largest based on dpi scaling
    dpmm_x = float(px_x)/mm_x
    dpmm_y = float(px_y)/mm_y
    scale_x = dpmm_x_max/dpmm_x
    scale_y = dpmm_y_max/dpmm_y

    xrandr_args.extend(['--output', output, '--scale', '%(x)fx%(y)f'%{'x':scale_x,'y':scale_y}])

print 'Applying computed DPI and scale factors:'
print '  '+' '.join(xrandr_args)
print
subprocess.check_call(xrandr_args)
