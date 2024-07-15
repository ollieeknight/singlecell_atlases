#!/bin/bash

project_id='yi_2023'
workingdir="$HOME/scratch/ngs/${project_id}"

mkdir -p ${workingdir}/outs/logs/

# Define an array with the folder names
libraries=(
"CITE_Yi_2023_lib1_PBMC"
"CITE_Yi_2023_lib2_SFMC"
"CITE_Yi_2023_lib3_SFMC"
)

cd ${workingdir}/outs/genotype/

# Loop through the array and process each BAM file
for i in {1..3}; do
    library_id="${libraries[i-1]}"
    sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=${library_id}
#SBATCH --output=${workingdir}/outs/logs/${library_id}_vireo.out
#SBATCH --error=${workingdir}/outs/logs/${library_id}_vireo.out
#SBATCH --ntasks=32
#SBATCH --mem=128000
#SBATCH --time=168:00:00

cd ${workingdir}/outs/${library_id}
mkdir -p vireo

apptainer run -B /data,/fast ~/scratch/tmp/oscar-qc_latest.sif cellsnp-lite -s ${workingdir}/outs/${library_id}/outs/per_sample_outs/${library_id}/count/sample_alignments.bam -b ${workingdir}/outs/${library_id}/cellbender/output_cell_barcodes.csv -O vireo -R /data/gpfs-1/users/knighto_c/group/work/ref/vireo/genome1K.phase3.SNP_AF5e2.chr1toX.hg38.vcf.gz --minMAF 0.1 --minCOUNT 20 --gzip -p \$(nproc)
apptainer run -B /data,/fast ~/scratch/tmp/oscar-qc_latest.sif vireo -c vireo -o vireo -N 2 -p \$(nproc)
EOF
done

# Define an array with the folder names
libraries=(
"CITE_Yi_2023_lib4_Paired"
"CITE_Yi_2023_lib5_Paired"
"CITE_Yi_2023_lib6_Paired"
"CITE_Yi_2023_lib7_Paired"
)

# Loop through the array and process each BAM file
for i in {1..4}; do
    library_id="${libraries[i-1]}"
    sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=${library_id}
#SBATCH --output=${workingdir}/outs/logs/${library_id}_vireo.out
#SBATCH --error=${workingdir}/outs/logs/${library_id}_vireo.out
#SBATCH --ntasks=32
#SBATCH --mem=128000
#SBATCH --time=168:00:00

cd ${workingdir}/outs/${library_id}
mkdir -p vireo

apptainer run -B /data,/fast ~/scratch/tmp/oscar-qc_latest.sif cellsnp-lite -s ${workingdir}/outs/${library_id}/outs/per_sample_outs/${library_id}/count/sample_alignments.bam -b ${workingdir}/outs/${library_id}/cellbender/output_cell_barcodes.csv -O vireo -R /data/gpfs-1/users/knighto_c/group/work/ref/vireo/genome1K.phase3.SNP_AF5e2.chr1toX.hg38.vcf.gz --minMAF 0.1 --minCOUNT 20 --gzip -p \$(nproc)
apptainer run -B /data,/fast ~/scratch/tmp/oscar-qc_latest.sif vireo -c vireo -o vireo -N 3 -p \$(nproc)
EOF
done
