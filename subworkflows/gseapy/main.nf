include {RUN_EXOMEDEPTH_GSEAPY_DEL} from "../../modules/gseapy/deletion"
include {RUN_EXOMEDEPTH_GSEAPY_DUP} from "../../modules/gseapy/duplication"

workflow GSEAPY {

  take:
  ch_exomedepth_del_tsv_for_gseapy
  ch_exomedepth_dup_tsv_for_gseapy
  gene_sets
  gseapy_enrich_script

  main:
  ch_versions = Channel.empty()
  RUN_EXOMEDEPTH_GSEAPY_DEL(ch_exomedepth_del_tsv_for_gseapy, gene_sets, gseapy_enrich_script)
  ch_versions = ch_versions.mix(RUN_EXOMEDEPTH_GSEAPY_DEL.out.versions)

  RUN_EXOMEDEPTH_GSEAPY_DUP(ch_exomedepth_dup_tsv_for_gseapy, gene_sets, gseapy_enrich_script)
  ch_versions = ch_versions.mix(RUN_EXOMEDEPTH_GSEAPY_DUP.out.versions)

  emit:
  gseapy_output_del_tsv        = RUN_EXOMEDEPTH_GSEAPY_DEL.out[0]
  gseapy_output_dup_tsv        = RUN_EXOMEDEPTH_GSEAPY_DUP.out[1]
  
  versions                 = ch_versions
}
