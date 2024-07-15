#!/bin/bash

project_id='amp_sle_2024'

workingdir="${HOME}/scratch/ngs/${project_id}"

libraries_dir="${workingdir}/scripts/libraries"

if [ -d "$libraries_dir" ]; then
  rm -rf "$libraries_dir"
fi

mkdir -p "$libraries_dir"

for library_directory in "$workingdir"/fastq/*; do

    if [ -d "${library_directory}" ]; then

    gex_library=$(basename "$library_directory")
    output_name="${gex_library#AMPSLEkid_cells_}"
    output_file="$libraries_dir/CITE_AMP_SLE_${output_name}.csv"

    {
        echo "[gene-expression]"
        echo "reference,/fast/work/groups/ag_romagnani/ref/hs/GRCh38-hardmasked-optimised-arc"
        echo "create-bam,false"
        echo "no-secondary,true"
        echo ""
        echo "[libraries]"
        echo "fastq_id,fastqs,feature_types"
        echo "${gex_library},/data/gpfs-1/scratch/users/knighto_c/ngs/${project_id}/fastq,Gene Expression"
    } > "$output_file"
fi
done

