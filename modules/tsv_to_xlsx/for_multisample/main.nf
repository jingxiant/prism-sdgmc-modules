process TSV_TO_XLSX_MULTISAMPLE {

        publishDir ( params.genotyping_mode == 'single' ? "$params.publishdir/$samplename/excel" : "$params.publishdir/excel" ), mode: 'copy', exclude: '*.yml'
        publishDir "$params.publishdir/Software_version/${task.process}", mode: 'copy', pattern: '*.yml'
        container 'jxprismdocker/prism_python3'
        errorStrategy 'ignore'

        input:
        tuple val(samplename), file(rarecoding_tsv)
        file(tsv_to_xlsx)
        file(col_file)

        output:
        tuple val(samplename), file("${samplename}_Variants.xlsx")
        path "versions.yml", emit: versions

        script:
        """
        python3 -W ignore ${tsv_to_xlsx} $rarecoding_tsv ${samplename}_Variants.xlsx ${col_file}

        cat <<-END_VERSIONS > versions.yml
                \$(echo "${task.process}" | sed 's/.*://')\ttsv to xlsv script:${tsv_to_xlsx}
        END_VERSIONS
        """
}
