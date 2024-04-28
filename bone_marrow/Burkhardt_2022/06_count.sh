#!/bin/bash

project_dir="$HOME/scratch/ngs/IPS"

mkdir -p "${project_dir}/IPS_outs/logs/"
cd "${project_dir}/IPS_outs"

for library_csv in "${project_dir}/IPS_scripts/libraries/"*; do
    library_id=$(basename "${library_csv%.*}")
    echo "Submitting cellranger multi count for ${library_id}"
sbatch <<EOF
#!/bin/bash
#SBATCH --job-name ${library_id}
#SBATCH --output "${project_dir}/IPS_outs/logs/${library_id}_cellranger.out"
#SBATCH --error "${project_dir}/IPS_outs/logs/${library_id}_cellranger.out"
#SBATCH --ntasks=32
#SBATCH --mem=96000
#SBATCH --time=96:00:00
num_cores=\$(nproc)
container="/fast/scratch/users/knighto_c/tmp/oscar-count_latest.sif"
cd "${project_dir}/IPS_outs/"
apptainer run -B /fast "\$container" cellranger multi --id "${library_id}" --csv "${library_csv}" --localcores "\$num_cores" --localmem 92
rm -r "${project_dir}/IPS_outs/${library_id}/SC_MULTI_CS" "${project_dir}/IPS_outs/${library_id}/_"*
EOF
done
