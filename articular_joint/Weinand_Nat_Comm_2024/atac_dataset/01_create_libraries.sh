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

    library_name="${folder_name}_ATAC"
    output_file="${libraries_dir}/${library_name}.csv"
    echo "${folder_name},${workingdir}/fastq/${folder_name}" >> "$output_file"

done
