#!/bin/bash

project_dir="$HOME/scratch/ngs/BMMC"

mkdir -p "${project_dir}/BMMC_outs/logs/"
cd "${project_dir}/BMMC_outs"

for library_csv in "${project_dir}/BMMC_scripts/libraries/"*; do
    library_id=$(basename "${library_csv%.*}")
    output_file="${project_dir}/BMMC_outs/${library_id}/cellbender/output_posterior.h5"

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
#SBATCH --output "${project_dir}/BMMC_outs/logs/${library_id}_cellbender.out"
#SBATCH --error "${project_dir}/BMMC_outs/logs/${library_id}_cellbender.out"
#SBATCH --ntasks 1
#SBATCH --partition "gpu"
#SBATCH --gres gpu:1
#SBATCH --cpus-per-task 16
#SBATCH --mem 64000
#SBATCH --time 12:00:00
cd "${project_dir}/BMMC_outs/${library_id}"
mkdir -p cellbender
container="/fast/scratch/users/knighto_c/tmp/oscar-qc_latest.sif"
apptainer run --nv -B /fast "\$container" cellbender remove-background --cuda --input outs/multi/count/raw_feature_bc_matrix.h5 --output cellbender/output.h5
rm ckpt.tar.gz
EOF
done
