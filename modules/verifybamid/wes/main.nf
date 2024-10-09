process VERIFYBAMID_WES {

        container 'griffan/verifybamid2'
        publishDir ( params.genotyping_mode == 'single' ? "$params.publishdir/$samplename/verifybamid" : "$params.publishdir/verifybamid" ), mode: 'copy', exclude: '*.yml'
        errorStrategy 'ignore'

        input:
        tuple val(samplename), file(bam), file(bamindex)
        file(ref_fa)
        file(ref_fai)
        file(verifybamid_resources)

        output:
        tuple val(samplename), file("${samplename}*")
        path "versions.yml", emit: versions

        script:
        """
        VerifyBamID --Reference ${params.ref} --BamFile ${bam} --SVDPrefix exome/1000g.phase3.10k.b38.exome.vcf.gz.dat --Output ${samplename}.${params.timestamp}

        cat <<-END_VERSIONS > versions.yml
                \$(echo "${task.process}" | sed 's/.*://')\tVerifyBamID:\$(echo \$(VerifyBamID 2>&1) | sed 's/^.*Version://g; s/ Copyright.*//g')
        END_VERSIONS
        """
}
