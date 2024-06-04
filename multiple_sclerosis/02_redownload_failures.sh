#!/bin/bash

project_id="schafflick_2020"

workingdir="$HOME/scratch/ngs/${project_id}"

failed_downloads="${workingdir}/bam/logs/failed.csv"

# Check if failed.txt exists and remove it
if [[ -f "$failed_downloads" ]]; then
    rm "$failed_downloads"
fi

# Create an empty failed.txt file
touch "$failed_downloads"

# Loop through each file in the directory
for logfile in "${workingdir}/bam/logs/"*.out; do
    if grep -q "ERROR" "$logfile"; then
        # Extract the filename without extension
        filename=$(basename "$logfile" .out)
        # Append the filename to failed.txt
        echo "$filename" >> "$failed_downloads"
    fi
done

while IFS= read -r SRR; do
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
ffq --ftp $SRR | grep -Eo '"url": "[^"]*"' | grep -o '"[^"]*"$' | xargs curl -o "GEX_Schafflic_2020_${disease}_${donor_id}_${origin}.bam" -L

EOF
done < "$failed_downloads"
