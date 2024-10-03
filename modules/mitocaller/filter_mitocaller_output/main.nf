process FILTER_HETEROPLASMY {

        publishDir "$params.publishdir/MitoCaller", mode: 'copy'

        input:
        tuple val(samplename), file(summary)
        file(header)
    
        output:
        tuple val(samplename), file("${summary.simpleName}.candidate_heteroplasmy.tsv")
    
        """
        cat ${summary} | awk -F'\t' '{if(\$30 == 1 && \$33 <= 0.96) print \$0}' | cat ${header} - > ${summary.simpleName}.candidate_heteroplasmy.tsv
        """
}
