#!/bin/bash

project_id='IPS'

project_dir="$HOME/scratch/ngs/${project_id}"

# Create directories for logs
mkdir -p "${project_dir}/fastq/logs/"

# Process BAM files in the GEX directory
for bam in "${project_dir}/bam/"*.bam; do
    filename=$(basename "${bam}" .bam)

    sbatch <<EOF
#!/bin/bash
#SBATCH --job-name ${filename}
#SBATCH --output "${project_dir}/fastq/logs/${filename}.out"
#SBATCH --error "${project_dir}/fastq/logs/${filename}.out"
#SBATCH --ntasks=16
#SBATCH --mem=32000
#SBATCH --time=8:00:00
cd "${project_dir}"
${HOME}/group/work/bin/cellranger-7.2.0/lib/bin/bamtofastq --nthreads 16 "${bam}" "${project_dir}/fastq/${filename}/"
EOF
done
