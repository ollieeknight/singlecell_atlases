#!/bin/bash

project_id='yi_2023'
workingdir="$HOME/scratch/ngs/${project_id}"

source ~/work/bin/miniconda3/etc/profile.d/conda.sh
conda activate sinto

mkdir -p ${workingdir}/outs/genotype/

# Define an array with the folder names
libraries=(
"CITE_Yi_2023_lib1_PBMC"
"CITE_Yi_2023_lib2_SFMC"
"CITE_Yi_2023_lib3_SFMC"
"CITE_Yi_2023_lib4_Paired"
"CITE_Yi_2023_lib5_Paired"
"CITE_Yi_2023_lib6_Paired"
"CITE_Yi_2023_lib7_Paired"
)

cd ${workingdir}/outs/genotype/

# Loop through the array and process each BAM file
for i in {1..7}; do

    library_id="${libraries[i-1]}"

    # Prepare barcodes file
    awk -F'\t' -v OFS='\t' '{print $0, "filtered"}' ${workingdir}/outs/${library_id}/cellbender/output_cell_barcodes.csv > barcodes.tsv
    awk -v suffix="_${i}" '{print $0 suffix}' ${workingdir}/outs/${library_id}/cellbender/output_cell_barcodes.csv > ${library_id}_renamed_barcodes.tsv

    # Filter BAM file using sinto
    sinto filterbarcodes -b ${workingdir}/outs/${library_id}/outs/per_sample_outs/${library_id}/count/sample_alignments.bam --cells barcodes.tsv -p $(nproc) --outdir ${workingdir}/outs/genotype/

    # Rename the filtered BAM file
    mv ${workingdir}/outs/genotype/filtered.bam ${library_id}_filtered.bam

    # Convert BAM to SAM
    samtools view -@ $(nproc) -h ${library_id}_filtered.bam > temp.sam

    # Use awk to modify the CB tag
    awk -v suffix="_${i}" 'BEGIN {OFS="\t"} {
        if ($1 ~ /^@/) {print $0; next}  # print header lines as is
        for (j=1; j<=NF; j++) {
            if ($j ~ /^CB:Z:/) {
                $j = $j suffix  # append suffix to the CB tag
            }
        }
        print $0
    }' temp.sam > temp_modified.sam

    # Convert SAM back to BAM
    samtools view -@ $(nproc) -Sb temp_modified.sam > ${library_id}_renamed.bam

    # Clean up temporary files
    rm temp.sam temp_modified.sam

done

samtools merge -@ $(nproc) -o CITE_Yi_2023_merged.bam CITE_Yi_2023_lib1_PBMC_renamed.bam CITE_Yi_2023_lib2_SFMC_renamed.bam CITE_Yi_2023_lib3_SFMC_renamed.bam CITE_Yi_2023_lib4_Paired_renamed.bam CITE_Yi_2023_lib6_Paired_renamed.bam CITE_Yi_2023_lib7_Paired_renamed.bam
samtools sort -@ $(nproc) -o CITE_Yi_2023_merged_sorted.bam CITE_Yi_2023_merged.bam
samtools index -@ $(nproc) CITE_Yi_2023_merged_sorted.bam

cat *renamed_barcodes.tsv > merged_barcodes.tsv

apptainer run -B /data,/fast ~/scratch/tmp/oscar-qc_latest.sif cellsnp-lite -s CITE_Yi_2023_merged_sorted.bam -b merged_barcodes.tsv -O vireo -R /data/gpfs-1/users/knighto_c/group/work/ref/vireo/genome1K.phase3.SNP_AF5e2.chr1toX.hg38.vcf.gz --minMAF 0.1 --minCOUNT 20 --gzip -p $(nproc)
apptainer run -B /data,/fast ~/scratch/tmp/oscar-qc_latest.sif vireo -c vireo -o vireo_6 -N 6 -p $(nproc)
apptainer run -B /data,/fast ~/scratch/tmp/oscar-qc_latest.sif vireo -c vireo -o vireo_7 -N 7 -p $(nproc)
