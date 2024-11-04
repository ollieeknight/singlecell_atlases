#!/bin/bash

project_id="zhang_2024"

workingdir="$HOME/scratch/ngs/${project_id}"

cd ${workingdir}/fastq

for file in *_1.fastq.gz; do
    sample="${file%_1.fastq.gz}"

    SRR=""
    while IFS=',' read -r SRR GSM sample_name modality chemistry lane ethnicity mutation sex age sorted_celltype; do
        if [[ "${sample}" == "$SRR" ]]; then
            break
        fi
    done < "${workingdir}/scripts/zhang_2024_metadata.csv"

    if [[ -z "$SRR" ]]; then
        echo "ERROR: No match found for ${sample##*/}"
        continue
    fi

    file_count=0

    if [ -e "${SRR}_4.fastq.gz" ]; then
        file_count=4
    elif [ -e "${SRR}_3.fastq.gz" ]; then
        file_count=3
    elif [ -e "${SRR}_2.fastq.gz" ]; then
        file_count=2
    fi

    echo "Renaming $SRR to ${sample_name}_S1_L0${lane} across $file_count files"
    case $file_count in
        2)
            mv "${SRR}_1.fastq.gz" "${sample_name}_S1_L0${lane}_R1_001.fastq.gz"
            mv "${SRR}_2.fastq.gz" "${sample_name}_S1_L0${lane}_R2_001.fastq.gz"
            ;;
        3)
            mv "${SRR}_1.fastq.gz" "${sample_name}_S1_L0${lane}_I1_001.fastq.gz"
            mv "${SRR}_2.fastq.gz" "${sample_name}_S1_L0${lane}_R1_001.fastq.gz"
            mv "${SRR}_3.fastq.gz" "${sample_name}_S1_L0${lane}_R2_001.fastq.gz"
            ;;
        4)
            mv "${SRR}_1.fastq.gz" "${sample_name}_S1_L0${lane}_I1_001.fastq.gz"
            mv "${SRR}_2.fastq.gz" "${sample_name}_S1_L0${lane}_I2_001.fastq.gz"
            mv "${SRR}_3.fastq.gz" "${sample_name}_S1_L0${lane}_R1_001.fastq.gz"
            mv "${SRR}_4.fastq.gz" "${sample_name}_S1_L0${lane}_R2_001.fastq.gz"
    esac
done
