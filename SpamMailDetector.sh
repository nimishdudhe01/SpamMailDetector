#!/bin/bash

echo -n > oc
echo -n > P_N_words
echo -n > P_S_words
echo -n > result1
echo -n > result2

items=$(($(cat data | wc -l)-2))

freq_N_words=0
freq_S_words=0

i=0

cat data | tail -n $items > input

cat input | while read line
do
	declare -a n_words_freq
	declare -a s_words_freq

	freq_n="$(echo "$line" | cut -d " " -f 2 | cut -d "," -f 1) "
	freq_s="$(echo "$line" | cut -d " " -f 2 | cut -d "," -f 2) "
	word=$(echo $line | cut -d " " -f 1)
	cat $1 | tr " " "\n" | grep -i -c $(echo "$word" | sed {s/'#'/'\\|'/}) | tr " " "\n" >> oc

	total_words_N=$(($total_words_N+$freq_n))
	total_words_S=$(($total_words_S+$freq_s))
	n_words_freq+=$freq_n
        s_words_freq+=$freq_s

	i=$(($i+1))
	if [ $i -eq 5 ]
	then
		echo -e $n_words_freq $total_words_N "\n"$s_words_freq $total_words_S >> oc
	fi
done

i=1
while [ $i -ne 6 ]
do
	echo "scale=6; " "("$(($(cat oc | head -n $(($(($items))+1)) | tail -n 1 | cut -d " " -f $i)))/$(($(cat oc | head -n $(($(($items))+1)) | tail -n 1 | cut -d " " -f $(($(($items))+1)))))")" | bc >> P_N_words
	i=$(($i+1))
done

i=1
while [ $i -ne 6 ]
do
        echo "scale=6; " "("$(($(cat oc | head -n $(($(($items))+2)) | tail -n 1 | cut -d " " -f $i)))/$(($(cat oc | head -n $(($(($items))+2)) | tail -n 1 | cut -d " " -f $(($(($items))+1)))))")" | bc >> P_S_words
        i=$(($i+1))
done

i=1
str='scale=10; 1'
cat P_N_words | while read line
do
	str+=*0$line^"$(cat oc | head -n $i | tail -n 1)"
	if [ $i -eq 5 ]
	then
		echo $str | bc >> result1
	fi
	i=$(($i+1))
done

i=1
str='scale=10; 1'
cat P_S_words | while read line
do
        str+=*0$line^"$(cat oc | head -n $i | tail -n 1)"
        if [ $i -eq 5 ]
        then
                echo $str | bc >> result1
        fi
        i=$(($i+1))
done

cat result1 | sort -n > result2

diff result1 result2 >/dev/null
if [ $? -eq 0 ]
then
	echo The mail can be classified as SPAM.
else
	echo The mail can be classified as Normal.
fi

rm oc
rm result1 result2
rm P_S_words
rm P_N_words
rm input


