#!/bin/bash

project_id='amp_zhang_2023'

workingdir="$HOME/scratch/ngs/${project_id}"

libraries_dir="${workingdir}/scripts/libraries"

if [ -d "$libraries_dir" ]; then
  rm -rf "$libraries_dir"
fi

mkdir -p "$libraries_dir"

for library_directory in "$workingdir"/fastq/gex/*; do
    gex_library=$(basename "$library_directory")
    output_file="$libraries_dir/CITE_AMP_RA_${gex_library}.csv"

    # Initialize donor_id_to_match
    donor_id_to_match=""

    # Find donor ID from gex library
    while IFS=, read -r fastq_name syn_id visit donor_id library_id; do
        # Skip the header line
        if [[ "$fastq_name" == "fastq_name" ]]; then
            continue
        fi

        if [[ "$library_id" == "$gex_library" ]]; then
            donor_id_to_match="$donor_id"
            visit_to_match=$visit
            echo "Matching $donor_id_to_match visit $visit_to_match for $gex_library"
            break
        fi
    done < "${workingdir}/scripts/fastq_gex_metadata.csv"

    # Check if donor_id_to_match was found
    if [[ -z "$donor_id_to_match" ]]; then
        echo "No matching donor ID found for gex_library: $gex_library"
    fi

    # Initialize adt_library
    adt_library=""

    # Find library ID from donor ID in adt metadata
    while IFS=, read -r fastq_name syn_id visit current_donor_id library_id; do
        # Skip the header line
        if [[ "$fastq_name" == "fastq_name" ]]; then
            continue
        fi

        if [[ "$current_donor_id" == "$donor_id_to_match" && "$visit_to_match" == "$visit" ]]; then
            adt_library="$library_id"
            echo "For $donor_id_to_match visit $visit_to_match matched $gex_library to $adt_library with $visit"
            break
        fi
    done < "${workingdir}/scripts/fastq_adt_metadata.csv"

    # Check if adt_library was found
    if [[ -z "$adt_library" ]]; then
        echo "No matching library found in adt metadata for donor ID: $donor_id_to_match"
    fi

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
        echo "${gex_library},/data/gpfs-1/scratch/users/knighto_c/ngs/amp_zhang_2023/fastq/gex,Gene Expression"
        echo "${adt_library},/data/gpfs-1/scratch/users/knighto_c/ngs/amp_zhang_2023/fastq/adt,Antibody Capture"
    } > "$output_file"
done

