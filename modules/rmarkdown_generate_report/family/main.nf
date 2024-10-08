process GENERATE_REPORT_RMARKDOWN {

        container 'limwwan/rmarkdown'
        publishDir "$params.publishdir/analysis_report", mode: 'copy'
                
        input:
        file template
        file versions_log
        file sample_analysis_log
        file depth_of_coverage_summary
        file resources_log
        file panel

        output:
        file("*")

        """
        Rscript -e "rmarkdown::render('${template}', output_file = paste('${params.proband}.',Sys.Date(),'.report.pdf',sep=''),\\
        params = list(title = 'Analysis Report for ${params.proband} and Family', date = '${params.timestamp}',\\
        tools_version_path = '${versions_log}',\\
        sample_quality_data_path = 'samples_quality_check.tsv',\\
        sample_coverage_data = 'samples_coverage_status.tsv',\\
        sample_gender_data = 'samples_gender_check.tsv',\\
        sample_relatedness_data = 'samples_relatedness_check.tsv',\\
        resources_log = '${resources_log}',\\
        mendeliome = '${panel}'))"
        """
}
