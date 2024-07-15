#!/bin/bash

project_id='hashemi_2024'
workingdir="$HOME/scratch/ngs/${project_id}"
libraries_dir="${workingdir}/scripts/libraries"

# Check if the directory exists, if yes, remove it
if [ -d "$libraries_dir" ]; then
    rm -rf "$libraries_dir"
fi

# Create the directory again to ensure it's empty
mkdir -p "$libraries_dir"

# Read metadata CSV file line by line
while IFS=, read -r SRR GSM tissue_code donor_id tissue age sex modality; do
    echo "Processing metadata entry: $SRR"

    found_match=false

    for folder in "${workingdir}/fastq/"*; do
        folder_name=$(basename "$folder")
        if [[ "${folder_name}" == "${SRR}" ]]; then
            found_match=true
            break
        fi
    done

    if [[ "$found_match" == false ]]; then
        echo "No matching folder found for SRR: $SRR"
        continue
    fi

    library_name="GEX_Hashemi_2024_${donor_id}_${tissue_code}"
    output_file="${libraries_dir}/${library_name}.csv"
    echo "Creating output file: $output_file"

    if [[ "${modality}" == "GEX" ]]; then

        if [[ ! -f "$output_file" ]]; then
            {
                echo "[gene-expression]"
                echo "reference,/fast/work/groups/ag_romagnani/ref/hs/GRCh38-hardmasked-optimised-arc"
                echo "create-bam,true"
                echo ""
                echo "[libraries]"
                echo "fastq_id,fastqs,feature_types"
            } > "$output_file"
            echo "Header added to: $output_file"
        fi

        echo "GEX_Hashemi_2024_${donor_id}_${tissue_code}_${modality},${workingdir}/fastq/${SRR},Gene Expression" >> "$output_file"
        echo "Added GEX line to: $output_file"
    fi

done < "${workingdir}/scripts/hashemi_2024_metadata.csv"
