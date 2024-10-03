process SVAFOTATE_FOR_EXOMEDEPTH {

        container 'jxprismdocker/prism_svafotate:latest'
        errorStrategy 'ignore'

        input:
        file(exomedepth_filtered_tsv)
        file(convert_tsv_to_vcf_script)
        file(svafotate_bed)

        output:
        file("*.svafotated.vcf")

        script:
        """
        python ${convert_tsv_to_vcf_script} ${exomedepth_filtered_tsv} ${exomedepth_filtered_tsv.baseName}.vcf
        bcftools sort ${exomedepth_filtered_tsv.baseName}.vcf -o ${exomedepth_filtered_tsv.baseName}.sorted.vcf
        svafotate annotate -v ${exomedepth_filtered_tsv.baseName}.sorted.vcf -o ${exomedepth_filtered_tsv.baseName}.svafotated.vcf -b ${svafotate_bed} -f 0.5
        """
}
