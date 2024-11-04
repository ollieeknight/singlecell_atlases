#!/bin/bash

project_id='yi_2023'
workingdir="$HOME/scratch/ngs/${project_id}"

mkdir -p "${workingdir}/fastq/logs"

# Loop through each directory that matches the pattern SRR*
for SRA_dir in "${workingdir}/SRA/"*; do
    SRA=$(basename "${SRA_dir}")
    if [[ $SRA == "logs" ]]; then
        continue
    fi

    sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=${SRA}
#SBATCH --output=${workingdir}/fastq/logs/${SRA}.out
#SBATCH --error=${workingdir}/fastq/logs/${SRA}.out
#SBATCH --ntasks=8
#SBATCH --mem=16000
#SBATCH --time=128:00:00
cd "${workingdir}/fastq/"
mkdir -p ${SRA}
export PATH=${HOME}/work/bin/pigz:$PATH
export PATH=${HOME}/group/work/bin/sratoolkit.3.1.1-centos_linux64/bin:$PATH
fasterq-dump ${workingdir}/SRA/${SRA}/${SRA}.sra --outdir ${workingdir}/fastq/${SRA} -e $(nproc) -t ${HOME}/scratch/tmp/ --split-files --include-technical
pigz ${workingdir}/fastq/${SRA}/* -p $(nproc)
EOF
done
