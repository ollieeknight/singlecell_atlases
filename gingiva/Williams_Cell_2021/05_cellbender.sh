#!/bin/bash

project_id="williams_2021"

workingdir="$HOME/scratch/ngs/${project_id}"

mkdir -p "${workingdir}/outs/logs/"
cd "${workingdir}/outs"

for library_csv in "${workingdir}/scripts/libraries/"*; do
    library_id=$(basename "${library_csv%.*}")

    echo "$library_id"

    # Check if the output directory already exists
    if [ ! -f "${workingdir}/outs/${library_id}/cellbender/output_posterior.h5" ]; then
        sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=${library_id}_cellbender
#SBATCH --output="${workingdir}/outs/logs/${library_id}_cellbender.out"
#SBATCH --error="${workingdir}/outs/logs/${library_id}_cellbender.out"
#SBATCH --ntasks=1
#SBATCH --partition="gpu"
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=16
#SBATCH --mem=200000
#SBATCH --time=24:00:00
cd "${workingdir}/outs/${library_id}"
mkdir -p cellbender
container="/data/cephfs-1/scratch/groups/romagnani/users/knighto_c/tmp/oscar-qc_latest.sif"
apptainer run -B /data --nv "\$container" cellbender remove-background --cuda --input outs/multi/count/raw_feature_bc_matrix.h5 --output cellbender/output.h5
rm ckpt.tar.gz
EOF
    fi
done
