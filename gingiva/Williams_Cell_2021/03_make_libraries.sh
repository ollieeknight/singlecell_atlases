#!/bin/bash

project_id="williams_2021"

workingdir="$HOME/scratch/ngs/${project_id}"

libraries=${workingdir}/scripts/libraries

if [ -d "${libraries}" ]; then
    rm -r $libraries
fi

mkdir -p $libraries

declare -A added_lines

# Read each line from the CSV file
while IFS=',' read -r SRR SAMN disease_state SRX GSM donor_id tissue replicate; do
    # Skip the first line if it matches the header
    if [[ "$SRR" == "SRR" ]]; then
        continue
    fi

    library_id="GEX_Williams_2021_${donor_id}_${tissue}_${disease_state}"
    sample_name="$library_id"  # Set sample_name to match the library_id

    library_output="${libraries}/${library_id}.csv"

    # Check if the sample library already exists
    if [ ! -f "${library_output}" ]; then
        echo "Creating new library file: ${library_output}"  # Debugging: Print library creation
        echo "[gene-expression]" > "${library_output}"
        echo "reference,/data/cephfs-2/unmirrored/groups/romagnani/work/ref/hs/GRCh38-hardmasked-optimised-arc" >> "${library_output}"
        echo "create-bam,false" >> "${library_output}"
        echo "no-secondary,true" >> "${library_output}"
        echo "" >> "${library_output}"

        echo "[libraries]" >> "${library_output}"
        echo "fastq_id,fastqs,feature_types" >> "${library_output}"
    fi

    # Find matching FASTQ files
    matching_fastq_files=($(find "${workingdir}/fastq/" -type f -name "${donor_id}_${tissue}_${disease_state}_S1_L00${replicate}*.fastq.gz"))

    # Iterate over each matching FASTQ file
    for fastq_file in "${matching_fastq_files[@]}"; do
        directory=$(dirname "${fastq_file}")
        line="${donor_id}_${tissue}_${disease_state},${directory},Gene Expression"
        # Check if the line has already been added
        if [ -z "${added_lines[$line]}" ]; then
            echo "$line" >> "${library_output}"
            added_lines["$line"]=1  # Mark the line as added
        fi
    done

done < ${workingdir}/scripts/metadata.csv
