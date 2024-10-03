process CHECK_FILE_VALIDITY_WES_SINGLESAMPLE {

        container 'jxprismdocker/bcftoolssh'
        publishDir "$params.publishdir/${samplename}/workflow_status", mode: 'copy'
        
        input:
        tuple val(samplename), file(input)
        file check_file_status_script
        file tabulate_samples_quality_script
        file check_sample_stats_script

        output:
        tuple val(samplename), file('*.tsv')

        """
        ls *.genome_results.txt | awk -F'.' '{print \$1}' > sampleid.txt
        bash ${check_file_status_script} WES
        #python ${tabulate_samples_quality_script} ${samplename}
        python ${tabulate_samples_quality_script} sampleid.txt
        bash ${check_sample_stats_script}
        """
}
