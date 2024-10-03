process GENERATE_REPORT_RMARKDOWN_SINGLESAMPLE {

        container 'limwwan/rmarkdown'
        publishDir "$params.publishdir/$samplename/analysis_report", mode: 'copy'

        input:
        tuple val(samplename), file(joined_input)
        file template
        file resources_log
        file panel
        
        output:
        file("*")
        
        script:
        """
        Rscript -e "rmarkdown::render('${template}', output_file = paste('${samplename}.',Sys.Date(),'.report.pdf',sep=''),\\
        params = list(title = 'Analysis Report for ${samplename}', date = '${params.timestamp}',\\
        tools_version_path = 'versions.txt',\\
        sample_quality_data_path = 'samples_quality_check.tsv',\\
        sample_coverage_data = 'samples_coverage_status.tsv',\\
        resources_log = '${resources_log}',\\
        mendeliome = '${panel}'))"
        """
}
