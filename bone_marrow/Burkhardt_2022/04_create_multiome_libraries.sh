#!/bin/bash

base_dir="/data/gpfs-1/users/knighto_c/scratch/ngs/IPS/fastq/fastq_GEX"

# Define the directory path
libraries_dir="$HOME/scratch/ngs/IPS/IPS_scripts/libraries/"

# Check if the directory exists
if [ -d "$libraries_dir" ]; then
    # If it exists, remove it
    rm -rf "$libraries_dir"
fi

# Create the directory again to ensure it's empty
mkdir -p "$libraries_dir"

# Loop through each library directory
for library_directory in "$base_dir"/CITE*/; do
    # Extract the library name from the directory path
    library_name=$(basename "$library_directory")

    # Define the output file for the current library
    output_file="$HOME/scratch/ngs/IPS/IPS_scripts/libraries/${library_name}.csv"

    # Print library creation
    echo "Creating new library file: ${output_file}"

    # Add gene expression and feature reference to the library output
    {
        echo "[gene-expression]"
        echo "reference,/fast/work/groups/ag_romagnani/ref/hs/GRCh38-hardmasked-optimised-arc"
	echo "no-bam,true"
        echo ""
        echo "[feature]"
        echo "reference,/fast/scratch/users/knighto_c/ngs/IPS/IPS_scripts/ADT_list.csv"
        echo ""
        echo "[libraries]"
        echo "fastq_id,fastqs,feature_types"
    } > "$output_file"  # Create the output file and add the headers

    # Loop through each subdirectory within the library directory
    for sub_directory in "$library_directory"*/; do
        # Check if the subdirectory contains either '0_1' or '1_1'
        if [[ $sub_directory == *"0_1"* ]]; then
            modality="Antibody Capture"
        elif [[ $sub_directory == *"1_1"* ]]; then
            modality="Gene Expression"
        else
            modality="Unknown_Modality"
        fi

        # Write the row for each fastq file in the subdirectory
        echo "bamtofastq,$sub_directory,$modality" >> "$output_file"
    done
done

# Loop through each library directory
for library_directory in "$base_dir"/Multiome*/; do
    # Extract the library name from the directory path
    library_name=$(basename "$library_directory")

    # Define the output file for the current library
    output_file="$HOME/scratch/ngs/IPS/IPS_scripts/libraries/${library_name}.csv"

    # Print library creation
    echo "Creating new library file: ${output_file}"

    # Add gene expression and feature reference to the library output
    {
        echo "[gene-expression]"
        echo "reference,/fast/work/groups/ag_romagnani/ref/hs/GRCh38-hardmasked-optimised-arc"
        echo "chemistry,ARC-v1"
        echo "no-bam,true"
        echo ""
	echo "[libraries]"
        echo "fastq_id,fastqs,feature_types"
    } > "$output_file"  # Create the output file and add the headers

    # Loop through each subdirectory within the library directory
    for sub_directory in "$library_directory"*/; do
        # Write the row for each fastq file in the subdirectory
        echo "bamtofastq,$sub_directory,Gene Expression" >> "$output_file"
    done
done
