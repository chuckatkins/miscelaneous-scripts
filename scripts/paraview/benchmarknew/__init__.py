'''
This module has utilities to benchmark paraview.

logbase contains core routines for colelcting and gathering timing logs from
all nodes.
logparser contains additional routines for parsing the raw logs and
calculating statistics across ranks and frames.

manyspheres is a geometry rendering benchmark that generates a large number
of spheres adn moves the camera around the scene.  To run the benchmark,
either explicitly import manyspheres from paraview.benchmark and call it's
run method, or call the manyspheres.py module directly via pvbatch.

::

    TODO: this doesn't handle split render/data server mode
    TODO: the end of frame markers are heuristic, likely buggy
'''

__all__ = ['logbase', 'logparser']
