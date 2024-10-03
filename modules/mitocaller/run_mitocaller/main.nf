process MITOCALLER {

        container 'limwwan/mitocaller'
        publishDir "$params.publishdir/MitoCaller", mode: 'copy'

        input:
        tuple val(samplename), file(bam)
        file(ref_fa)
    
        output:
        tuple val(samplename), file("${bam.simpleName}.mitocaller.output.summary")

        """
        mitoCaller -m -b ${bam} -r $params.ref > ${bam.simpleName}.mitocaller.output.summary
        """
}
