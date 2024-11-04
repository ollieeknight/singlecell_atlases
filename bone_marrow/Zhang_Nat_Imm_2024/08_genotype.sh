#!/bin/bash

project_id="zhang_2024"

workingdir="$HOME/scratch/ngs/${project_id}"

declare -A processed_library_ids

cd "${workingdir}/BMMC_outs"

# Read each line from the CSV file
while IFS=',' read -r SRR GSM fastq_name library_id modality chemistry lane ethnicity disease mutation sex age sorted_celltype n_donors donor_id; do
    # Skip the first line if it matches the header
    if [[ "$SRR" == "SRR" ]]; then
        continue
    fi
    library_id=$(basename "${library_id%.*}")

    # Check if the $library_id/outs directory exists
    if [ ! -d "${workingdir}/outs/${library_id}/outs" ]; then
        echo "Directory ${library_id}/outs does not exist, skipping"
        continue
    fi

    # Check if the output file already exists
    if [ "$n_donors" -gt 1 ]; then
        # Check if the library_id has been processed before
        if [ ${processed_library_ids[$library_id]+_} ]; then
            echo "Script for $library_id has already been submitted, skipping"
            continue
        else
            echo "For $library_id, number of donors is $n_donors"
            echo "Submitting vireo for ${library_id}"
            echo ""
            sbatch <<EOF
#!/bin/bash
#SBATCH --job-name ${library_id}
#SBATCH --output ${workingdir}/outs/logs/${library_id}_vireo.out
#SBATCH --error ${workingdir}/outs/logs/${library_id}_vireo.out
#SBATCH --ntasks=32
#SBATCH --mem=128000
#SBATCH --time=96:00:00
num_cores=\$(nproc)
cd "${workingdir}/outs/${library_id}"
mkdir -p vireo
container="/fast/scratch/users/knighto_c/tmp/oscar-qc_latest.sif"
apptainer exec -B /fast,/data \${container} cellsnp-lite -s outs/per_sample_outs/${library_id}/count/sample_alignments.bam -b cellbender/output_cell_barcodes.csv -O vireo -R /opt/SNP/genome1K.phase3.SNP_AF5e2.chr1toX.hg38.vcf.gz --minMAF 0.1 --minCOUNT 20 --gzip -p \$num_cores
apptainer run -B /fast,/data \${container} vireo -c vireo -o vireo -N $n_donors -p \$num_cores
EOF
            processed_library_ids[$library_id]=1 # Mark the library_id as processed
        fi
    elif [ "$n_donors" -eq 1 ]; then
        if [ ${processed_library_ids[$library_id]+_} ]; then
            echo "Script for $library_id has already been submitted, skipping"
            continue
        processed_library_ids[$library_id]=1 # Mark the library_id as processed
        fi
    fi
done < ${workingdir}/scripts/zhang_2024_metadata.csv

