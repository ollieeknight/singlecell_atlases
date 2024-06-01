#!/bin/bash

project_id='burkhardt_2022'

project_dir="$HOME/scratch/ngs/$project_id"

mkdir -p "${project_dir}/outs/logs/"
cd "${project_dir}/outs"

for library_csv in "${project_dir}/scripts/libraries/"*; do

    library_id=$(basename "${library_csv%.*}")

    if [[ $library_csv == *_GEX* || $library_csv == *CITE* ]]; then

        output_folder="${project_dir}/outs/${library_id}/outs"

        # Check if the output file already exists
        if [ -d "$output_folder" ]; then
            echo "Output file exists for ${library_id}, skipping"
            continue
        fi

        echo "Submitting cellranger multi count for ${library_id}"
sbatch <<EOF
#!/bin/bash
#SBATCH --job-name ${library_id}
#SBATCH --output "${project_dir}/outs/logs/${library_id}_cellranger.out"
#SBATCH --error "${project_dir}/outs/logs/${library_id}_cellranger.out"
#SBATCH --ntasks=32
#SBATCH --mem=96000
#SBATCH --time=96:00:00
num_cores=\$(nproc)
container="${HOME}/scratch/tmp/oscar-count_latest.sif"
cd "${project_dir}/outs/"
apptainer run -B /fast,/data "\$container" cellranger multi --id "${library_id}" --csv "${library_csv}" --localcores "\$num_cores" --localmem 92
rm -r "${project_dir}/outs/${library_id}/SC_MULTI_CS" "${project_dir}/outs/${library_id}/_"*
EOF

    elif [[ $library_csv == *ATAC* ]]; then

        echo "Submitting cellranger-atac count for ${library_id}"

        output_folder="${project_dir}/outs/${library_id}/outs"

        # Check if the output file already exists
        if [ -d "$output_folder" ]; then
            echo "Output file exists for ${library_id}, skipping"
            continue
        fi

    while IFS= read -r line; do
        # Check if the line contains "ATAC"
        if [[ $line == *ATAC* ]]; then
            # Extract fastq name and directory from the line
            IFS=',' read -r fastq_name fastq_dir <<< "$line"

            # Concatenate the fastq name to fastq_names variable
            if [ -n "$fastq_names" ]; then
                fastq_names="${fastq_names},${fastq_name}"
            else
                fastq_names="$fastq_name"
            fi

            # Concatenate the fastq directory to fastq_dirs variable
            if [ -n "$fastq_dirs" ]; then
                fastq_dirs="${fastq_dirs},${fastq_dir}"
            else
                fastq_dirs="$fastq_dir"
            fi
        fi
    done < "${library_csv}"

sbatch <<EOF
#!/bin/bash
#SBATCH --job-name ${library_id}
#SBATCH --output "${project_dir}/outs/logs/${library_id}_cellranger.out"
#SBATCH --error "${project_dir}/outs/logs/${library_id}_cellranger.out"
#SBATCH --ntasks=64
#SBATCH --mem=200000
#SBATCH --time=96:00:00
num_cores=\$(nproc)
container="${HOME}/scratch/tmp/oscar-count_latest.sif"
cd "${project_dir}/outs/"
apptainer run -B /fast,/data \$container cellranger-atac count --id $library_id --reference /fast/work/groups/ag_romagnani/ref/hs/GRCh38-hardmasked-optimised-arc --fastqs $fastq_dirs --sample $fastq_names --localcores \$num_cores --localmem 190 --chemistry ARC-v1
rm -r "${project_dir}/outs/${library_id}/SC_ATAC_COUNTER_CS" "${project_dir}/outs/${library_id}/_"*
EOF
    fi
fastq_names=''
fastq_dirs=''

done
