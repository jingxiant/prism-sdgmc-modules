process COMPARE_SAMPLE_MITOMAP_MITOTIP {

        container 'jxprismdocker/prism_python3'    
        publishDir "$params.publishdir/MitoCaller", mode: 'copy'

        input:
        tuple val(samplename), file(heteroplasmy)
        file(mitocaller_result_filter)
        file(mitomap)
        file(mitotip)
        file(mitimpact)
    
        output:
        tuple val(samplename), file("${samplename}.mitocaller.filtered.output.tsv")

        """
        python3 ${mitocaller_result_filter} ${mitomap} ${mitotip} ${heteroplasmy} ${mitimpact} ${samplename}.mitocaller.filtered.output.tsv
        """    
}
