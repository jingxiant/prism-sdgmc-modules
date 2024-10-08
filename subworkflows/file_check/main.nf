include { GET_TOOLS_VERSION } from "../../modules/file_check/get_tools_version"
include { LOG_PARAMS } from "../../modules/log_params"
include { CHECK_FILE_VALIDITY_WES_MULTISAMPLE } from "../../modules/file_check/check_file_validity_multisample"
include { CHECK_FILE_VALIDITY_WES_SINGLESAMPLE } from "../../modules/file_check/check_file_validity_singlesample"
include { CHECK_FILE_VALIDITY_WES } from "../../modules/file_check/check_file_validity_trio"

workflow CHECK_FILE_VALIDITY {

  take:
  ch_versions_log
  modify_versions_log_script
  parameters_file
  ch_for_filecheck
  check_file_status_script
  tabulate_samples_quality_script
  check_sample_stats_script
  ch_depth_of_coverage_stats 
  ch_vcf_filtered_tsv
  ch_decom_norm_vcf
  ch_verifybamid_wes
  ch_edit_qualimap
  ch_slivar_tsv
  ch_somalier_relate
  
  main:
  GET_TOOLS_VERSION(ch_versions_log, modify_versions_log_script)

  LOG_PARAMS(parameters_file)


  if(params.genotyping_mode == 'single'){
    if (params.small_panel == true){
      println "Processing single sample with small_panel = true"
    } else if (params.small_panel == false) {
      println "Processing single sample with small_panel = false"
    }
    CHECK_FILE_VALIDITY_WES_SINGLESAMPLE(
          ch_for_filecheck, 
          check_file_status_script,
          tabulate_samples_quality_script, 
          check_sample_stats_script
        )
        check_file_validity_wes_output = CHECK_FILE_VALIDITY_WES_SINGLESAMPLE.out[0]
  }
  
  /*if(params.genotyping_mode == 'single' && params.small_panel == 'true'){
        println "Running for single sample with small panel"
        CHECK_FILE_VALIDITY_WES_SINGLESAMPLE(
          ch_for_filecheck, 
          check_file_status_script,
          tabulate_samples_quality_script, 
          check_sample_stats_script
        )
        check_file_validity_wes_output = CHECK_FILE_VALIDITY_WES_SINGLESAMPLE.out[0]
      } 

    if(params.genotyping_mode == 'single' && params.small_panel == 'false'){
        println "Running for single sample with full panel"
        CHECK_FILE_VALIDITY_WES_SINGLESAMPLE(
          ch_for_filecheck, 
          check_file_status_script,
          tabulate_samples_quality_script, 
          check_sample_stats_script
        )
        check_file_validity_wes_output = CHECK_FILE_VALIDITY_WES_SINGLESAMPLE.out[0]
      }
  */

  if(params.genotyping_mode == 'joint'){
    CHECK_FILE_VALIDITY_WES_MULTISAMPLE(
      ch_depth_of_coverage_stats, 
      ch_vcf_filtered_tsv, 
      ch_decom_norm_vcf, 
      ch_verifybamid_wes, 
      ch_edit_qualimap, 
      check_file_status_script,
      tabulate_samples_quality_script,
      check_sample_stats_script
      )
    check_file_validity_wes_output = CHECK_FILE_VALIDITY_WES_MULTISAMPLE.out[0]
    }

  if(params.genotyping_mode == 'family'){
    CHECK_FILE_VALIDITY_WES(
      ch_depth_of_coverage_stats, 
      ch_vcf_filtered_tsv, 
      ch_decom_norm_vcf,
      ch_slivar_tsv,
      ch_verifybamid_wes,
      ch_edit_qualimap,
      ch_somalier_relate,
      check_file_status_script,
      tabulate_samples_quality_script,
      check_sample_stats_script      
      )
    check_file_validity_wes_output = CHECK_FILE_VALIDITY_WES.out[0]   
  }


  emit:
  version_txt                                  = GET_TOOLS_VERSION.out[0]
  params_log                                   = LOG_PARAMS.out
  check_file_validity_wes_output 
  
}
