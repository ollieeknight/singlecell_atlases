#!/bin/bash

project_id='weinand_2024'
workingdir="$HOME/scratch/ngs/${project_id}"

# Create necessary directories
mkdir -p "${workingdir}/outs/logs/"
cd "${workingdir}/outs"

# Loop through library CSV files
for library_csv in "${workingdir}/scripts/libraries/"*; do
library_id=$(basename "${library_csv%.*}")

    # Check for GEX libraries
    if [[ "${library_id}" == *_GEX ]]; then

        # Check if the output directory does not exist
        if [[ ! -d "${workingdir}/outs/${library_id}/outs" || ! -d "${workingdir}/outs/${library_id}/SC_MULTI_CS" ]]; then

            # Submit cellranger job
            job_id=$(sbatch --test-only <<EOF
#!/bin/bash
#SBATCH --job-name=${library_id}
#SBATCH --output="${workingdir}/outs/logs/${library_id}_cellranger.out"
#SBATCH --error="${workingdir}/outs/logs/${library_id}_cellranger.out"
#SBATCH --ntasks=32
#SBATCH --mem=96000
#SBATCH --time=96:00:00

num_cores=\$(nproc)
container="/fast/scratch/users/knighto_c/tmp/oscar-count_latest.sif"
cd "${workingdir}/outs/"
echo "apptainer run -B /fast,/data "\$container" cellranger multi --id "${library_id}" --csv "${library_csv}" --localcores "\$num_cores""
echo ""
apptainer run -B /fast,/data "\$container" cellranger multi --id "${library_id}" --csv "${library_csv}" --localcores "\$num_cores"
rm -r "${workingdir}/outs/${library_id}/SC_MULTI_CS" "${workingdir}/outs/${library_id}/_"*
EOF
            )

            job_id=$(echo $job_id | awk '{print $4}')

            sbatch --dependency=afterok:$job_id --test-only <<EOF
#!/bin/bash
#SBATCH --job-name=${library_id}_cellbender
#SBATCH --output="${workingdir}/outs/logs/${library_id}_cellbender.out"
#SBATCH --error="${workingdir}/outs/logs/${library_id}_cellbender.out"
#SBATCH --ntasks=1
#SBATCH --partition="gpu"
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=16
#SBATCH --mem=128000
#SBATCH --time=24:00:00

cd "${workingdir}/outs/${library_id}"
mkdir -p cellbender
container="/fast/scratch/users/knighto_c/tmp/oscar-qc_latest.sif"
apptainer run --nv -B /fast,/data "\$container" cellbender remove-background --cuda --input outs/multi/count/raw_feature_bc_matrix.h5 --output cellbender/output.h5
rm ckpt.tar.gz
EOF
        fi
    elif [[ "${library_id}" == *ATAC* ]]; then

        fastq_dirs=""
        fastq_names=""
        # Check for ATAC libraries
        while IFS=, read -r fastq_name fastq_dir; do
            if [ -n "$fastq_names" ]; then
                fastq_names="${fastq_names},${fastq_name}"
            else
                fastq_names="$fastq_name"
            fi
            if [ -n "$fastq_dirs" ]; then
                fastq_dirs="${fastq_dirs},${fastq_dir}"
            else
                fastq_dirs="$fastq_dir"
            fi
        done < "${library_csv}"

        if [[ "${library_id}" == "Multiome_"* ]]; then
            extra_arguments="--chemistry ARC-v1"
            echo "for $library_id adding $extra_arguments"
        else
            extra_arguments=""
            echo "for $library_id adding nothing"
        fi

        job_id=$(sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=${library_id}_cellranger
#SBATCH --output="${workingdir}/outs/logs/${library_id}_cellranger.out"
#SBATCH --error="${workingdir}/outs/logs/${library_id}_cellranger.out"
#SBATCH --ntasks=32
#SBATCH --mem=96000
#SBATCH --time=48:00:00
num_cores=\$(nproc)
cd "${workingdir}/outs/"
container="/fast/scratch/users/knighto_c/tmp/oscar-count_latest.sif"
echo "apptainer run -B /fast,/data "\$container" cellranger-atac count --id $library_id --reference /fast/work/groups/ag_romagnani/ref/hs/GRCh38-hardmasked-optimised-arc --fastqs $fastq_dirs --sample $fastq_names --localcores \$num_cores ${extra_arguments}"
echo ""
apptainer run -B /fast,/data "\$container" cellranger-atac count --id $library_id --reference /fast/work/groups/ag_romagnani/ref/hs/GRCh38-hardmasked-optimised-arc --fastqs $fastq_dirs --sample $fastq_names --localcores \$num_cores ${extra_arguments}
rm -r ${workingdir}/outs/${library_id}/_* ${workingdir}/outs/${library_id}/SC_ATAC_COUNTER_CS
EOF
        )

        job_id=$(echo "$job_id" | awk '{print $4}')

        sbatch --dependency=afterok:$job_id <<EOF
#!/bin/bash
#SBATCH --job-name=${library_id}_mgatk
#SBATCH --output="${workingdir}/outs/logs/${library_id}_mgatk.out"
#SBATCH --error="${workingdir}/outs/logs/${library_id}_mgatk.out"
#SBATCH --ntasks=16
#SBATCH --mem=64000
#SBATCH --time=128:00:00

cd ${workingdir}/outs/${library_id}
container="/fast/scratch/users/knighto_c/tmp/oscar-qc_latest.sif"
mkdir -p AMULET
apptainer run -B /fast,/data \${container} AMULET outs/fragments.tsv.gz outs/singlecell.csv /opt/AMULET/human_autosomes.txt /opt/AMULET/RestrictionRepeatLists/restrictionlist_repeats_segdups_rmsk_hg38.bed ${workingdir}/outs/${library_id}/AMULET /opt/AMULET/
apptainer exec -B /fast,/data,/usr \${container} mgatk tenx -i outs/possorted_bam.bam -n output -o mgatk -c 1 -bt CB -b outs/filtered_peak_bc_matrix/barcodes.tsv
rm -r ${workingdir}/outs/${library_id}/.snakemake
EOF
    fi
done
