include { SOMALIER_EXTRACT } from "../../modules/somalier/extract"
include { SOMALIER_ANCESTRY } from "../../modules/somalier/ancestry"
include { SOMALIER_RELATE} from "../../modules/somalier/relate"

workflow SOMALIER {

  take:
  ch_apply_bqsr_bam
  ref_genome
  ref_genome_index
  somalier_sites
  proband_id
  pedfile
  somalier_onekg_files
  somalier_prism_files
  
  main:
  SOMALIER_EXTRACT(ch_apply_bqsr_bam, ref_genome, ref_genome_index, somalier_sites, proband_id)
  SOMALIER_ANCESTRY(SOMALIER_EXTRACT.out[0].collect(), pedfile, proband_id)
  SOMALIER_RELATE(SOMALIER_EXTRACT.out[0].collect(), pedfile, proband_id)

  ch_versions = Channel.empty()

  emit:
  somalier_ancestry_output  = SOMALIER_ANCESTRY.out[0]
  somalier_relate_output    = SOMALIER_RELATE.out[0]

  versions                  = ch_versions
}
