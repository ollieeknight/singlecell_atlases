#!/bin/bash

project_id='mossawi_2019'
workingdir="$HOME/scratch/ngs/${project_id}"
libraries_dir="${workingdir}/scripts/libraries"

# Check if the directory exists, if yes, remove it
if [ -d "$libraries_dir" ]; then
    rm -rf "$libraries_dir"
fi

# Create the directory again to ensure it's empty
mkdir -p "$libraries_dir"

# Declare associative arrays to track processed entries
declare -A processed_entries

# Read metadata CSV file line by line
while IFS=, read -r ENA donor_id age sex origin sorted_celltype chemistry lane r1_fastq r2_fastq; do

    if [[ $ENA == "ENA" ]]; then
        continue
    fi


    library_name="GEX_Mossawi_2019_${donor_id}_${origin}_${sorted_celltype}"
    output_file="${libraries_dir}/${library_name}.csv"

    # Create header if this combination has not been processed
    if [[ ! -f "$output_file" ]]; then
        {
            echo "[gene-expression]"
            echo "reference,/fast/work/groups/ag_romagnani/ref/hs/GRCh38-hardmasked-optimised-arc"
            echo "create-bam,false"
            echo ""
            echo "[libraries]"
            echo "fastq_id,fastqs,feature_types"
        } > "$output_file"
        echo "Header added to: $output_file"
    fi

    # Define a unique key for tracking processed lines
    entry_key="${library_name}"

    if [[ -z "${processed_entries[$entry_key]}" ]]; then
        echo "${library_name},${workingdir}/fastq/,Gene Expression" >> "$output_file"
        echo "Added GEX line to: $output_file"
        processed_entries["$entry_key"]=1
    fi

done < "${workingdir}/scripts/${project_id}_metadata.csv"
