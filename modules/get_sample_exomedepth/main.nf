process GET_SAMPLES_FOR_EXOMEDEPTH {
        
        input:
        file(bqsr_bam)
        
        output:
        file("samples.txt")

        """
        echo *.BQSR.bam | sed 's/\\.BQSR\\.bam//g' | tr " " "," > samples.txt
        """
}
