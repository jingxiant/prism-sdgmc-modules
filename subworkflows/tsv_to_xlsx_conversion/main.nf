include { TSV_TO_XLSX_TRIO } from "../../modules/tsv_to_xlsx/for_trio"
include { TSV_TO_XLSX_MULTISAMPLE } from "../../modules/tsv_to_xlsx/for_multisample/"

workflow CONVERT_TSV_TO_XLSX {

  take:
  ch_slivar_tsv
  ch_vep_filtered_tsv
  tsv_to_xlsx_script
  column_file


  main:

  emit:

}
