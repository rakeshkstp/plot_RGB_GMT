#!/bin/bash
source input_GMT.bash
#mkdir ../PNG
if [ -f product.lst ]; then
			rm product.lst
	fi

nfiles=$(ls -1 ../NC/*rgb.nc 2>/dev/null | wc -l)
if [ $nfiles -gt 0 ]; then
	echo "$nfiles netCDF files are present."
	ls -1 ../NC/*rgb.nc > product.lst
fi

scale=temp.cpt
for ncfile in `cat product.lst`
  do
		$mfont
		red="${ncfile}?red"
		green="${ncfile}?green"
		blue="${ncfile}?blue"

		IFS='.' read -r path1 path2 path3  <<< ${ncfile:6}
		sensor=${path1:0:3}
		year=${path1:4:4}
		month=${path1:8:2}
		day=${path1:10:2}
		pr=${path1:12}
		path1="${year}${month}${day}${pr}"
		pstc="${path1}_TC.ps"
		pngtc="${path1}_TC.png"

		rm -f red.nc
		rm -f green.nc
		rm -f blue.nc
		gmt grdconvert $red=nf+s255+o0 $R -Gred.nc
		gmt grdconvert $green=nf+s255+o0 $R -Ggreen.nc
		gmt grdconvert $blue=nf+s255+o0 $R -Gblue.nc
		gmt psbasemap $R $J $lat -K > $pstc
		gmt pscoast $R $J $lon -O -C -K >> $pstc
		gmt grdimage red.nc green.nc blue.nc $R $J -Ba0g0 -O >> $pstc

		#	echo "15:38:0E 78:10:30N $sensor $year/${month}/$day" | gmt pstext -R -J -O -K -F+f14p,Helvetica,red+jLB >> $cps
		#gmt psscale -C$scale $D -Bax+l"g m@+-3@+" -S -O -N300i -t100 -Q>> $pstc
		gmt psconvert -A -P -TG $pstc
		rm $pstc
		rm -f red.nc
		rm -f green.nc
		rm -f blue.nc

    rm *.history
	done
rm -f product.lst
rm -f gmt.conf
