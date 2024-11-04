#!/bin/bash

project_id='ra'
workingdir="/data/cephfs-1/scratch/groups/romagnani/users/knighto_c/ngs/${project_id}"
fastqdir="${workingdir}/fastq"
libraries_dir="${workingdir}/scripts/libraries"

# Remove the libraries directory if it exists, then recreate it
if [ -d "$libraries_dir" ]; then
  rm -rf "$libraries_dir"
fi

mkdir -p "$libraries_dir"

# Loop through all directories in the fastq folder
for folder in "$fastqdir"/*; do

  # Extract the folder name
  folder_name=$(basename "$folder")

  # Skip folders containing 'FB' as they are ADT libraries
  if [[ "$folder_name" == *"FB"* ]]; then
    continue
  fi

  # Split the folder name based on underscores
  IFS='_' read -r donor_id_1 donor_id_2 origin celltype <<< "$folder_name"
  
  # Combine donor_id parts
  donor_id="${donor_id_1}_${donor_id_2}"

  # Search for the corresponding ADT folder that matches both the donor ID and the origin
  adt_folder=$(find "$fastqdir" -type d -name "*${donor_id}_${origin}*_FB*")

  # Check if the ADT folder was found
  if [[ -n "$adt_folder" ]]; then
    ADT_library_number=$(basename "$adt_folder")
    echo "Matching ADT folder found for donor $donor_id with origin $origin: $ADT_library_number"
  else
    echo "No matching ADT folder found for donor $donor_id with origin $origin"
    continue
  fi

  # Extract the GEX library number
  GEX_library_number=$(basename "$folder")

  # Output file path
  output_file="$libraries_dir/CITE_AMP_RA_${donor_id_1}_${donor_id_2}_${origin}_BT.csv"

  echo "Writing library file for donor $donor_id with GEX: ${GEX_library_number} and ADT: ${ADT_library_number}"

  # Write the configuration to the output file
  {
    echo "[gene-expression]"
    echo "reference,/data/cephfs-2/unmirrored/groups/romagnani/work/ref/hs/GRCh38-hardmasked-optimised-arc"
    echo "create-bam,false"
    echo "no-secondary,true"
    echo ""
    echo "[feature]"
    echo "reference,${workingdir}/scripts/AMP_ADT_list.csv"
    echo ""
    echo "[libraries]"
    echo "fastq_id,fastqs,feature_types"
    echo "${GEX_library_number},${fastqdir},Gene Expression"
    echo "${ADT_library_number},${fastqdir},Antibody Capture"
  } > "$output_file"

done
