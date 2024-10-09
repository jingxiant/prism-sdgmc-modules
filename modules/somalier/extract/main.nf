process SOMALIER_EXTRACT {

        container 'brentp/somalier'
        publishDir "$params.publishdir/somalier", mode: 'copy', exclude: '*.yml'

        input:
        tuple val(samplename), file(bam), file(bai)
        file(ref)
        file(ref_fai)
        file(somalier_sites)
        stdin samplename

        output:
        tuple val(samplename), file("*.somalier")
        path "versions.yml", emit: versions

        script:
        samplename = params.proband
        """
        somalier extract -d ./ --sites ${somalier_sites} -f ${params.ref} ${bam}

        cat <<-END_VERSIONS > versions.yml
                \$(echo "${task.process}" | sed 's/.*://')\tsomalier:\$(somalier 2>&1 | sed -n '1p' | sed 's/somalier version: //g')
        END_VERSIONS
        """
}
