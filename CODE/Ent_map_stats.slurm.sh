#!/bin/sh
#SBATCH --time=168:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=10GB
#SBATCH --mem-per-cpu=10GB
#SBATCH --job-name="rsem_Ent2_3"
#SBATCH --error="rsem_Ent2_3.err"
#SBATCH --output="rsem_Ent2_3.out"

module load rsem/1.3

module load bowtie/2.3

rsem-prepare-reference Entoloma_abortivum_transcripts.fasta Entoloma --bowtie2

rsem-calculate-expression --paired-end Ent2_f_3.fastq Ent2_r_3.fastq Entoloma Ent2_3 --bowtie2

rsem-generate-data-matrix Ent1_1.genes.results Ent1_2.genes.results Ent1_3.genes.results Ent2_1.genes.results Ent2_2.genes.results Ent2_3.genes.results Ent3_1.genes.results Ent3_2.genes.results Ent3_3.genes.results Ebor2_1.genes.results Ebor2_2.genes.results Ebor2_3.genes.results Ebor4_1.genes.results Ebor4_2.genes.results Ebor4_3.genes.results Ebor5_1.genes.results Ebor5_2.genes.results Ebor5_3.genes.results > RSEM_Entoloma.counts.matrix

rsem-run-ebseq RSEM_Entoloma.counts.matrix 9,9 Entoloma.results

rsem-control-fdr Entoloma.results 0.05 Entoloma.de.txt