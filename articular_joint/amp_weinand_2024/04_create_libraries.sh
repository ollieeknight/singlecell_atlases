#!/bin/bash

project_id='weinand_2024'
workingdir="$HOME/scratch/ngs/${project_id}"
libraries_dir="${workingdir}/scripts/libraries"

# Check if the directory exists, if yes, remove it
if [ -d "$libraries_dir" ]; then
    rm -rf "$libraries_dir"
fi

# Create the directory again to ensure it's empty
mkdir -p "$libraries_dir"

for folder in ${workingdir}/fastq/*; do
    folder_name=$(basename "$folder")

    while IFS=, read -r SRR assay chemistry modality site experiment tissue sample_name sex donor_id disease sample_id; do
        if [[ "${folder_name}" == "${SRR}" ]]; then
            break
        fi
    done < "${workingdir}/scripts/weinand_2024_metadata.csv"

    if [[ "${modality}" == "GEX" ]]; then
        library_name="${assay}_${donor_id}_${disease}_${tissue}_${site}_GEX"
        output_file="${libraries_dir}/${library_name}.csv"

        if [[ ! -e "$output_file" ]]; then
            {
                echo "[gene-expression]"
                echo "reference,/fast/work/groups/ag_romagnani/ref/hs/GRCh38-hardmasked-optimised-arc"
                echo "create-bam,true"
                echo "chemistry,ARC-v1"
                echo ""
                echo "[libraries]"
                echo "fastq_id,fastqs,feature_types"
            } > "$output_file"
        fi

        echo "${library_name},${workingdir}/fastq/${SRR},Gene Expression" >> "$output_file"
    elif [[ "${modality}" == "ATAC" && "${chemistry}" == "ARC-v1" ]]; then
        library_name="${assay}_${donor_id}_${disease}_${tissue}_${site}_ATAC"
        output_file="${libraries_dir}/${library_name}.csv"

        echo "${library_name},${workingdir}/fastq/${SRR}" >> "$output_file"
    elif [[ "${modality}" == "ATAC" && "${chemistry}" == "ATAC" ]]; then
        library_name="${assay}_${donor_id}_${disease}_${tissue}_${site}_ATAC"
        output_file="${libraries_dir}/${library_name}.csv"

        echo "${library_name},${workingdir}/fastq/${SRR}" >> "$output_file"
    fi

done
