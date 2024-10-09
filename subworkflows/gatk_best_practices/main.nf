include { MARK_DUPLICATES } from "../../modules/mark_duplicates"
include { BASE_RECALIBRATOR } from "../../modules/bqsr_wes"
include { APPLY_BQSR_WES } from "../../modules/apply_bqsr_wes"
include { HAPLOTYPECALLER_WES } from "../../modules/haplotypecaller_wes"
include { GENOTYPEGVCFS_WES } from "../../modules/genotypegvcfs_wes"
include { GENOTYPEGVCFS_WES_SINGLE_OR_COHORT } from "../../modules/genotypegvcfs_single_or_cohort"

workflow GATK_BEST_PRACTICES {

  take:
  ch_aligned_bam
  ref_genome
  ref_genome_index
  known_snps_dbsnp
  known_indels
  known_snps_dbsnp_index
  known_indels_index
  target_bed

  main:
  ch_versions = Channel.empty()

  MARK_DUPLICATES(ch_aligned_bam)
  ch_versions = ch_versions.mix(MARK_DUPLICATES.out.versions)
  
  BASE_RECALIBRATOR(MARK_DUPLICATES.out[0], ref_genome, ref_genome_index, known_snps_dbsnp_index, known_indels_index, known_snps_dbsnp, known_indels, target_bed)
  ch_versions = ch_versions.mix(BASE_RECALIBRATOR.out.versions)

  APPLY_BQSR_WES(MARK_DUPLICATES.out[0].join(BASE_RECALIBRATOR.out[0]), ref_genome, ref_genome_index)
  ch_versions = ch_versions.mix(APPLY_BQSR_WES.out.versions)

  HAPLOTYPECALLER_WES(APPLY_BQSR_WES.out[0], ref_genome, ref_genome_index, known_snps_dbsnp_index, known_indels_index, known_snps_dbsnp, known_indels, target_bed)
  ch_versions = ch_versions.mix(HAPLOTYPECALLER_WES.out.versions)

  if(params.genotyping_mode == 'single') {
    GENOTYPEGVCFS_WES_SINGLE_OR_COHORT(HAPLOTYPECALLER_WES.out[0], HAPLOTYPECALLER_WES.out[1], HAPLOTYPECALLER_WES.out[2], ref_genome, target_bed)
    ch_versions = ch_versions.mix(GENOTYPEGVCFS_WES_SINGLE_OR_COHORT.out.versions)
  }       
  
  if(params.genotyping_mode == 'joint'){
    GENOTYPEGVCFS_WES_SINGLE_OR_COHORT(HAPLOTYPECALLER_WES.out[0].collect(), HAPLOTYPECALLER_WES.out[1].collect(), HAPLOTYPECALLER_WES.out[2].collect(), ref_genome, target_bed)
    ch_versions = ch_versions.mix(GENOTYPEGVCFS_WES_SINGLE_OR_COHORT.out.versions)
  }
  
  if(params.genotyping_mode == 'family'){
    GENOTYPEGVCFS_WES(HAPLOTYPECALLER_WES.out[1].collect(),HAPLOTYPECALLER_WES.out[2].collect(), ref_genome, target_bed, params.proband)
    GENOTYPEGVCFS_WES.out.versions.ifEmpty { Channel.empty() }
    ch_versions = ch_versions.mix(GENOTYPEGVCFS_WES.out.versions)
  }

  
  emit:
  marked_dup_bam           = MARK_DUPLICATES.out[0]
  bqsr_recal_table         = BASE_RECALIBRATOR.out[0]
  bqsr_bam                 = APPLY_BQSR_WES.out[0]
  gvcf_file                = HAPLOTYPECALLER_WES.out[1]
  gvcf_index               = HAPLOTYPECALLER_WES.out[2]
  raw_vcf                  = params.genotyping_mode == 'family' ? GENOTYPEGVCFS_WES.out[0] : GENOTYPEGVCFS_WES_SINGLE_OR_COHORT.out[0]
  
  versions                 = ch_versions
}

