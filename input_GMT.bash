#!/bin/bash

loc1="6:45:0E 76:30:0N"
loc2="7:00:0E 76:10:0N"
#J=-JL24/78.7/77.6/79.8/10c #Projection Lambert Conformal Conic
J=-JU17/10c #Projection UTM
R=-R-82.734/-78.342/50.857/55.329 #Region [-R<west>/<east>/<south>/<north>[+r]]
A=WSne  #Annotation
D=-Dx1.0c/5.0c+w4.5c/0.2c+jTC+ml #Colorbar
lat=-Ba1g0fWne		#latitude
lon=-Ba1g0fSne		#longitude
L=-Lf32.5/77/10/100+lkm #Scale
T=-Tdg8/80.2+w0.8c+f+l,,,N #Rose
#landmask=-ESJ+gdarkgrey+p0.25p,black+r # Svalbard
landmask="-Dh -G120 -W0.2p,black"
cfont="gmt set FONT_ANNOT_PRIMARY 14p,Helvetica FONT_TITLE 10p MAP_TITLE_OFFSET 0.1c MAP_ANNOT_OFFSET_PRIMARY 0.1c MAP_ANNOT_OFFSET_SECONDARY 0.1c MAP_LABEL_OFFSET 0.2c"
gmt gmtset COLOR_NAN 200
gmt set FONT_ANNOT_PRIMARY 20p,Helvetica \
        MAP_GRID_CROSS_SIZE_PRIMARY 0.1i MAP_ANNOT_OFFSET_PRIMARY 0.2c
chlscale="-Cjet -T0/1/0.1 -Z -Do -Qi"
spmscale="-Cdrywet -I -T0/4/0.1 -Z -Do"
parbscale="-Cpanoply -T-2/1/0.01 -Z -Do -Qi"
parsscale="-Cpanoply -T0/60/1 -Z -Do"
seaicescale="-Cblue,cyan,aquamarine,white -T0/1/0.1 -Z -Do"
