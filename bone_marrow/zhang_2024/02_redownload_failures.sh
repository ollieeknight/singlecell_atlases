#!/bin/bash

project_id="zhang_2024"

workingdir="$HOME/scratch/ngs/${project_id}"

failed_downloads="${workingdir}/fastq/logs/failed.csv"

# Check if failed.txt exists and remove it
if [[ -f "$failed_downloads" ]]; then
    rm "$failed_downloads"
fi

# Create an empty failed.txt file
touch "$failed_downloads"

# Loop through each file in the directory
for logfile in "${workingdir}/fastq/logs/"*.out; do
    if grep -q "Failed" "$logfile"; then
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
#SBATCH --output "${workingdir}/fastq/logs/${SRR}.out"
#SBATCH --error "${workingdir}/fastq/logs/${SRR}.out"
#SBATCH --ntasks=2
#SBATCH --mem=8000
#SBATCH --time=96:00:00
cd "${workingdir}"
export PATH=~/group/work/bin/sratoolkit.3.1.1-centos_linux64/bin:$PATH
fastq-dump --split-files --gzip "$SRR" --outdir "${workingdir}/fastq/"
EOF
done < "$failed_downloads"
