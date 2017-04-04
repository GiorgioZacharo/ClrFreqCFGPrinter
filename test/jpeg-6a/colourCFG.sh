#!/bin/bash

# Case 1	: Weather Map Temperature.
# 
# Red 		: Hot
# Orange   	: Warmer
# Yellow   	: Warm	
# Green    	: Tepid
# Turquoise 	: Breeze
# Cyan     	: Cool
# SkyBlue  	: Cooler	
# Blue     	: Cold


IN="$1"

DEFAULT="cjpeg"
IN="${IN:-${DEFAULT}}"

 if [ -d Dot_colour_freq_files_$IN ]; then
 	mv *bbs.txt Dot_colour_freq_files_$IN/.
 	mv freq*.txt freq_val.txt.bak Dot_colour_freq_files_$IN/.
 	mkdir CFG_colour_freq_graphs_$IN
	cd Dot_colour_freq_files_$IN
	#rm freq*.txt
 fi



for i in cfg*.dot
do 

	cat $i > temp_$i.dot

	for j in `ls *bbs.txt`; do	
		while read func bb; do
			if [ "cfg.$func.dot" == "$i" ]; then
				echo " found $i"
				

				if [ "hot_bbs.txt" == "$j" ]; then
					color="red"
					#color="\"#ff 00 00 ff\""
				elif [ "warmer_bbs.txt" == "$j" ]; then
					color="orange"
				elif [ "warm_bbs.txt" == "$j" ]; then
					color="yellow"
				elif [ "tepid_bbs.txt" == "$j" ]; then
					color="green"
				elif [ "breeze_bbs.txt" == "$j" ]; then
					color="turquoise"																	
				elif [ "cool_bbs.txt" == "$j" ]; then
					color="cyan"
				elif [ "cooler_bbs.txt" == "$j" ]; then
					color="skyblue"
				elif [ "cold_bbs.txt" == "$j" ]; then
					color="blue"
				fi			

				sed -e "s/label=\"{$bb:/ style = filled, fillcolor = $color, label=\"{$bb:/g"  temp_$i.dot > freq.$func.dot	
				cat freq.$func.dot > temp_$i.dot

			fi	
		done<"$j"
	done
	
done

rm temp*
echo "--> Generate pdf files from dot files"
for l in `ls freq*.dot`; do dot -Tpdf $l > ../CFG_colour_freq_graphs_$IN/$l.pdf; done

exit 0;

# Authors  :   Georgios Zacharopoulos <georgios.zacharopoulos@usi.ch> , Universita della Svizzera italiana  Date: July, 2016
