#!/bin/bash

project_id='weinand_2024'
workingdir="$HOME/scratch/ngs/${project_id}"

# Create necessary directories
mkdir -p "${workingdir}/outs/logs/"
cd "${workingdir}/outs"

# Loop through library CSV files
for library_csv in "${workingdir}/scripts/libraries/"*; do
    library_id=$(basename "${library_csv%.*}")

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

        job_id=$(sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=${library_id}_cellranger
#SBATCH --output="${workingdir}/outs/logs/${library_id}_cellranger.out"
#SBATCH --error="${workingdir}/outs/logs/${library_id}_cellranger.out"
#SBATCH --ntasks=32
#SBATCH --mem=96000
#SBATCH --time=48:00:00
cd "${workingdir}/outs/"
container="/fast/scratch/users/knighto_c/tmp/oscar-count_latest.sif"
echo "apptainer run -B /fast,/data \$container cellranger-atac count --id $library_id --reference /fast/work/groups/ag_romagnani/ref/hs/GRCh38-hardmasked-optimised-arc --fastqs $fastq_dirs --sample $fastq_names --localcores $(nproc)"
echo ""
apptainer run -B /fast,/data "\$container" cellranger-atac count --id $library_id --reference /fast/work/groups/ag_romagnani/ref/hs/GRCh38-hardmasked-optimised-arc --fastqs $fastq_dirs --sample $fastq_names --localcores $(nproc)
rm -r ${workingdir}/outs/${library_id}/_* ${workingdir}/outs/${library_id}/SC_ATAC_COUNTER_CS
EOF
        )

        job_id=$(echo "$job_id" | awk '{print $4}')

        sbatch --dependency=afterok:$job_id <<EOF
#!/bin/bash
#SBATCH --job-name=${library_id}_qc
#SBATCH --output="${workingdir}/outs/logs/${library_id}_qc.out"
#SBATCH --error="${workingdir}/outs/logs/${library_id}_qc.out"
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
done
