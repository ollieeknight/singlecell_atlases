#!/bin/bash

project_id="williams_2021"

workingdir="$HOME/scratch/ngs/${project_id}"

mkdir -p "${workingdir}/fastq/logs"

while IFS=, read -r SRR SAMN disease_state SRX GSM donor_id tissue replicate; do
    if [[ "$SRR" == "SRR" ]]; then
        continue
    fi

    echo $SRR
    sbatch <<EOF
#!/bin/bash
#SBATCH --job-name ${SRR}
#SBATCH --output "${workingdir}/fastq/logs/${SRR}.out"
#SBATCH --error "${workingdir}/fastq/logs/${SRR}.out"
#SBATCH --ntasks=2
#SBATCH --mem=8000
#SBATCH --time=96:00:00
cd "${workingdir}"
export PATH=~/group/work/bin/sratoolkit.3.1.1-centos_linux64/bin:$PATH
fastq-dump --split-files --gzip "$SRR" --outdir "${workingdir}/fastq/"
EOF
done < "${workingdir}/scripts/metadata.csv"
