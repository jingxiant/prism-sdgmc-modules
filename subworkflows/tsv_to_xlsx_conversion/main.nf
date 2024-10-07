include { TSV_TO_XLSX_TRIO } from "../../modules/tsv_to_xlsx/for_trio"
include { TSV_TO_XLSX_MULTISAMPLE } from "../../modules/tsv_to_xlsx/for_multisample/"

workflow TSV_TO_XLSX {

  take:
  ch_slivar_tsv
  ch_vep_filtered_tsv
  tsv_to_xlsx_script
  column_file

  main:

  ch_versions = Channel.empty()

  if(params.genotyping_mode == 'single' || params.genotyping_mode == 'joint'){
    TSV_TO_XLSX_MULTISAMPLE(ch_vep_filtered_tsv, tsv_to_xlsx_script, column_file)
    excel_file = TSV_TO_XLSX_MULTISAMPLE.out
    ch_versions = ch_versions.mix(TSV_TO_XLSX_MULTISAMPLE.out.versions)
  }

  if(params.genotyping_mode == 'family'){
    TSV_TO_XLSX_TRIO(ch_slivar_tsv, ch_vep_filtered_tsv, tsv_to_xlsx_script, column_file)
    excel_file = TSV_TO_XLSX_TRIO.out
    ch_versions = ch_versions.mix(TSV_TO_XLSX_TRIO.out.versions)
  }
  ch_versions = ch_versions.mix(ALIGN_READS.out.versions)

  emit:
  excel_file
  versions                 = ch_versions
}
