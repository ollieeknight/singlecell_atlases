#!/bin/bash

project_id='penkava_2020'

workingdir="$HOME/scratch/ngs/${project_id}"

mkdir -p "${workingdir}/fastq/logs"

# Read each line from accessions.txt and process it
while IFS=, read -r ENA r1_ftp r2_ftp lane age sex disease donor_id tissue cell_type assay chemistry modality; do
    # Skip the header row
    if [[ $ENA == "ENA" ]]; then
        continue
    fi
    echo "Downloading ENA files $ENA"
sbatch <<EOF
#!/bin/bash
#SBATCH --job-name ${ENA}
#SBATCH --output ${workingdir}/fastq/logs/${ENA}.out
#SBATCH --error ${workingdir}/fastq/logs/${ENA}.out
#SBATCH --ntasks=2
#SBATCH --mem=4000
#SBATCH --time=128:00:00
cd ${workingdir}/fastq/
wget -O GEX_Penkava_2020_${disease}_${donor_id}_${tissue}_${cell_type}_${modality}_S1_L00${lane}_R1_001.fastq.gz ${r1_ftp}
wget -O GEX_Penkava_2020_${disease}_${donor_id}_${tissue}_${cell_type}_${modality}_S1_L00${lane}_R2_001.fastq.gz ${r2_ftp}
EOF
echo ""
done < "${workingdir}/scripts/penkava_2020_metadata.csv"
