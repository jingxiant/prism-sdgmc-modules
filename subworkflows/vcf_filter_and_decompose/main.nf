include { HARDFILTER_VARIANTS } from "../../modules/hardfilter_variants"
include { DECOMPOSE_AND_NORMALIZE } from "../../modules/decompose_normalize"

workflow VCF_FILTER_AND_DECOMPOSE {

  take:
  ch_raw_vcf
  ref_genome
  ref_genome_index

  main:
  ch_versions = Channel.empty()

  HARDFILTER_VARIANTS(ch_raw_vcf, ref_genome, ref_genome_index)
  ch_versions = ch_versions.mix(HARDFILTER_VARIANTS.out.versions)

  DECOMPOSE_AND_NORMALIZE(HARDFILTER_VARIANTS.out[0], ref_genome, ref_genome_index)
  ch_versions = ch_versions.mix(DECOMPOSE_AND_NORMALIZE.out.versions)

  emit:
  filtered_vcfs            = HARDFILTER_VARIANTS.out[0]
  decom_norm_vcf           = DECOMPOSE_AND_NORMALIZE.out[0]

  versions                 = ch_versions
  
}
