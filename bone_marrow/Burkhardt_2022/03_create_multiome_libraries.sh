#!/bin/bash

project_id='burkhardt_2022'

workingdir="$HOME/scratch/ngs/${project_id}"

libraries_dir="${workingdir}/scripts/libraries"

if [ -d "$libraries_dir" ]; then
    rm -rf "$libraries_dir"
fi

mkdir -p "$libraries_dir"

for library_directory in $workingdir/fastq/CITE*/; do
    library_name=$(basename "$library_directory")
    cleaned_library_name=$(echo "$library_name" | sed 's/_CITE$//')
    output_file="$libraries_dir/${cleaned_library_name}.csv"

    echo "Creating new library file ${output_file}"

    {
        echo "[gene-expression]"
        echo "reference,/fast/work/groups/ag_romagnani/ref/hs/GRCh38-hardmasked-optimised-arc"
	echo "create-bam,false"
        echo ""
        echo "[feature]"
        echo "reference,${workingdir}/scripts/titrated_ADT_list.csv"
        echo ""
        echo "[libraries]"
        echo "fastq_id,fastqs,feature_types"
    } > "$output_file"

    for sub_directory in "$library_directory"*/; do
        if [[ $sub_directory == *"0_1"* ]]; then
            modality="Antibody Capture"
        elif [[ $sub_directory == *"1_1"* ]]; then
            modality="Gene Expression"
        else
            modality="Unknown_Modality"
        fi
        echo "bamtofastq,$sub_directory,$modality" >> "$output_file"
    done
done

for library_directory in $workingdir/fastq/*Multiome*GEX*/; do
    library_name=$(basename "$library_directory")

    output_file="$libraries_dir/${library_name}.csv"

    echo "Creating new library file: ${output_file}"

    {
        echo "[gene-expression]"
        echo "reference,/fast/work/groups/ag_romagnani/ref/hs/GRCh38-hardmasked-optimised-arc"
        echo "chemistry,ARC-v1"
        echo "create-bam,false"
        echo ""
        echo "[libraries]"
        echo "fastq_id,fastqs,feature_types"
    } > "$output_file"

    for sub_directory in "$library_directory"*/; do
        echo "bamtofastq,$sub_directory,Gene Expression" >> "$output_file"
    done
done

for library_directory in $workingdir/fastq/*ATAC*/; do
    library_name=$(basename "$library_directory")

    output_file="$libraries_dir/${library_name}.csv"

    echo "Creating new library file: ${output_file}"

    first_entry=true

    for sub_directory in "$library_directory"*/; do
        if $first_entry; then
            echo "bamtofastq,$sub_directory" > "$output_file"
            first_entry=false
        else
            echo "bamtofastq,$sub_directory" >> "$output_file"
        fi
    done
done
