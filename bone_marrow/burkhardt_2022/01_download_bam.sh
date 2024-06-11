#!/bin/bash

project_id='IPS'

workingdir="$HOME/scratch/ngs/${project_id}"

mkdir -p "${workingdir}/bam/logs"

# Read each line from accessions.txt and process it
while IFS=, read -r SRR biosample experiment library_name site donor_number modality chemistry disease age blood_type bmi donor_id race sex smoking_status; do
    # Skip the header row
    if [[ $SRR == "SRR" ]]; then
        continue
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
ffq --ftp $SRR | grep -Eo '"url": "[^"]*"' | grep -o '"[^"]*"$' | xargs curl -o "CITE_Burkhardt_NeurIPS_2022_S${site}_D${donor_number}_${modality}.bam" -L

EOF

    sleep 300
done < "$workingdir/scripts/burkhardt_2022_metadata.csv"
