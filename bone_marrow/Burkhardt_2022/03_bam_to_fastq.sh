#!/bin/bash

# Define the working directory
workdir="${HOME}/scratch/ngs/IPS/"

# Create directories for logs
mkdir -p "${workdir}/fastq/logs/"

# Process BAM files in the GEX directory
for bam in "${workdir}/bam/"*.bam; do
    filename=$(basename "${bam}" .bam)

    sbatch <<EOF
#!/bin/bash
#SBATCH --job-name ${filename}
#SBATCH --output "${workdir}/fastq/logs/${filename}.out"
#SBATCH --error "${workdir}/fastq/logs/${filename}.out"
#SBATCH --ntasks=16
#SBATCH --mem=32000
#SBATCH --time=8:00:00
cd "${workdir}"
${HOME}/group/work/bin/cellranger-7.2.0/lib/bin/bamtofastq --nthreads 16 "${bam}" "${workdir}/fastq/fastq/${filename}/"
EOF
done
