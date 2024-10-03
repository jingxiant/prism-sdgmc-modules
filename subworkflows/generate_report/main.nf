include { GENERATE_REPORT_RMARKDOWN_SINGLESAMPLE } from "../../modules/rmarkdown_generate_report/single_sample"
include { GENERATE_REPORT_RMARKDOWN_MULTISAMPLE } from "../../modules/rmarkdown_generate_report/multiple_samples"

workflow GENERATE_REPORT {

  take:
  ch_for_rmarkdown
  rmd_template
  resources_log
  panel
  versions_log
  ch_depth_of_coverage
  ch_check_file_output
  
  main:
  if(params.genotyping_mode == 'single'){
    GENERATE_REPORT_RMARKDOWN_SINGLESAMPLE(
      ch_for_rmarkdown, 
      rmd_template, 
      resources_log, 
      panel
      )
    sample_report = GENERATE_REPORT_RMARKDOWN_SINGLESAMPLE.out[0]
  }

  if(params.genotyping_mode == 'joint'){
    GENERATE_REPORT_RMARKDOWN_MULTISAMPLE(
      rmd_template, 
      versions_log, 
      ch_check_file_output, 
      ch_depth_of_coverage, 
      resources_log, 
      panel
      )
    sample_report = GENERATE_REPORT_RMARKDOWN_MULTISAMPLE.out[0]
  }

  emit:
  sample_report
}
