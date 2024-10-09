process SMACA_BAM {
        
        publishDir ( params.genotyping_mode == 'single' ? "$params.publishdir/${bam[1].simpleName}/smaca" : "$params.publishdir/smaca" ), mode: 'copy', exclude: ['*.yml']
        container 'limwwan/smaca'

        input: 
        file(bam)
        file(ref_fa)
        file(ref_fai)

        output:
        file("*.tsv")
        path "versions.yml", emit: versions

        script:
        """
        echo *.BQSR.bam | tr " " "\n" > bam.list
        smaca --reference hg38 --output smaca.${params.timestamp}.result.tsv \$(cat bam.list)

        cat <<-END_VERSIONS > versions.yml
                \$(echo "${task.process}" | sed 's/.*://')\tsmaca:\$(pip show smaca 2>&1 | grep "Version" | sed 's/Version: //g')
        """
}
