#!/bin/bash

project_id='penkava_2020'
workingdir="$HOME/scratch/ngs/${project_id}"
libraries_dir="${workingdir}/scripts/libraries"

# Check if the directory exists, if yes, remove it
if [ -d "$libraries_dir" ]; then
    rm -rf "$libraries_dir"
fi

# Create the directory again to ensure it's empty
mkdir -p "$libraries_dir"

while IFS=, read -r ENA r1_ftp r2_ftp lane age sex disease donor_id tissue cell_type assay chemistry modality; do

    if [[ $ENA == "ENA" ]]; then
        continue
    fi

    library_name="GEX_Penkava_2020_${disease}_${donor_id}_${tissue}_${cell_type}"
    output_file="${libraries_dir}/${library_name}.csv"

    if [[ ! -e "$output_file" ]]; then
        {
            echo "[gene-expression]"
            echo "reference,/fast/work/groups/ag_romagnani/ref/hs/GRCh38-hardmasked-optimised-arc"
            echo "create-bam,true"
            echo ""
            echo "[vdj]"
            echo "reference,/fast/work/groups/ag_romagnani/ref/hs/GRCh38-IMGT-VDJ-2024"
            echo ""
            echo "[libraries]"
            echo "fastq_id,fastqs,feature_types"
        } > "$output_file"
    fi
   if [[ "${modality}" == "GEX" ]]; then
        echo "${library_name}_GEX,${workingdir}/fastq/,Gene Expression" >> "$output_file"
   elif [[ "${modality}" == "VDJ-T" ]]; then
        echo "${library_name}_VDJ-T,${workingdir}/fastq/,VDJ-T" >> "$output_file"
   fi

done < "${workingdir}/scripts/penkava_2020_metadata.csv"
