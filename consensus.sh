#!/usr/bin/bash

#Creates a consensus genome from a reference and SRR fastq file 
#Usage params: ./consensus.sh -i input_files -o output_directory 
#Modules: fastp, bowtie2, samtools, bcftools

usage() { echo "Usage: $0 -i input -r reference_genome -o output_filename"; exit 1; }
  
while getopts ":i:r:o:" arg; do	
	case "${arg}" in
		i) 
			FILE=${OPTARG}
			;;
		r)
			REFERENCE=${OPTARG}
			;;
		o)
			OUTPUT=${OPTARG}
			;;
		*)
			usage
			;;
	esac
done

shift $((OPTIND-1))

if [ -z "${FILE}" ] || [ -z "${OUTPUT}" ]; then
	usage
fi

ml fastp 
fastp -i ${FILE} -o fp_${FILE}.fastq
ml -fastp

ml bowtie2
bowtie2-build ${REFERENCE} refdict
bowtie2 --local -x refdict -U fp_${FILE}.fastq -S ${FILE}.sam
ml -bowtie2

ml samtools
samtools sort -@ 1 ${FILE}.sam -o ${FILE}.bam
samtools index ${FILE}.bam
ml bcftools
bcftools mpileup -f ${REFERENCE} -6 ${FILE}.bam -o pile_${FILE}.bam
bcftools call -c pile_${FILE}.bam -o call_${FILE}.vcf
bgzip call_${FILE}.vcf call_${FILE}.vcf
bcftools index call_${FILE}.vcf.gz
bcftools consensus -f ${REFERENCE} call_${FILE}.vcf.gz > ${FILE}_consensus.fasta
ml -samtools
ml -bcftools

echo "Script complete"
 
