process GENERATE_REPORT_RMARKDOWN_MULTISAMPLE {

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
        Rscript -e "rmarkdown::render('${template}', output_file = paste('${params.cohort}.',Sys.Date(),'.report.pdf',sep=''),\\
        params = list(title = 'Analysis Report for ${params.cohort} and Family', date = '${params.timestamp}',\\
        tools_version_path = '${versions_log}',\\
        sample_quality_data_path = 'samples_quality_check.tsv',\\
        sample_coverage_data = 'samples_coverage_status.tsv',\\
        resources_log = '${resources_log}',\\
        mendeliome = '${panel}'))"
        """
}
