include { EXTRACT_MTDNA_BAM } from "../../modules/mitocaller/extract_mtdna"
include { MITOCALLER } from "../../modules/mitocaller/run_mitocaller"
include { FILTER_HETEROPLASMY } from "../../modules/mitocaller/filter_mitocaller_output"
include { COMPARE_SAMPLE_MITOMAP_MITOTIP } from "../../modules/mitocaller/mitomap_mitotip_filtering"


workflow MITOCALLER_ANALYSIS {

  take:
  ch_recalbam
  ref_genome
  header_file
  mitocaller_result_filter_script
  mitomap
  mitotip
  mitimpact
  
  main:
  EXTRACT_MTDNA_BAM(ch_recalbam)
  MITOCALLER(EXTRACT_MTDNA_BAM.out, ref_genome)
  FILTER_HETEROPLASMY(MITOCALLER.out[0],header_file)
  COMPARE_SAMPLE_MITOMAP_MITOTIP(FILTER_HETEROPLASMY.out[0], mitocaller_result_filter_script, mitomap, mitotip, mitimpact)

  emit:
  mitocaller_output_summary             = MITOCALLER.out[0]
  mitocaller_candidate_variants         = FILTER_HETEROPLASMY.out[0]
  mitocaller_filtered_output            = COMPARE_SAMPLE_MITOMAP_MITOTIP.out[0]
  
}
