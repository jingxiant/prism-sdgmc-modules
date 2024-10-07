include { AUTOSOLVE_TIER1_TIER2_MULTISAMPLE } from "../../../modules/autosolve_multisample"
include { AUTOSOLVE_TIER1_TIER2_TRIO } from "../../../modules/autosolve_family"

workfloe AUTOSOLVE {

  take:
  ch_vep_tsv_filtered
  pedfile
  autosolve_script
  clingen
  panel_monoallelic
  panel_biallelic
  mutation_spectrum
  
  main:
  
  if(params.genotyping_mode == 'single' || params.genotyping_mode == 'joint'){
    AUTOSOLVE_TIER1_TIER2_MULTISAMPLE(ch_vep_tsv_filtered ,autosolve_script, clingen, panel_monoallelic, panel_biallelic, mutation_spectrum)
    autosolve_output_tsv = AUTOSOLVE_TIER1_TIER2_MULTISAMPLE.out[0]
  }
  
  if(params.genotyping_mode == 'family'){
    AUTOSOLVE_TIER1_TIER2_TRIO(ch_vep_tsv_filtered, pedfile, autosolve_script, clingen, panel_monoallelic, panel_biallelic, mutation_spectrum)
    autosolve_output_tsv = AUTOSOLVE_TIER1_TIER2_TRIO.out[0]
  }
  
  emit:
    autosolve_output_tsv
}
