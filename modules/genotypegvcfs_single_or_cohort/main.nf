process GENOTYPEGVCFS_WES_SINGLE_OR_COHORT {

        container 'jxprismdocker/prism_bwa_gatk'
        publishDir ( params.genotyping_mode == 'single' ? "$params.publishdir/$samplename/vcf" : "$params.publishdir/jointcalling" ), mode: 'copy'
        
        input:
                val(samplename) 
                file(gvcf)
                file(gvcf_tbi)
                file(ref_fai)
                file(target_bed)

        output:
                tuple val(samplename), file("*.raw.vcf.gz"), file("*.raw.vcf.gz.tbi")
                path "versions.yml", emit: versions 
 
        script:
        samplename = params.genotyping_mode == 'single' ? "${samplename}" : "${params.cohort}"
         
        if(params.genotyping_mode == 'joint'){
        """
                echo ${gvcf} | tr " " "\n" > gvcf.list
                gatk CombineGVCFs -R $params.ref -V gvcf.list -O ${samplename}.${params.timestamp}.combinedgvcf.vcf.gz
                gatk GenotypeGVCFs -R $params.ref -V ${samplename}.${params.timestamp}.combinedgvcf.vcf.gz  -O ${samplename}.${params.timestamp}.raw.vcf.gz -L $target_bed
                
                cat <<-END_VERSIONS > versions.yml
                        \$(echo "${task.process}" | sed 's/.*://')\tgatk:\$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
        """
        }
        else if(params.genotyping_mode == 'single'){
        """
                gatk GenotypeGVCFs -R $params.ref -V ${gvcf} -O ${samplename}.${params.timestamp}.raw.vcf.gz -L $target_bed
                
                cat <<-END_VERSIONS > versions.yml
                        \$(echo "${task.process}" | sed 's/.*://')\tgatk:\$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
        """
        }
}
