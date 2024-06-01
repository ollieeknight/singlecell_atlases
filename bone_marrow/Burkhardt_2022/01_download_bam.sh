#!/bin/bash

project_id='burkhardt_2022'

workingdir="$HOME/scratch/ngs/${project_id}"

mkdir -p "${workingdir}/bam/logs"

# Read each line from burkhardt_2022_metadata.csv and process it
while IFS=, read -r SRR biosample experiment library_name site donor_number modality chemistry disease age blood_type bmi donor_id race sex smoking_status; do
    # Skip the header row
    if [[ $SRR == "SRR" ]]; then
        continue
    fi

    # Set the assay variable based on the value of chemistry
    if [[ $chemistry == "SC3Pv3" ]]; then
        assay="CITE"
    elif [[ $chemistry == "ARC-v1" ]]; then
        assay="Multiome"
    else
        echo "Assay unknown, check entry for $SRR"
        exit 1
    fi

    echo $SRR
sbatch <<EOF
#!/bin/bash
#SBATCH --job-name ${SRR}
#SBATCH --output ${workingdir}/bam/logs/${SRR}.out
#SBATCH --error ${workingdir}/bam/logs/${SRR}.out
#SBATCH --ntasks=2
#SBATCH --mem=10000
#SBATCH --time=48:00:00
cd "${workingdir}/bam/"
source "${HOME}/work/bin/miniconda3/etc/profile.d/conda.sh"
conda activate ffq
ffq --ftp $SRR | grep -Eo '"url": "[^"]*"' | grep -o '"[^"]*"$' | xargs curl -o "${assay}_Burkhardt_NeurIPS_2022_S${site}_D${donor_number}_${modality}.bam"
EOF

    sleep 300
done < "$workingdir/scripts/burkhardt_2022_metadata.csv"
