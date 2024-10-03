include { MERGE_FASTQ } from "../../modules/merge_fastq"
include { ALIGN_READS } from "../../modules/bwa"

workflow BWA_ALIGN_READS {
  take:
  reads
  ref_genome
  ref_genome_index

  main:

  ch_versions = Channel.empty()

  MERGE_FASTQ(reads)
  ALIGN_READS(MERGE_FASTQ.out, ref_genome, ref_genome_index)
  
  ch_versions = ch_versions.mix(ALIGN_READS.out.versions)

  emit:
  aligned_bam              = ALIGN_READS.out[0]
  versions                 = ch_versions

}
