#!/bin/bash

project_id='hashemi_2024'
workingdir="$HOME/scratch/ngs/${project_id}"

mkdir -p "${workingdir}/outs/logs/"
cd "${workingdir}/outs"

for library_csv in "${workingdir}/scripts/libraries/"*; do
    library_id=$(basename "${library_csv%.*}")
    if [ ! -d "${workingdir}/outs/${library_id}/outs" ]; then
            job_id=$(sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=${library_id}
#SBATCH --output="${workingdir}/outs/logs/${library_id}_cellranger.out"
#SBATCH --error="${workingdir}/outs/logs/${library_id}_cellranger.out"
#SBATCH --ntasks=32
#SBATCH --mem=128000
#SBATCH --time=168:00:00

num_cores=\$(nproc)
container="/fast/scratch/users/knighto_c/tmp/oscar-count_latest.sif"
cd "${workingdir}/outs/"
apptainer run -B /data,/fast "\$container" cellranger multi --id "${library_id}" --csv "${library_csv}" --localcores "\$num_cores"
rm -r "${workingdir}/outs/${library_id}/SC_MULTI_CS" "${workingdir}/outs/${library_id}/_"*
EOF
            )

            job_id=$(echo $job_id | awk '{print $4}')

            echo "Submitting cellbender for ${library_id}"

            sbatch --dependency=afterok:$job_id <<EOF
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
container="/fast/scratch/users/knighto_c/tmp/oscar-qc_latest.sif"
apptainer run --nv -B /data,/fast "\$container" cellbender remove-background --cuda --input outs/multi/count/raw_feature_bc_matrix.h5 --output cellbender/output.h5
rm ckpt.tar.gz
EOF
    fi
done
