#!/bin/bash

project_id='schafflick_2020'

workingdir="$HOME/scratch/ngs/${project_id}"

mkdir -p "${workingdir}/bam/logs"

# Read each line from accessions.txt and process it
while IFS=, read -r SRR SAMN disease SRX GSM donor_id origin; do
    # Skip the header row
    if [[ $SRR == "SRR" ]]; then
        continue
    fi

echo "GEX_Schafflick_2020_${disease}_${donor_id}_${origin}.bam"

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
ffq --ftp $SRR | grep -Eo '"url": "[^"]*"' | grep -o '"[^"]*"$' | xargs curl -o "GEX_Schafflic_2020_${disease}_${donor_id}_${origin}.bam" -L
EOF
sleep 300
done < "$workingdir/scripts/schafflick_2020_metadata.csv"
