#!/bin/bash

project_id='amp_zhang_2023'
workingdir="$HOME/scratch/ngs/${project_id}"

mkdir -p "${workingdir}/fastq/adt/"
mkdir -p "${workingdir}/fastq/gex/"

source ${HOME}/work/bin/miniconda3/etc/profile.d/conda.sh

# Check if conda environment 'synapse' exists
if ! conda info --envs | grep -q "^synapse "; then
  echo "Conda environment 'synapse' not found. Creating it now..."
  conda create -y -n synapse python=3.9
  conda activate synapse
  pip install --upgrade synapseclient
else
  echo "Synapse env exists, moving to download FASTQ files"
fi

sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=synapse_gex
#SBATCH --output="${workingdir}/fastq/gex/download.log"
#SBATCH --error="${workingdir}/fastq/gex/download.log"
#SBATCH --ntasks=4
#SBATCH --mem=16000
#SBATCH --time=336:00:00

source ${HOME}/work/bin/miniconda3/etc/profile.d/conda.sh
conda activate ffq
cd "${workingdir}/fastq/gex/"
synapse get -r syn26379988
EOF

sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=synapse_adt
#SBATCH --output="${workingdir}/fastq/adt/download.log"
#SBATCH --error="${workingdir}/fastq/adt/download.log"
#SBATCH --ntasks=4
#SBATCH --mem=16000
#SBATCH --time=336:00:00

source ${HOME}/work/bin/miniconda3/etc/profile.d/conda.sh
conda activate ffq
cd "${workingdir}/fastq/adt"
synapse get -r syn26379988

for entry in "${workingdir}/fastq/adt/"*; do
  if [[ -d "\$entry" ]]; then
    current_name=\$(basename "\$entry")
    if [[ "\$current_name" =~ "-" ]]; then
      new_name="\${current_name//-/_}"
      mv "\$entry" "${workingdir}/fastq/adt/\$new_name"
    fi
  fi
done
EOF
