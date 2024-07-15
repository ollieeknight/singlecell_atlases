#!/bin/bash

project_id='hashemi_2024'

workingdir="$HOME/scratch/ngs/${project_id}"

cd "${workingdir}/fastq" || exit

for folder in ${workingdir}/fastq/*; do
    folder_name=$(basename $folder)
    SRR=""
    while IFS=, read -r SRR GSM tissue_code donor_id tissue age sex modality; do
        if [[ "${folder_name}" == "${SRR}" ]]; then
            break
        fi
    done < "${workingdir}/scripts/hashemi_2024_metadata.csv"

    if [[ -z "${SRR}" ]]; then
        echo "ERROR: No match found for ${folder_name} in metadata"
        continue
    fi

    file_count=0

    if [[ -e "${SRR}/${SRR}_4.fastq.gz" ]]; then
        file_count=4
    elif [[ -e "${SRR}/${SRR}_2.fastq.gz" ]]; then
        file_count=2
    fi

    case $file_count in
        2)
            echo "Renaming ${SRR} to GEX_Hashemi_2024_${donor_id}_${tissue_code}_${modality} across ${file_count} files"
            mv "${SRR}/${SRR}_1.fastq.gz" "${SRR}/GEX_Hashemi_2024_${donor_id}_${tissue_code}_${modality}_S1_L001_I1_001.fastq.gz"
            mv "${SRR}/${SRR}_2.fastq.gz" "${SRR}/GEX_Hashemi_2024_${donor_id}_${tissue_code}_${modality}_S1_L001_R1_001.fastq.gz"
            mv "${SRR}/${SRR}_3.fastq.gz" "${SRR}/GEX_Hashemi_2024_${donor_id}_${tissue_code}_${modality}_S1_L001_R2_001.fastq.gz"
            ;;
        4)
            echo "Renaming ${SRR} to GEX_Hashemi_2024_${donor_id}_${tissue_code}_${modality} across ${file_count} files"
            mv "${SRR}/${SRR}_1.fastq.gz" "${SRR}/GEX_Hashemi_2024_${donor_id}_${tissue_code}_${modality}_S1_L001_I1_001.fastq.gz"
            mv "${SRR}/${SRR}_2.fastq.gz" "${SRR}/GEX_Hashemi_2024_${donor_id}_${tissue_code}_${modality}_S1_L001_I2_001.fastq.gz"
            mv "${SRR}/${SRR}_3.fastq.gz" "${SRR}/GEX_Hashemi_2024_${donor_id}_${tissue_code}_${modality}_S1_L001_R1_001.fastq.gz"
            mv "${SRR}/${SRR}_4.fastq.gz" "${SRR}/GEX_Hashemi_2024_${donor_id}_${tissue_code}_${modality}_S1_L001_R2_001.fastq.gz"
            ;;
        *)
            echo "ERROR: No recognized file count for ${SRR}"
            ;;
    esac
done
