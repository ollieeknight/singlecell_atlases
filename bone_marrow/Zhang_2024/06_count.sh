#!/bin/bash

project_dir="$HOME/scratch/ngs/BMMC"

mkdir -p "${project_dir}/BMMC_outs/logs/"
cd "${project_dir}/BMMC_outs"

for library_csv in "${project_dir}/BMMC_scripts/libraries/"*; do
    library_id=$(basename "${library_csv%.*}")
    if [ ! -d "${project_dir}/BMMC_outs/${library_id}/outs" ]; then
        echo "Submitting cellranger multi count for ${library_id}"
        sbatch <<EOF
#!/bin/bash
#SBATCH --job-name ${library_id}
#SBATCH --output "${project_dir}/BMMC_outs/logs/${library_id}_cellranger.out"
#SBATCH --error "${project_dir}/BMMC_outs/logs/${library_id}_cellranger.out"
#SBATCH --ntasks=64
#SBATCH --mem=192000
#SBATCH --time=168:00:00
num_cores=\$(nproc)
container="/fast/scratch/users/knighto_c/tmp/oscar-count_latest.sif"
cd "${project_dir}/BMMC_outs/"
apptainer run -B /fast "\$container" cellranger multi --id "${library_id}" --csv "${library_csv}" --localcores "\$num_cores"
rm -r "${project_dir}/BMMC_outs/${library_id}/SC_MULTI_CS" "${project_dir}/BMMC_outs/${library_id}/_"*
EOF
    fi
done
