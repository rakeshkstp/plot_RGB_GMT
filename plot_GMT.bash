#!/bin/bash
source input_GMT.bash
mkdir ./PNG
if [ -f product.lst ]; then
			rm product.lst
	fi

nfiles=$(ls -1 ../*.nc 2>/dev/null | wc -l)
if [ $nfiles -gt 0 ]; then
	echo "$nfiles netCDF files are present."
	ls -1 ../*.nc > product.lst
fi

scale=temp.cpt
for ncfile in `cat product.lst`
  do
		$mfont
    IFS='_' read -r year month prod  <<< ${ncfile:3}
  	if [[ ${prod:0:3} == "Chl" ]]; then
			rm -f $scale
			iprod="Chlorophyll.a"
			product="Chl"
			gmt makecpt $chlscale > $scale
		elif [[ ${prod:0:3} == "SPM" ]]; then
			rm -f $scale
			iprod="SPM"
			product="SPM"
			gmt makecpt $spmscale > $scale
		elif [[ ${prod:0:4} == "PARb" ]]; then
			rm -f $scale
			iprod="PARb"
			product="PARb"
			gmt makecpt $parbscale > $scale
		elif [[ ${prod:0:4} == "PARs" ]]; then
			rm -f $scale
			iprod="PARs"
			product="PARs"
			gmt makecpt $parsscale > $scale
		elif [[ ${prod:0:3} == "Sea" ]]; then
			rm -f $scale
			iprod="SeaIce"
			product="SIF"
			gmt makecpt $seaicescale > $scale
		else
			echo "Not a valid image file."
			continue
		fi
		nc="${ncfile}?Median_${iprod}_${year}_${month}"
    ps="${product}_Median_${year}_${month}.ps"
    gmt grdimage $nc -C$scale -t100 $R $J -K -E300i -G100 > $ps
    gmt pscoast $R $J $lon $landmask -K -O >> $ps
    gmt pscoast $R $J $lat $landmask -K -O >> $ps
    $cfont
    gmt pscoast $R $J -Ba0g0fswne $landmask -K -O >> $ps
    #echo $loc1 "${month}, ${year}" | gmt pstext -R -J -O -K -F+f12p,Helvetica,white+jLB >> $ps
    #echo $loc2 "Chlorophyll-a" | gmt pstext -R -J -O -K -F+f12p,Helvetica,white+jLB >> $ps
		if [[ ${prod:0:3} == "Chl" ]]; then
			gmt psscale -C$scale $D -Bxa+l"mg m@+-3@+" -S -O -N300i -t100 -Q >> $ps
		elif [[ ${prod:0:3} == "SPM" ]]; then
			gmt psscale -C$scale $D -Bx2+l"g m@+-3@+" -S -O -N300i -t100 -Q >> $ps
		elif [[ ${prod:0:4} == "PARb" ]]; then
			gmt psscale -C$scale $D -Bx0.5+l"E m@+-2@+ day@+-1@+" -S -O -N300i -t100 -Q >> $ps
		elif [[ ${prod:0:4} == "PARs" ]]; then
			gmt psscale -C$scale $D -Bxa+l"E m@+-2@+ day@+-1@+" -S -O -N300i -t100 >> $ps
		elif [[ ${prod:0:3} == "Sea" ]]; then
			gmt psscale -C$scale $D -Bxa+l"Sea Ice Fraction" -O -N300i -S -t100 >> $ps
		else
			echo "Cannot create scale, invalid image file."
			continue
		fi
    gmt psconvert -A -P -TG $ps
    rm $ps
    rm *.history
		rm -f $scale
	done
rm -f product.lst
rm -f gmt.conf
mv *.png ./PNG
