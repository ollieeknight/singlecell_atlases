#!/bin/bash

project_id="williams_2021"

workingdir="$HOME/scratch/ngs/${project_id}"

cd ${workingdir}/fastq

for file in *_1.fastq.gz; do
    sample="${file%_1.fastq.gz}"

    SRR=""
    while IFS=',' read -r SRR SAMN disease_state SRX GSM donor_id tissue replicate; do
        if [[ "${sample}" == "$SRR" ]]; then
            break
        fi
    done < "${workingdir}/scripts/metadata.csv"

    if [[ -z "$SRR" ]]; then
        echo "ERROR: No match found for ${sample##*/}"
        continue
    fi

    echo "Renaming $SRR to ${donor_id}_${tissue}_${disease_state}_S1_L00${replicate}"
    mv "${SRR}_1.fastq.gz" "${donor_id}_${tissue}_${disease_state}_S1_L00${replicate}_I1_001.fastq.gz"
    mv "${SRR}_2.fastq.gz" "${donor_id}_${tissue}_${disease_state}_S1_L00${replicate}_R1_001.fastq.gz"
    mv "${SRR}_3.fastq.gz" "${donor_id}_${tissue}_${disease_state}_S1_L00${replicate}_R2_001.fastq.gz"

done
