#!/bin/bash
J=-JU17/10c #Projection UTM
R=-R-82.734/-78.342/50.857/55.329 #Region [-R<west>/<east>/<south>/<north>[+r]]
A=WSne  #Annotation
D=-Dx1.0c/5.0c+w4.5c/0.2c+jTC+ml #Colorbar
lat=-Ba1g0fWne		#latitude
lon=-Ba1g0fSne		#longitude
L=-Lf32.5/77/10/100+lkm #Scale
T=-Tdg8/80.2+w0.8c+f+l,,,N #Rose
landmask="-Dh -G120 -W0.2p,black"
cfont="gmt set FONT_ANNOT_PRIMARY 14p,Helvetica FONT_TITLE 10p MAP_TITLE_OFFSET 0.1c MAP_ANNOT_OFFSET_PRIMARY 0.1c MAP_ANNOT_OFFSET_SECONDARY 0.1c MAP_LABEL_OFFSET 0.2c"
gmt gmtset COLOR_NAN 200
mfont="gmt set FONT_ANNOT_PRIMARY 20p,Helvetica \
        MAP_GRID_CROSS_SIZE_PRIMARY 0.1i MAP_ANNOT_OFFSET_PRIMARY 0.2c"
chlscale="-Cjet -T0/1/0.01 -Z -Do -Qi"
spmscale="-Cdrywet -I -T0/1.35/0.1 -Z -Do -Qi"
parbscale="-Cpanoply -T-2/1/0.1 -Z -Do -Qi"
parsscale="-Cpanoply -T0/60/0.1 -Z -Do"
seaicescale="-Cblue,cyan,aquamarine,white -T0/1/0.1 -Z -Do"
icwscale="-Cblue,aquamarine,white -T0/2/1 -Z -Do"
COTscale="-Cpolar -T0/65/0.1 -Z -Do"
OOTscale="-Ccool -T300/400/1 -Z -Do"
salbscale="-Cwysiwyg -T0/0.85/0.01 -Z -Do"
rhosscale="-Crainbow -T0/0.2/0.01 -Z -Do"
statname="Median"
