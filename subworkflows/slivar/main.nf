include { RUN_SLIVAR_TRIO_ANALYSIS } from "../../modules/slivar/trio_analysis/main.nf"
include { ANNOTATE_VEP_SLIVAR } from "../../modules/vep_annotate_slivar/main.nf"
include { VEP_VCF_TO_TSV_SLIVAR } from "../../modules/vcf_to_tsv_slivar/main.nf"
include { RUN_SLIVAR_TRIO_ANALYSIS_TIER2 } from "../../modules/slivar/trio_analysis_tier2/main.nf"
include { ANNOTATE_VEP_SLIVAR as ANNOTATE_VEP_SLIVAR_TIER2 } from "../../modules/vep_annotate_slivar/main.nf"
include { VEP_VCF_TO_TSV_SLIVAR as VEP_VCF_TO_TSV_SLIVAR_TIER2 } from "../../modules/vcf_to_tsv_slivar/main.nf"

workflow SLIVAR_ANALYSIS {

  take:
  ch_decom_norm_vcf
  ref_genome
  ref_genome_index
  gff3_file
  pedfile
  slivar_gnomadpath
  slivar_jspath
  vep_cache_files
  vep_plugin_files
  vcf_to_tsv_script
  mane_transcript
  
  main:
  ch_versions = Channel.empty()

  RUN_SLIVAR_TRIO_ANALYSIS(ch_decom_norm_vcf, ref_genome, ref_genome_index, gff3_file, pedfile, slivar_gnomadpath, slivar_jspath)
  ch_versions = ch_versions.mix(RUN_SLIVAR_TRIO_ANALYSIS.out.versions)

  ANNOTATE_VEP_SLIVAR(RUN_SLIVAR_TRIO_ANALYSIS.out[0].flatten(), vep_cache_files, vep_plugin_files)
  ch_versions = ch_versions.mix(ANNOTATE_VEP_SLIVAR.out.versions)

  VEP_VCF_TO_TSV_SLIVAR(ANNOTATE_VEP_SLIVAR.out[0], vcf_to_tsv_script, mane_transcript)
  ch_versions = ch_versions.mix(VEP_VCF_TO_TSV_SLIVAR.out.versions)

  RUN_SLIVAR_TRIO_ANALYSIS_TIER2(ch_decom_norm_vcf, ref_genome, ref_genome_index, gff3_file, pedfile, slivar_gnomadpath, slivar_jspath)
  ch_versions = ch_versions.mix(RUN_SLIVAR_TRIO_ANALYSIS_TIER2.out.versions)

  ANNOTATE_VEP_SLIVAR_TIER2(RUN_SLIVAR_TRIO_ANALYSIS_TIER2.out[0].flatten(), vep_cache_files, vep_plugin_files)
  ch_versions = ch_versions.mix(ANNOTATE_VEP_SLIVAR_TIER2.out.versions)

  VEP_VCF_TO_TSV_SLIVAR_TIER2(ANNOTATE_VEP_SLIVAR_TIER2.out[0], vcf_to_tsv_script, mane_transcript)
  ch_versions = ch_versions.mix(VEP_VCF_TO_TSV_SLIVAR_TIER2.out.versions)

  emit:
  slivar_trio_analysis_output_raw_vcf    = RUN_SLIVAR_TRIO_ANALYSIS.out[0]
  annotated_slivar_output                = ANNOTATE_VEP_SLIVAR.out[0]
  slivar_tsv                             = VEP_VCF_TO_TSV_SLIVAR.out[0]
  slivar_tsv_tier2                       = VEP_VCF_TO_TSV_SLIVAR_TIER2.out[0]

  versions                 = ch_versions
  
}
