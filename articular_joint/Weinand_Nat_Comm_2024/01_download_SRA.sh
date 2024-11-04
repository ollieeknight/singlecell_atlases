#!/bin/bash

project_id='weinand_2024'

workingdir="$HOME/scratch/ngs/${project_id}"

mkdir -p "${workingdir}/SRA/logs"

# Read each line from accessions.txt and process it
while IFS=, read -r SRR assay chemistry modality site experiment tissue sample_name sex donor_id disease sample_id; do
    # Skip the header row
    if [[ $SRR == "SRR" ]]; then
        continue
    fi
    echo "Downloading SRA file $SRA"
sbatch <<EOF
#!/bin/bash
#SBATCH --job-name ${SRR}
#SBATCH --output ${workingdir}/SRA/logs/${SRR}.out
#SBATCH --error ${workingdir}/SRA/logs/${SRR}.out
#SBATCH --ntasks=2
#SBATCH --mem=4000
#SBATCH --time=128:00:00
cd "${workingdir}/SRA/"
export PATH=~/group/work/bin/sratoolkit.3.1.1-centos_linux64/bin:$PATH
prefetch --ngc ${workingdir}/scripts/prj_37934.ngc $SRR --max-size 10t
EOF
echo ""
done < "${workingdir}/scripts/weinand_2024_metadata.csv"
