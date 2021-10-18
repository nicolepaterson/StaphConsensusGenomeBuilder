# StaphConsensusGenomeBuilder

Pipeline for generating consensus genomes, using Staphylococcus aureus 8325 as reference. 
Customized for use in the CDC Aspen HPC cluster, may not work in other systems without tweaking.

Dependencies:
fastp 
bowtie2
picard
samtools
bcftools
gatk

```usage: ./consensus.sh -p path/to/fastq -o output.fasta```
