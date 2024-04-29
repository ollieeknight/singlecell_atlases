#!/bin/bash

workingdir="$HOME/scratch/ngs/BMMC"

mkdir -p "${workingdir}/BMMC_fastq/logs"

while IFS=, read -r SRR GSM sample_name modality chemistry lane ethnicity mutation sex age sorted_celltype; do
    echo $SRR
    sbatch <<EOF
#!/bin/bash
#SBATCH --job-name ${SRR}
#SBATCH --output "${workingdir}/BMMC_fastq/logs/${SRR}.out"
#SBATCH --error "${workingdir}/BMMC_fastq/logs/${SRR}.out"
#SBATCH --ntasks=2
#SBATCH --mem=8000
#SBATCH --time=96:00:00
cd "${workingdir}"
export PATH="${HOME}/group/work/bin/sratoolkit.3.0.6/bin:$PATH"
fastq-dump --split-files --gzip "$SRR" --outdir "${workingdir}/BMMC_fastq/"
EOF
done < <(tail -n +2 "$workingdir/BMMC_scripts/zhang_2024_metadata.csv")
