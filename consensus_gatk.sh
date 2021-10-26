
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

ml picard
picard AddOrReplaceReadGroups \
I=${FILE}.bam \
O=rg_${FILE}.bam \
RGID=4 \
RGLB=lib1 \
RGPL=ILLUMINA \
RGPU=unit1 \
RGSM=20
ml -picard

samtools index rg_${FILE}.bam

ml gatk 
gatk CreateSequenceDictionary -R ${REFERENCE}
gatk --java-options "-Xmx4g" HaplotypeCaller -R ${REFERENCE} -I rg_${FILE}.bam -O ${FILE}.bam.vcf
bgzip ${FILE}.bam.vcf
bcftools index ${FILE}.bam.vcf.gz
bcftools consensus -f ${REFERENCE} ${FILE}.bam.vcf.gz > ${OUT}_${FILE}_consensus.fasta
ml -samtools
ml -bcftools
ml -gatk

echo "Script complete"

