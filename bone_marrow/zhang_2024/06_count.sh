#!/bin/bash

project_id="zhang_2024"

workingdir="$HOME/scratch/ngs/${project_id}"

mkdir -p "${workingdir}/outs/logs/"
cd "${workingdir}/outs"

for library_csv in "${workingdir}/scripts/libraries/"*; do
    library_id=$(basename "${library_csv%.*}")
    if [ ! -d "${workingdir}/outs/${library_id}/outs" ]; then
        echo "Submitting cellranger multi count for ${library_id}"
        sbatch <<EOF
#!/bin/bash
#SBATCH --job-name ${library_id}
#SBATCH --output "${workingdir}/outs/logs/${library_id}_cellranger.out"
#SBATCH --error "${workingdir}/_outs/logs/${library_id}_cellranger.out"
#SBATCH --ntasks=64
#SBATCH --mem=192000
#SBATCH --time=168:00:00
num_cores=\$(nproc)
container="/fast/scratch/users/knighto_c/tmp/oscar-count_latest.sif"
cd "${workingdir}/outs/"
apptainer run -B /fast,/data "\$container" cellranger multi --id "${library_id}" --csv "${library_csv}" --localcores "\$num_cores"
rm -r "${workingdir}/outs/${library_id}/SC_MULTI_CS" "${workingdir}/outs/${library_id}/_"*
EOF
    fi
done
