#!/bin/bash

libraries=$HOME/scratch/ngs/BMMC/BMMC_scripts/libraries

if [ -d "${libraries}" ]; then
    rm -r $libraries
fi

mkdir -p $libraries

declare -A added_lines

# Read each line from the CSV file
while IFS=',' read -r SRR GSM sample_name modality chemistry lane ethnicity mutation sex age sorted_celltype; do
    # Skip the first line if it matches the header
    if [[ "$SRR" == "SRR" ]]; then
        continue
    fi

    # Determine the modality based on the sample_id
    if [[ "$modality" == "GEX" ]]; then
        full_modality="Gene Expression"
        library_id="${sample_name%"_GEX"}"
    elif [[ "$modality" == "ADT" ]]; then
        full_modality="Antibody Capture"
        library_id="${sample_name%"_ADT"}"
    elif [[ "$modality" == "HTO" ]]; then
        full_modality="Antibody Capture"
        library_id="${sample_name%"_HTO"}"
    fi

    echo "For sample $sample_name of $chemistry chemistry, $modality is being added"

    library_output="${libraries}/${library_id}.csv"

    # Check if the sample library already exists
    if [ ! -f "${library_output}" ]; then
        echo "Creating new library file: ${library_output}"  # Debugging: Print library creation
        echo "[gene-expression]" > "${library_output}"
        echo "reference,/fast/work/groups/ag_romagnani/ref/hs/GRCh38-hardmasked-optimised-arc" >> "${library_output}"
        echo "create-bam,false" >> "${library_output}"
#        if [ "$chemistry" == "SC3Pv3" ]; then
#            echo "chemistry,${chemistry}" >> "${library_output}"
#        elif [ "$chemistry" == "SC3Pv3HT" ]; then
#            echo "chemistry,${chemistry}" >> "${library_output}"
#        elif [ "$chemistry" == "ADT" ] || [ "$chemistry" == "HTO" ]; then
#            continue
#        fi
        echo "" >> "${library_output}"
        echo "[feature]" >> "${library_output}"
        echo "reference,$HOME/scratch/ngs/BMMC/BMMC_scripts/full_ADT_list.csv" >> "${library_output}"
        echo "" >> "${library_output}"

        # Write the header to the CSV file
	echo "[libraries]" >> "${library_output}"
        echo "fastq_id,fastqs,feature_types" >> "${library_output}"
    fi

    matching_fastq_files=($(find "${HOME}/scratch/ngs/BMMC/BMMC_fastq/" -type f -name "${sample_name}*.fastq.gz"))

    # Iterate over each matching FASTQ file
    for fastq_file in "${matching_fastq_files[@]}"; do
        # Extract the directory containing the FASTQ file
        directory=$(dirname "${fastq_file}")
        # Check if the line has already been added
        line="${sample_name},${directory},${full_modality}"
        if [ -z "${added_lines[$line]}" ]; then
            # Append the line to the library file
            echo "$line" >> "${library_output}"
            # Mark the line as added
            added_lines["$line"]=1
        fi
    done

done < ${HOME}/scratch/ngs/BMMC/BMMC_scripts/zhang_2024_metadata.csv
