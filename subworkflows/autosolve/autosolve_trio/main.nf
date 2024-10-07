include { AUTOSOLVE_TIER1_TIER2_TRIO } from "../../../modules/autosolve_family/main.nf"

workflow AUTOSOLVE_TRIO {

  take:
  ch_vep_tsv_filtered
  pedfile
  autosolve_script
  clingen
  panel_monoallelic
  panel_biallelic
  mutation_spectrum
       
  main:
  AUTOSOLVE_TIER1_TIER2_TRIO(ch_vep_tsv_filtered, pedfile, autosolve_script, clingen, panel_monoallelic, panel_biallelic, mutation_spectrum)

  emit:
  autosolve_trio_tsv        = AUTOSOLVE_TIER1_TIER2_TRIO.out

  
}
