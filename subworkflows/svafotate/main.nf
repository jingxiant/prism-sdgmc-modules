include { SVAFOTATE_FOR_EXOMEDEPTH } from "../../modules/exomedepth/svafotate"

workflow SVAFOTATE {

  take:
  ch_exomedepth_merge_tsv
  convert_tsv_to_vcf_script_for_exomedepth
  svafotate_bed

  main:
  SVAFOTATE_FOR_EXOMEDEPTH(ch_exomedepth_merge_tsv, convert_tsv_to_vcf_script_for_exomedepth, svafotate_bed)

  emit:
  svafotate_vcf                = SVAFOTATE_FOR_EXOMEDEPTH.out
}
