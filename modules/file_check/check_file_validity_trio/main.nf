process CHECK_FILE_VALIDITY_WES {

        container 'jxprismdocker/bcftoolssh'
        publishDir "$params.publishdir/workflow_status", mode: 'copy'
 
        input:
        file doc_samplesummary
        file filtered_tsv
        file decompose_normalized_vcf
        file slivar_tsv
        file verifybamid
        file bamqc_stats
        file somalier_relate
        file check_file_status_script
        file tabulate_samples_quality_script
        file check_sample_stats_script

        output:
        file('*.tsv')

        """
        ls *.genome_results.txt | awk -F'.' '{print \$1}' > sampleid.txt
        bash ${check_file_status_script} WES
        python ${tabulate_samples_quality_script} sampleid.txt
        bash ${check_sample_stats_script}
        """
}
