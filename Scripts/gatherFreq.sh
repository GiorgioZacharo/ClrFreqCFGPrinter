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
echo "	Computing Average value of frequencies."
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

average=$((total/count));

# Generating 4 Groups (Bins).
count=0;
total=0;
count_lower=0;
total_lower=0;
for i in $( awk '{ print $1; }' freq_val.txt )
   do

    if [ $i -gt $average ]; then
       total=$(echo $total+$i | bc )
       ((count++))

    else
         total_lower=$(echo $total_lower+$i | bc )
         ((count_lower++))
    fi

  done

higher_average=$((total / count));
lower_average=$((total_lower / count_lower));

# Generating 8 Groups (Bins).
count_highest=0;
total_highest=0;
count_high=0;
total_high=0;
count_low=0;
total_low=0;
count_lowest=0;
total_lowest=0;
for i in $( awk '{ print $1; }' freq_val.txt )
   do

    if [ $i -gt $higher_average ]; then
       total_highest=$(echo $total_highest+$i | bc )
       ((count_highest++))

    elif [ $i -gt $average ] && [ $i -lt $higher_average ]; then
         total_high=$(echo $total_high+$i | bc )
         ((count_high++))

    elif [ $i -gt $lower_average ] && [ $i -lt $average ]; then
         total_low=$(echo $total_low+$i | bc )
         ((count_low++))

    elif [ $i -lt $lower_average ]; then
         total_lowest=$(echo $total_lowest+$i | bc )
         ((count_lowest++))
    fi

  done

highest_average=$((total_highest/count_highest));
lowest_average=$((total_lowest/count_lowest));
low_average=$((total_low/count_low));
high_average=$((total_high/count_high));

echo "          Frequency	Total	is : $total "
echo "          Frequency	Count	is : $count "
echo "          Frequency	Max	is : $max "
echo "          Frequency	Min	is : $min "
echo "          Frequency	Average	is : $average"
echo""
echo "          Frequency 	High	Average  is : $high_average"
echo "          Frequency 	Low	Average  is : $low_average "
echo "          Frequency 	Higher	Average  is : $higher_average"
echo "          Frequency 	Lower	Average  is : $lower_average "
echo "          Frequency 	Highest	Average  is : $highest_average"
echo "          Frequency 	Lowest	Average  is : $lowest_average "
echo""

# Ready to exclude just the hot basic blocks.
echo "	Generating Hot -->  Cold basic blocks files."

# Compare the frequency value of all basic blocks to the
# 8  average values and sort them accordingly to different groups - text files.
while read func_bb bb freq_val; do

   if [ $freq_val -ge $highest_average ]; then
            echo $func_bb $bb  >> hot_bbs.txt;
                ((count_hot++))
   elif [ $freq_val -ge $higher_average ] && [ $freq_val -lt $highest_average ]; then
        echo $func_bb $bb  >> warmer_bbs.txt;
        ((count_warmer++))

   elif [ $freq_val -ge $high_average ] && [ $freq_val -lt $higher_average ]; then
        echo $func_bb $bb >> warm_bbs.txt;
        ((count_warm++))

   elif [ $freq_val -ge $average ] && [ $freq_val -lt $high_average ]; then
        echo $func_bb $bb >> tepid_bbs.txt;
        ((count_tepid++))

   elif [ $freq_val -ge $low_average ] && [ $freq_val -lt $average ]; then
        echo $func_bb $bb >> breeze_bbs.txt;
        ((count_breeze++))

   elif [ $freq_val -ge $lower_average ] && [ $freq_val -lt $low_average ]; then
        echo $func_bb $bb  >> cool_bbs.txt;
        ((count_cool++))

   elif [ $freq_val -gt $lowest_average ] && [ $freq_val -lt $lower_average ]; then
        echo $func_bb $bb  >> cooler_bbs.txt;
        ((count_cooler++))

   elif [ $freq_val -le $lowest_average ]; then
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
