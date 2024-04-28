#!/bin/bash

workingdir=$HOME/scratch/ngs/IPS/

mkdir -p ${workingdir}/bam/

# Read each line from accessions.txt and process it
while IFS= read -r SRR biosample experiment library_name sample_name chemistry modality disease age blood_type bmi donor_id race sex smoking_status site donor_number; do
sbatch <<EOF
#!/bin/bash
#SBATCH --job-name ${SRR}
#SBATCH --output $workingdir/logs/${SRR}.out
#SBATCH --error $workingdir/logs/${SRR}.out
#SBATCH --ntasks=2
#SBATCH --mem=10000
#SBATCH --time=48:00:00
cd ${workingdir}/bam/
source ${HOME}/work/bin/miniconda3/etc/profile.d/conda.sh
conda activate ffq
ffq --ftp $accession_id | grep -Eo '"url": "[^"]*"' | grep -o '"[^"]*"$' | xargs curl -O
EOF
sleep 120
done < $workingdir/scripts/burkhardt_2022_metadata.csv
