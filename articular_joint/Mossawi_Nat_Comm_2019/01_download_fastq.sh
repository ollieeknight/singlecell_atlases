#!/bin/bash

project_id="mossawi_2019"
workingdir="$HOME/scratch/ngs/${project_id}"

csv_file="${workingdir}/scripts/${project_id}_metadata.csv"

mkdir -p "${workingdir}/fastq/logs/"

# Skip the header and read each line from the CSV file
while IFS=',' read -r ENA donor_id age sex origin sorted_celltype chemistry lane r1_fastq r2_fastq; do

    if [[ $ENA == "ENA" ]]; then
        continue
    fi

    # Define the output filenames
    r1_output="GEX_Mossawi_2019_${donor_id}_${origin}_${sorted_celltype}_${lane}_R1_001.fastq.gz"
    r2_output="GEX_Mossawi_2019_${donor_id}_${origin}_${sorted_celltype}_${lane}_R2_001.fastq.gz"

    # Download the FASTQ files using wget and rename them
    wget -O "${workingdir}/fastq/${r1_output}" "${r1_fastq}"
    wget -O "${workingdir}/fastq/${r2_output}" "${r2_fastq}"
    sleep 300
done < "${workingdir}/scripts/mossawi_2019_metadata.csv"
