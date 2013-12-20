#!/usr/bin/env bash
#
# EXPortImagestoDITAA
# ===================
#
# This tool makes it possible to draw ASCII-art diagrams in your text or
# reStructuredText files.
#
# Description
#
# As long as the diagram is indented with spaces at least one space this tool
# tries to identify where you have your readable ASCII-art and produce a
# number of files. One PNG file, using the wonderful "ditaa" tool and one
# reStructuredText with the images removed and replaced with ".. image::"
# markup tags.
#
# Usage
# -----
#
# $ expiditaa <textfile.txt>
#
# The reStructuredText output is written to stdout.
#
# To-do
# -----
#
# * Make the script take stdin as input if no file is provided.
# * Use shell math to calculate the length of the ASCII-art diagram instead
#   of wc -l.
#

set -e

file=$1

if [ "$file" == "" -o "$file" == "-h" -o "$file" == "--help" ]; then
    echo "USAGE: $0 <text-file>"
    exit 0
fi

test -f $file || (echo "ERROR: Could not open file $file" >&2; exit 1)

name=$(basename ${file%.*}) # Extract the base file name without path.
max=$(wc -l $file | cut -d' ' -f1) # Count the number of rows in the file.

# Filter out potential ASCII diagrams in the format:
#  <line number>:<matching row>
text=`egrep -n -e '^ +[\||+|\/|-| +]+' $file`

IFS="
"

declare -a fig   # Array to store all ASCII-art diagrams in.
declare -a first # First row of each ASCII-art diagram.
declare -a last  # Last row of each ASCII-art diagram,.

last_line=0
count=0

#
# Traverse all lines in the matching output done earlier and keep track of
# which line in the original file every diagram starts and ends at, and move
# the actual ASCII-art to an array for later output.
#
for i in $text; do
    line=${i%%:*} # Get the line number to the left of the :
    row=${i##*:}  # .. And the text contents to the right of the :

    #
    # Continuous ASCII-art, detected, keep collecting rows and keep track of
    # for how many rows the picture consist of.
    #
    if [ $line == $[last_line+1] ]; then
        if [ "${first[$count]}" == "" ]; then
            first[$count]=$[line-2] # Just found a new ASCII-art diagram.
        fi
        fig[$count]="${fig[$count]}$last_row \n"
        last[$count]=$[line+1] # Keep track of text-lines in the ASCII-art.
    else
        fig[$count]="${fig[$count]}$last_row \n"
        last_line=0
        count=$[count+1]
    fi
    last_line=$line
    last_row=$row
done
fig[$count]="${fig[$count]}$last_row\n" # Tail of the last ASCII-art diagram

IFS="
"
last[0]=0
first[0]=0
sub=0
offset=$(wc -l $file | cut -d' ' -f1)
for i in $(seq 1 $[count]); do

    #
    # Output the PNG-picture.
    #
    echo -e ${fig[$i]} > ".$$.${name}-fig-${i}.txt" # Temporary file for ditaa
    ditaa ".$$.${name}-fig-${i}.txt" "${name}-fig-${i}.png" > /dev/null

    #
    # Calculate head and tail command arguments (number of lines to be copied
    # from the original file, extracting the actual ASCII-art diagram).
    #
    prev=$[i-1]
    diff=$[${first[$i]}-${last[$prev]}]
    tail -n$offset $file | head -n$diff # Output everything up to the diagram.
    sub=${first[$i]}
    sub=$[sub+$(wc -l ".$$.${name}-fig-${i}.txt" | cut -d' ' -f1)] # To-do
    offset=$[max-${sub}] # Start of next text to output (from end of the file).

    #
    # Replace the ASCII-art diagram with a reStructuredText markdown.
    #
    echo ".. image:: ${name}-fig-${i}.png"
    echo ""

    #
    # Cleanup.
    #
    rm ".$$.${name}-fig-${i}.txt"
done
tail -n$offset $file # The last contents of the file (after the last diagram).
