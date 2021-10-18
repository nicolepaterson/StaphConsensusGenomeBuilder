# StaphConsensusGenomeBuilder

Pipeline for generating consensus genomes, Staphylococcus aureus 8325 provided as optional reference. 
Customized for use in the CDC Aspen HPC cluster, may not work in other systems without tweaking.

Dependencies:
fastp 
bowtie2
samtools
bcftools

```usage: ./consensus.sh -p path/to/fastq -o output.fasta```
