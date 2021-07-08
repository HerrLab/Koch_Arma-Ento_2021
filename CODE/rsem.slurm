###SLURM input file that has the commands for rsem, which measured expression files of each gene, and ultimately created a data matrix that included expression data for each of the nine samples in both the sporocarp and carpophoroid treatments
###This script was used independently for all nine samples in each of the two treatments (so 18 total times), however, some commands, indicated at each, were only necessary to run once

#!/bin/sh
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=10GB
#SBATCH --mem-per-cpu=10GB
#SBATCH --job-name="2_1_Abor"
#SBATCH --error="2_1_Abor.err"
#SBATCH --output="2_1_Abor.out"

module load bbmap/38.06
module load rsem/1.3
module load bowtie/2.3
module load samtools/1.9

###Remove sequencing artifacts from the raw reads. *um.fq corresponds to those files that did not match known sequencing artifacts, while *m.fq are those that do match.
bbduk.sh in1=Abor2_f_1.fastq in2=Abor2_r_1.fastq out1=Abor2_f_1_um.fq out2=Abor2_r_1_um.fq outm1=Abor2_f_1_m.fq outm2=Abor2_r_1_m.fq ref=/util/opt/anaconda/deployed-conda-envs/packages/bbmap/envs/bbmap-38.06/opt/bbmap-38.06/resources/sequencing_artifacts.fa.gz stats=Ent3_3_stats.txt

#####Removes Illumina adaptors. Input are the unmatched reads from above. Output is now labeled as "clean"... no artifacts or adaptors!
bbduk.sh in1=Abor2_f_1_um.fq in2=Abor2_r_1_um.fq out1=Abor2_f_1_um_clean.fq out2=Abor2_r_1_um_clean.fq outs=Ent3_3_um_clean_singles.fq ktrim=r k=31 hdist=1 tpe tbo mink=11 ref=/util/opt/anaconda/deployed-conda-envs/packages/bbmap/envs/bbmap-38.06/opt/bbmap-38.06/resources/adapters.fa

###prepare reference for bowtie mapping; used transcript to gene map option so that instead of just getting isoform-level data, we can actually get gene-level data too (https://deweylab.github.io/RSEM/rsem-prepare-reference.html)
###this command was only run one time (and not for each sample)
rsem-prepare-reference Armillaria_transcriptome.fasta Armillaria --bowtie2 --transcript-to-gene-map Armillaria_gene_trans_map.txt

####Estimate gene and isoform expression from RNA-Seq data; using Bowtie2 to do the mapping; the output for the command below included a bam file: Abor2_1.transcript.bam (https://deweylab.github.io/RSEM/rsem-calculate-expression.html)
rsem-calculate-expression --paired-end Abor2_f_1_um_clean.fq Abor2_r_1_um_clean.fq Armillaria Abor2_1_clean --bowtie2

####Because we only wanted to keep mapped reads that had a mapq score of 30 (0.999 of correctly mapping), I used samtools to create a new bam file of just those... all of which have the .q30.bam extension. This was important to me particularly because of the mixed carpophoroid sample where the two samples are phylogenetically similar
samtools view -q 30 -b Abor2_1_clean.transcript.bam > Abor2_1_clean.q30.bam

###now I redid the calculate expression analysis with q30 bam file as input (to get rid of all of the spurious mapped reads) and got the output file containing gene level expression estimates: Abor2_1_clean.genes.results (for example) (https://deweylab.github.io/RSEM/rsem-calculate-expression.html)
rsem-calculate-expression --alignments Abor2_1_clean.q30.bam --paired-end Armillaria Abor2_1_clean

###this makes a data matrix of all expression results for all samples at each gene... which is then used as input for differential gene expression analysis
###this command was also only run once (obviously)
rsem-generate-data-matrix Arm1_1_clean.genes.results Arm1_2_clean.genes.results Arm1_3_clean.genes.results Arm3_1_clean.genes.results Arm3_2_clean.genes.results Arm3_3_clean.genes.results Arm4_1_clean.genes.results Arm4_2_clean.genes.results Arm4_3_clean.genes.results Abor2_1_clean.genes.results Abor2_2_clean.genes.results Abor2_3_clean.genes.results Abor4_1_clean.genes.results Abor4_2_clean.genes.results Abor4_3_clean.genes.results Abor5_1_clean.genes.results Abor5_2_clean.genes.results Abor5_3_clean.genes.results > Armillaria.counts.genes.q30.matrix
