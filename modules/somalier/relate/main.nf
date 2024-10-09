process SOMALIER_RELATE {

        container 'brentp/somalier'
        publishDir "$params.publishdir/somalier/somalier_relate", mode: 'copy', exclude: '*.yml'

        input:
        file(somalier_extract_files)
        file(pedfile)
        stdin samplename

        output:
        file("*.tsv")
        file("*.html")
        path "versions.yml", emit: versions

        script:
        samplename = params.proband
        """
        somalier relate ./*.somalier --ped ${pedfile} -o somalier.${params.timestamp}

        cat <<-END_VERSIONS > versions.yml
                \$(echo "${task.process}" | sed 's/.*://')\tsomalier:\$(somalier 2>&1 | sed -n '1p' | sed 's/somalier version: //g')
        END_VERSIONS
        """
}
