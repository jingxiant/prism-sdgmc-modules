include { RUN_QUALIMAP_WES } from "../../modules/qualimap_wes"
include { DEPTH_OF_COVERAGE_WES } from "../../modules/depth_of_coverage"
include { EDIT_QUALIMAP_OUTPUT } from "../../modules/edit_qualimap_output"
include { VERIFYBAMID_WES } from "../../modules/verifybamid/wes"

workflow BAM_QC {

  take:
  ch_apply_bqsr
  targeted_bed_covered
  ref_genome
  ref_genome_index
  refgene_track
  verifybamid_resources

  main:
  ch_versions = Channel.empty()

  RUN_QUALIMAP_WES(ch_apply_bqsr, targeted_bed_covered)
  DEPTH_OF_COVERAGE_WES(ch_apply_bqsr, ref_genome, ref_genome_index, refgene_track, targeted_bed_covered)
  EDIT_QUALIMAP_OUTPUT(RUN_QUALIMAP_WES.out[0])

  VERIFYBAMID_WES(ch_apply_bqsr, ref_genome, ref_genome_index, verifybamid_resources)
  ch_versions = ch_versions.mix(VERIFYBAMID_WES.out.versions)

  emit:
  qualimap_stats           = RUN_QUALIMAP_WES.out[0]
  depth_of_coverage_stats  = DEPTH_OF_COVERAGE_WES.out[0]
  versions                 = ch_versions
  edited_qualimap_output   = EDIT_QUALIMAP_OUTPUT.out[0]
  verifybam_id_output      = VERIFYBAMID_WES.out[0]

  versions                 = ch_versions
}
