#!/bin/bash

project_id='weinand_2024'
workingdir="$HOME/scratch/ngs/${project_id}"

# Create necessary directories
mkdir -p "${workingdir}/outs/logs/"
cd "${workingdir}/outs"

# Loop through library CSV files
for library_csv in "${workingdir}/scripts/libraries/"*; do
    library_id=$(basename "${library_csv%.*}")

    if [[ ! -f "${workingdir}/outs/${library_id}/mgatk/final/output.rds" ]]; then

sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=${library_id}_qc
#SBATCH --output=${workingdir}/outs/logs/${library_id}_qc.out
#SBATCH --error=${workingdir}/outs/logs/${library_id}_qc.out
#SBATCH --ntasks=16
#SBATCH --mem=64000
#SBATCH --time=128:00:00

cd ${workingdir}/outs/${library_id}
container="/fast/scratch/users/knighto_c/tmp/oscar-qc_latest.sif"
apptainer exec -B /fast,/data,/usr \${container} mgatk tenx -i outs/possorted_bam.bam -n output -o mgatk -c 1 -bt CB -b outs/filtered_peak_bc_matrix/barcodes.tsv --skip-R
rm -r ${workingdir}/outs/${library_id}/.snakemake
EOF
fi

done

