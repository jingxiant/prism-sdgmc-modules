process DEPTH_OF_COVERAGE_WES {
        
        tag "${sampleid}"
        container 'limwwan/gatk-4.2'
        publishDir "$params.publishdir/$sampleid/Depth_of_coverage", mode: 'copy', exclude: '*.yml'

        input:
        tuple val(sampleid), file(bam), file(bai)
        file(ref)
        file(ref_fai)
        file(refseq_gene_track)
        file(target_bed)

        output:
        tuple val(sampleid), file("${sampleid}*")
        path "versions.yml", emit: versions

        script:
        """
        gatk DepthOfCoverage -R ${params.ref} -O ${sampleid}.${params.timestamp} -I ${bam} -gene-list ${refseq_gene_track} --omit-depth-output-at-each-base --summary-coverage-threshold 10 --summary-coverage-threshold 20 --interval-merging-rule OVERLAPPING_ONLY -L ${target_bed}
        
        cat <<-END_VERSIONS > versions.yml
                \$(echo "${task.process}" | sed 's/.*://')\tgatk:\$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
        END_VERSIONS
        """
}
