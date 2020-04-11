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
  	if [[ ${prod:0:3} == "ABI" ]]; then
			rm -f $scale
			iprod="ABI_Chlorophyll.a"
			product="ABI_Chl"
			gmt makecpt $chlscale > $scale
		elif [[ ${prod:0:3} == "GAB" ]]; then
			rm -f $scale
			iprod="GABI_Chlorophyll.a"
			product="GABI_Chl"
			gmt makecpt $chlscale > $scale
		elif [[ ${prod:0:3} == "SPM" ]]; then
			rm -f $scale
			iprod="SPM"
			product="SPM"
			gmt makecpt $spmscale > $scale
		elif [[ ${prod:0:8} == "PAR_OBPG" ]]; then
			rm -f $scale
			iprod="PAR_OBPG"
			product="PAR_OBPG"
			gmt makecpt $parsscale > $scale
		elif [[ ${prod:0:11} == "PAR_UQAR_0p" ]]; then
			rm -f $scale
			iprod="PAR_UQAR_0plus"
			product="PAR_UQAR_0plus"
			gmt makecpt $parsscale > $scale
		elif [[ ${prod:0:11} == "PAR_UQAR_0m" ]]; then
			rm -f $scale
			iprod="PAR_UQAR_0minus"
			product="PAR_UQAR_0minus"
			gmt makecpt $parsscale > $scale
		elif [[ ${prod:0:15} == "PAR_UQAR_bottom" ]]; then
			rm -f $scale
			iprod="PAR_UQAR_bottom"
			product="PAR_UQAR_bottom"
			gmt makecpt $parbscale > $scale
		elif [[ ${prod:0:3} == "Sea" ]]; then
			rm -f $scale
			iprod="SeaIce"
			product="SIF"
			gmt makecpt $seaicescale > $scale
		elif [[ ${prod:0:3} == "ICW" ]]; then
			rm -f $scale
			iprod="ICW"
			product="ICW"
			gmt makecpt $icwscale > $scale
		elif [[ ${prod:0:3} == "COT" ]]; then
			rm -f $scale
			iprod="COT"
			product="COT"
			gmt makecpt $COTscale > $scale
		elif [[ ${prod:0:3} == "OOT" ]]; then
			rm -f $scale
			iprod="OOT"
			product="OOT"
			gmt makecpt $OOTscale > $scale
		elif [[ ${prod:0:4} == "salb" ]]; then
			rm -f $scale
			iprod="salb"
			product="salb"
			gmt makecpt $salbscale > $scale
		elif [[ ${prod:0:4} == "rhos" ]]; then
			rm -f $scale
			iprod="rhos_2130"
			product="rhos_2130"
			gmt makecpt $rhosscale > $scale
		else
			echo "Not a valid image file."
			continue
		fi


		if [[ ${prod:0:3} == "ICW" ]]; then
			statname="Minimum"
		fi
		nc="${ncfile}?${statname}_${iprod}_${year}_${month}"
    ps="${product}_${statname}_${year}_${month}.ps"


		gmt grdimage $nc -C$scale -t100 $R $J -K -E300i -G100 > $ps
    gmt pscoast $R $J $lon $landmask -K -O >> $ps
    gmt pscoast $R $J $lat $landmask -K -O >> $ps
    $cfont
    gmt pscoast $R $J -Ba0g0fswne $landmask -K -O >> $ps
    #echo $loc1 "${month}, ${year}" | gmt pstext -R -J -O -K -F+f12p,Helvetica,white+jLB >> $ps
    #echo $loc2 "Chlorophyll-a" | gmt pstext -R -J -O -K -F+f12p,Helvetica,white+jLB >> $ps
		if [[ ${prod:0:3} == "ABI" ]]; then
			gmt psscale -C$scale $D -Bxa+l"mg m@+-3@+" -S -O -N300i -t100 -Q >> $ps
		elif [[ ${prod:0:3} == "GAB" ]]; then
			gmt psscale -C$scale $D -Bxa+l"mg m@+-3@+" -S -O -N300i -t100 -Q >> $ps
		elif [[ ${prod:0:3} == "SPM" ]]; then
			gmt psscale -C$scale $D -Bx2+l"g m@+-3@+" -S -O -N300i -t100 -Q >> $ps
		elif [[ ${prod:0:3} == "PAR" ]]; then
			gmt psscale -C$scale $D -Bxa+l"E m@+-2@+ day@+-1@+" -S -O -N300i -t100 >> $ps
		elif [[ ${prod:0:3} == "Sea" ]]; then
			gmt psscale -C$scale $D -Bxa+l"Sea Ice Fraction" -O -N300i -S -t100 >> $ps
		elif [[ ${prod:0:3} == "ICW" ]]; then
			gmt psscale -C$scale $D -Bx+l"Water     Ice     Cloud" -O -N300i -S -t100 >> $ps
		elif [[ ${prod:0:3} == "COT" ]]; then
			gmt psscale -C$scale $D -Bxa -S -O -N300i -t100 >> $ps
		elif [[ ${prod:0:3} == "OOT" ]]; then
			gmt psscale -C$scale $D -Bxa+l"DU" -S -O -N300i -t100 >> $ps
		elif [[ ${prod:0:3} == "sal" ]]; then
			gmt psscale -C$scale $D -Bxa -S -O -N300i -t100 >> $ps
		elif [[ ${prod:0:3} == "rho" ]]; then
			gmt psscale -C$scale $D -Bxa -S -O -N300i -t100 >> $ps
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
#mv *.png ./PNG
