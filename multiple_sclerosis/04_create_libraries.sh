#!/bin/bash

project_id='schafflick_2020'

workingdir="$HOME/scratch/ngs/${project_id}"

# Define the directory path
libraries_dir="$HOME/scratch/ngs/${project_id}/scripts/libraries/"

# Check if the directory exists
if [ -d "$libraries_dir" ]; then
    # If it exists, remove it
    rm -rf "$libraries_dir"
fi

# Create the directory again to ensure it's empty
mkdir -p "$libraries_dir"

# Loop through each library directory
for library_directory in $workingdir/fastq/GEX*; do
    library_name=$(basename "$library_directory")

    output_file="${workingdir}/scripts/libraries/${library_name}.csv"

    echo "Creating new library file: ${output_file}"

    # Add gene expression and feature reference to the library output
    {
        echo "[gene-expression]"
        echo "reference,/fast/work/groups/ag_romagnani/ref/hs/GRCh38-hardmasked-optimised-arc"
        echo "create-bam,false"
        echo ""
	echo "[libraries]"
        echo "fastq_id,fastqs,feature_types"
    } > "$output_file"  # Create the output file and add the headers

    # Loop through each subdirectory within the library directory
    for sub_directory in "$library_directory"*/*; do
        # Write the row for each fastq file in the subdirectory
        echo "bamtofastq,$sub_directory,Gene Expression" >> "$output_file"
    done
done
