#!/bin/bash

project_id="weinand_2024"

workingdir="$HOME/scratch/ngs/${project_id}"

mkdir -p "${workingdir}/outs/logs/"
cd "${workingdir}/outs"

for library_csv in "${workingdir}/scripts/libraries/"*GEX*; do
    library_id=$(basename "${library_csv%.*}")
    output_file="${workingdir}/outs/${library_id}/cellbender/output_posterior.h5"

    # Check if the $library_id/outs directory exists
    if [ ! -d "${workingdir}/outs/${library_id}/outs" ]; then
        echo "Directory ${library_id}/outs does not exist, skipping"
        continue
    fi

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
#SBATCH --output "${workingdir}/outs/logs/${library_id}_cellbender.out"
#SBATCH --error "${workingdir}/outs/logs/${library_id}_cellbender.out"
#SBATCH --ntasks 1
#SBATCH --partition "gpu"
#SBATCH --gres gpu:1
#SBATCH --cpus-per-task 16
#SBATCH --mem 128000
#SBATCH --time 24:00:00
cd "${workingdir}/outs/${library_id}"
mkdir -p cellbender
container="/fast/scratch/users/knighto_c/tmp/oscar-qc_latest.sif"
apptainer run --nv -B /fast,/data "\$container" cellbender remove-background --cuda --input outs/multi/count/raw_feature_bc_matrix.h5 --output cellbender/output.h5
rm ckpt.tar.gz
EOF
done
