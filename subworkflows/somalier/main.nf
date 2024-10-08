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
  ch_versions = Channel.empty()

  //default empty channels
  somalier_ancestry_output = Channel.empty()
  somalier_relate_output = Channel.empty()

  if(params.genotyping_mode == "family"){
    SOMALIER_EXTRACT(ch_apply_bqsr_bam, ref_genome, ref_genome_index, somalier_sites, proband_id)
    ch_versions = ch_versions.mix(SOMALIER_EXTRACT.out.versions)

    SOMALIER_ANCESTRY(SOMALIER_EXTRACT.out[0].collect(), somalier_onekg_files, somalier_prism_files, proband_id)
    somalier_ancestry_output = SOMALIER_ANCESTRY.out[0]
    ch_versions = ch_versions.mix(SOMALIER_ANCESTRY.out.versions)
    
    SOMALIER_RELATE(SOMALIER_EXTRACT.out[0].collect(), pedfile, proband_id)
    ch_versions = ch_versions.mix(SOMALIER_RELATE.out.versions)
    somalier_relate_output = SOMALIER_RELATE.out[0]
  }
  

  emit:
  somalier_ancestry_output
  somalier_relate_output

  versions                  = ch_versions
}
