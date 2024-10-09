process SOMALIER_ANCESTRY {

        container 'brentp/somalier'
        publishDir "$params.publishdir/somalier/somalier_ancestry", mode: 'copy', exclude: '*.yml'

        input:
        file(somalier_extract_files)
        file(somalier_onekg_files)
        file(somalier_prism_files)
        stdin samplename

        output:
        file("*.tsv")
        file("*.html")
        path "versions.yml", emit: versions

        script:
        samplename = params.proband
        """
        somalier ancestry --labels 1kg-somalier/ancestry-labels-1kg.tsv 1kg-somalier/*.somalier ++ ./*.somalier -o somalier.1kg.${params.timestamp}
        somalier ancestry --labels prism-somalier/ancestry-labels-prism.tsv prism-somalier/*.somalier ++ ./*.somalier -o somalier.prism.${params.timestamp}

        cat <<-END_VERSIONS > versions.yml
                \$(echo "${task.process}" | sed 's/.*://')\tsomalier:\$(somalier 2>&1 | sed -n '1p' | sed 's/somalier version: //g')
        END_VERSIONS
        """
}
