include { AUTOSOLVE_TIER1_TIER2_MULTISAMPLE } from "../../../modules/autosolve_multisample/main.nf"

workflow AUTOSOLVE_MULTISAMPLE {

  take:
  ch_vep_tsv_filtered
  autosolve_script
  clingen
  panel_monoallelic
  panel_biallelic
  mutation_spectrum

  main:
  //ch_versions = Channel.empty()

  AUTOSOLVE_TIER1_TIER2_MULTISAMPLE(ch_vep_tsv_filtered ,autosolve_script, clingen, panel_monoallelic, panel_biallelic, mutation_spectrum)

  emit:
  autosolve_tsv  = AUTOSOLVE_TIER1_TIER2_MULTISAMPLE.out

}
