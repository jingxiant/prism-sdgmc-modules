process APPLY_BQSR {

        container 'jxprismdocker/prism_bwa_gatk'
        publishDir "$params.publishdir/$samplename", mode: 'copy', exclude: '*.yml'

        input:
        tuple val(samplename), file(sortedbam), file(sortedbam_index), file(recal_table)
        file(ref_fa)
        file(ref_fai)

        output:
        tuple val(samplename), file("${sortedbam.simpleName}.${params.timestamp}.BQSR.bam"), file("${sortedbam.simpleName}.${params.timestamp}.BQSR.bai")
        path "versions.yml", emit: versions

        script:
        """
        gatk ApplyBQSR -R $params.ref -I $sortedbam --bqsr-recal-file ${recal_table} -O ${sortedbam.simpleName}.${params.timestamp}.BQSR.bam
        
        cat <<-END_VERSIONS > versions.yml
        \$(echo "${task.process}" | sed 's/.*://')\tgatk:\$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
        END_VERSIONS
        """
}
