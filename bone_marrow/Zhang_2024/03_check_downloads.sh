#!/bin/bash

#!/bin/bash

# Read each line from the metadata file
while IFS=',' read -r SRR GSM sample_name modality chemistry lane ethnicity mutation sex age sorted_celltype; do
    found=false
    # Check if files exist for the pattern in the current directory
    if ls "$HOME/scratch/ngs/BMMC/BMMC_fastq/${SRR}"* >/dev/null 2>&1; then
        echo "${SRR} found"
        found=true
    fi
    # Check if found is still false after checking for the current SRR
    if ! $found; then
        echo "ERROR: ${SRR} not found"
    fi
done < "$HOME/scratch/ngs/BMMC/BMMC_scripts/zhang_2024_metadata.csv"
