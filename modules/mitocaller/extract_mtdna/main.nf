process EXTRACT_MTDNA_BAM {

        time '30m'
        errorStrategy { 'retry' }
        maxRetries 3
        container 'limwwan/mitocaller'

        input:
        tuple val(samplename), file(recalbam), file(recalbam_idx)
        
        output:
        tuple val(samplename), file("${recalbam.simpleName}.mtdna.bam")

        """
        samtools view -@10 -bh ${recalbam} chrM > ${recalbam.simpleName}.mtdna.bam
        """
}
