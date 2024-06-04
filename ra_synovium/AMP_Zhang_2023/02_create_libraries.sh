#!/bin/bash

project_id='amp_zhang_2023'
workingdir="${HOME}/scratch/ngs/${project_id}"
libraries_dir="${workingdir}/scripts/libraries"

# Remove the libraries directory if it exists, then recreate it
if [ -d "$libraries_dir" ]; then
  rm -rf "$libraries_dir"
fi

mkdir -p "$libraries_dir"

# Read the AMP metadata CSV file
while IFS=, read -r donor_id pipeline_date site disease treatment biopsied sex age CDAI disease_duration tissue_type krenn_lining krenn_inflammation GEX_library_number ADT_library_number ATAC_library_number DAS28_CRP DAS28_ESR CCP; do
    # Skip the header line
    if [[ "$donor_id" == "donor_id" ]]; then
         continue
    fi

    output_file="$libraries_dir/CITE_AMP_RA_${GEX_library_number}.csv"

    # Check if the GEX library directory exists
    if [[ -d ${workingdir}/fastq/gex/${GEX_library_number} ]]; then

        echo "Writing library file for donor $donor_id with ${GEX_library_number} and ${ADT_library_number}"
        echo "GEX:"
        ls ${workingdir}/fastq/gex/$GEX_library_number
        echo "ADT:"
        ls ${workingdir}/fastq/adt/$ADT_library_number
        echo "---"
        # Write the configuration to the output file
        {
            echo "[gene-expression]"
            echo "reference,/fast/work/groups/ag_romagnani/ref/hs/GRCh38-hardmasked-optimised-arc"
            echo "create-bam,false"
            echo "no-secondary,true"
            echo "r1-length,26"
            echo ""
            echo "[feature]"
            echo "reference,${workingdir}/scripts/AMP_ADT_list.csv"
            echo "r1-length,26"
            echo ""
            echo "[libraries]"
            echo "fastq_id,fastqs,feature_types"
            echo "${GEX_library_number},${workingdir}/fastq/gex,Gene Expression"
            echo "${ADT_library_number},${workingdir}/fastq/adt,Antibody Capture"
        } > "$output_file"
    fi
done < "${workingdir}/scripts/AMP_RA_metadata.csv"
