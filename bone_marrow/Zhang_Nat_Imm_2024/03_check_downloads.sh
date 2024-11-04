#!/bin/bash

project_id="zhang_2024"

workingdir="$HOME/scratch/ngs/${project_id}"

# Read each line from the metadata file
while IFS=',' read -r SRR GSM sample_name modality chemistry lane ethnicity mutation sex age sorted_celltype; do
    found=false
    # Check if files exist for the pattern in the current directory
    if ls "${workingdir}/fastq/${SRR}"* >/dev/null 2>&1; then
        echo "${SRR} found"
        found=true
    fi
    # Check if found is still false after checking for the current SRR
    if ! $found; then
        echo "ERROR: ${SRR} not found"
    fi
done < "${workingdir}/scripts/zhang_2024_metadata.csv"
