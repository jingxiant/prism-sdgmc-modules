include { ANNOTATE_VEP } from "../../modules/vep_annotate"
include { VEP_VCF_TO_TSV } from "../../modules/vcf_to_tsv"

workflow VEP_ANNOTATE {

  take:
  ch_decom_norm_vcf
  vep_cache
  vep_plugins
  vcf_to_tsv_script
  mane_transcript

  main:
  ch_versions = Channel.empty()
  
  ANNOTATE_VEP(ch_decom_norm_vcf, vep_cache, vep_plugins)
  ch_versions = ch_versions.mix(ANNOTATE_VEP.out.versions)

  VEP_VCF_TO_TSV(ANNOTATE_VEP.out[0], vcf_to_tsv_script, mane_transcript)
  ch_versions = ch_versions.mix(VEP_VCF_TO_TSV.out.versions)

  emit:
  annotated_vcf                         = ANNOTATE_VEP.out[0]
  vep_tsv                               = VEP_VCF_TO_TSV.out[0]        
  vep_tsv_filtered                      = VEP_VCF_TO_TSV.out[1]
  vep_tsv_filtered_without_samplename   = VEP_VCF_TO_TSV.out[2]
  vep_tsv_filtered_highqual             = VEP_VCF_TO_TSV.out[3]
  
  versions                 = ch_versions
}
