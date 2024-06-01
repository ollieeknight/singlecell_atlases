#!/bin/bash

project_id='burkhardt_2022'

project_dir="$HOME/scratch/ngs/$project_id"

mkdir -p "${project_dir}/outs/logs/"
cd "${project_dir}/outs"

for library_csv in "${project_dir}/scripts/libraries/"*; do
    library_id=$(basename "${library_csv%.*}")

    if [[ $library_csv == *_GEX* || $library_csv == *CITE* ]]; then

        output_file="${project_dir}/outs/${library_id}/cellbender/output_filtered.h5"

        # Check if the output file already exists
        if [ -f "$output_file" ]; then
            echo "Output file exists for ${library_id}, skipping"
            continue
        fi

        echo "Submitting cellbender for ${library_id}"
        echo ""
        sbatch <<EOF
#!/bin/bash
#SBATCH --job-name ${library_id}
#SBATCH --output "${project_dir}/outs/logs/${library_id}_cellbender.out"
#SBATCH --error "${project_dir}/outs/logs/${library_id}_cellbender.out"
#SBATCH --ntasks 1
#SBATCH --partition "gpu"
#SBATCH --gres gpu:1
#SBATCH --cpus-per-task 16
#SBATCH --mem 64000
#SBATCH --time 12:00:00
cd "${project_dir}/outs/${library_id}"
mkdir -p cellbender
container="/fast/scratch/users/knighto_c/tmp/oscar-qc_latest.sif"
apptainer run --nv -B /fast,/data "\$container" cellbender remove-background --cuda --input outs/multi/count/raw_feature_bc_matrix.h5 --output cellbender/output.h5
rm ckpt.tar.gz
EOF

    elif [[ $library_csv == *ATAC* ]]; then

        output_file="${project_dir}/outs/${library_id}/mgatk/final/output.rds"
        if [ -f "$output_file" ]; then
            echo "Output file exists for ${library_id}, skipping"
            continue
        fi

        echo "Submitting ATAC QC for ${library_id}"
sbatch <<EOF
#!/bin/bash
#SBATCH --job-name ${library_id}
#SBATCH --output "${project_dir}/outs/logs/${library_id}_ATAC_QC.out"
#SBATCH --error "${project_dir}/outs/logs/${library_id}_ATAC_QC.out"
#SBATCH --ntasks=16
#SBATCH --mem=96000
#SBATCH --time=12:00:00
num_cores=\$(nproc)
container="/fast/scratch/users/knighto_c/tmp/oscar-qc_latest.sif"
cd ${project_dir}/outs/${library_id}
mkdir -p ${project_dir}/outs/${library_id}/AMULET
apptainer exec -B /fast,/data "\${container}" bash /opt/AMULET/AMULET.sh outs/fragments.tsv.gz outs/singlecell.csv /opt/AMULET/human_autosomes.txt /opt/AMULET/RestrictionRepeatLists/restrictionlist_repeats_segdups_rmsk_hg38.bed AMULET /opt/AMULET/
apptainer exec -B /fast,/usr,/data "\${container}" mgatk tenx -i outs/possorted_bam.bam -n output -o mgatk -c 1 -bt CB -b outs/filtered_peak_bc_matrix/barcodes.tsv --skip-R
rm -r .snakemake
EOF
fi
done
