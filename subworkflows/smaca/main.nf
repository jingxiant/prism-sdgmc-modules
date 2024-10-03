include { SMACA_BAM } from "../../modules/smaca"

workflow SMACA {

  take:
  ch_apply_bqsr_bam
  ref_genome
  ref_genome_index

  main:
  ch_versions = Channel.empty()

  SMACA_BAM(ch_apply_bqsr_bam, ref_genome, ref_genome_index)
  ch_versions = ch_versions.mix(SMACA_BAM.out.versions)

  emit:
  smaca_tsv                = SMACA_BAM.out[0]
  versions                 = ch_versions
}
