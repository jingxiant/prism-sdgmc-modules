process RUN_QUALIMAP_WES{

        container 'jxprismdocker/prism_qualimap'
        publishDir "$params.publishdir/$samplename", mode: 'copy', exclude: '*.yml'

        input:
        tuple val(samplename), file(recalbam), file(recalbam_index)
        file(target_bed)

        output:
        tuple val(samplename), file("*BQSR_stats/*")
        path "versions.yml", emit: versions

        script:
        """
        unset DISPLAY
        qualimap bamqc -gff $target_bed -bam $recalbam --java-mem-size=40G -nt 20

        cat <<-END_VERSIONS > versions.yml
                \$(echo "${task.process}" | sed 's/.*://')\tqualimap bamqc:\$( echo \$(qualimap bamqc 2>&1) | sed 's/.*QualiMap v/v/' | sed 's/ Built.*//g')
        END_VERSIONS
        """
}
