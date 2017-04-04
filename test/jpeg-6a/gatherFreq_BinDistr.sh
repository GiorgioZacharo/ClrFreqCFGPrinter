#!/bin/bash

# Load BBFreq Pass
echo ""
echo "-->	Loading  BBFreq Pass for each .ir file."
echo ""

make -f Makefile_orig freq_bb &> freq.txt;

# Generating a text where only the frequency values are kept.
awk '{print $NF}' freq.txt > freq_val.txt

# Delete unnecessary lines.
sed -i.bak 's/[^0-9]//g' freq_val.txt ; sed -i.bak '/^$/d' freq_val.txt; 

#############################################
# Sort the Basic Blocks to groups according
# to their frequency. (Hot -- to -- Cold)
#############################################

# Compute the average value of
# the provided frequency values.

# Generating 2 Groups (Bins).
echo "	Computing Limit value of frequencies."
echo ""

count=0;
total=0;
max=0;
min=$(head -n 1 freq_val.txt);

for i in $( awk '{ print $1; }' freq_val.txt )
   do
     total=$(echo $total+$i | bc )
     ((count++))

     if [ $i -gt $max ]; then
	max=$i
     fi

     if [ $i -lt $min ]; then
	min=$i
     fi

   done

width=$(((max-min)/8));

# Limits accordingly.
lowest_limit=$((width));
lower_limit=$((2*width));
low_limit=$((3*width));
limit=$((4*width));
high_limit=$((5*width));
higher_limit=$((6*width));
highest_limit=$((7*width));

echo "          Frequency	Total	is : $total "
echo "          Frequency	Count	is : $count "
echo "          Frequency	Max	is : $max "
echo "          Frequency	Min	is : $min "
echo "          Frequency       Width     is : $width "
echo""
echo "          Frequency 	Lowest	Limit  is :	$lowest_limit "
echo "          Frequency	Lower   Limit  is :	$lower_limit "
echo "          Frequency 	Low	Limit  is :	$low_limit "
echo "          Frequency 	Low	Limit  is :	$limit "
echo "          Frequency 	High	Limit  is :	$high_limit"
echo "          Frequency 	Higher	Limit  is :	$higher_limit"
echo "          Frequency 	Highest	Limit  is :	$highest_limit"
echo""

# Ready to exclude just the hot basic blocks.
echo "	Generating Hot -->  Cold basic blocks files."

# Compare the frequency value of all basic blocks to the
# 7 limit values and sort them accordingly to 8 different bins - text files.
while read func_bb bb freq_val; do

   if [ $freq_val -ge $highest_limit ]; then
            echo $func_bb $bb  >> hot_bbs.txt;
		((count_hot++))

   elif [ $freq_val -ge $higher_limit ] && [ $freq_val -lt $highest_limit ]; then
        echo $func_bb $bb  >> warmer_bbs.txt;
	((count_warmer++))

   elif [ $freq_val -ge $high_limit ] && [ $freq_val -lt $higher_limit ]; then
        echo $func_bb $bb >> warm_bbs.txt;
	((count_warm++))

   elif [ $freq_val -ge $limit ] && [ $freq_val -lt $high_limit ]; then
        echo $func_bb $bb >> tepid_bbs.txt;
	((count_tepid++))

   elif [ $freq_val -ge $low_limit ] && [ $freq_val -lt $limit ]; then
        echo $func_bb $bb >> breeze_bbs.txt;
	((count_breeze++))

   elif [ $freq_val -ge $lower_limit ] && [ $freq_val -lt $low_limit ]; then
        echo $func_bb $bb  >> cool_bbs.txt;
	((count_cool++))

   elif [ $freq_val -gt $lowest_limit ] && [ $freq_val -lt $lower_limit ]; then
        echo $func_bb $bb  >> cooler_bbs.txt;
	((count_cooler++))

   elif [ $freq_val -le $lowest_limit ]; then
        echo $func_bb $bb  >>cold_bbs.txt;
	((count_cold++))

    fi

done<"freq.txt"

echo""
echo "          Cold    count   is :     $count_cold "
echo "          Cooler  count   is :     $count_cooler "
echo "          Cool    count   is :     $count_cool "
echo "          Breeze  count   is :     $count_breeze "
echo "          Tepid   count   is :     $count_tepid "
echo "          Warm    count   is :     $count_warm "
echo "          Warmer  count   is :     $count_warmer "
echo "          Hot     count   is :     $count_hot "

exit 0;

# Authors  :   Georgios Zacharopoulos <georgios.zacharopoulos@usi.ch> , Universita della Svizzera italiana  Date: July, 2016
