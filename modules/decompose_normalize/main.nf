process DECOMPOSE_AND_NORMALIZE {

        container 'jxprismdocker/prism_vt_picard'
        publishDir ( params.genotyping_mode == 'single' ? "$params.publishdir/$samplename/vcf" : "$params.publishdir/jointcalling" ), mode: 'copy', exclude: '*.yml'
        
        input:
        tuple val(samplename), file(filtered_snp_vcf), file(filtered_snp_vcf_index), file(filtered_indel_vcf), file(filtered_indel_vcf_index)
        file(ref_fa)
        file(ref_fai)
        
        output:
        tuple val(samplename), file("${samplename}.${params.timestamp}.decomposed.normalized.vcf.gz"), file("${samplename}.${params.timestamp}.decomposed.normalized.vcf.gz.tbi")
        path "versions.yml", emit: versions

        script:
        """
        java -jar /usr/local/bin/picard.jar MergeVcfs I=${filtered_snp_vcf} I=${filtered_indel_vcf} O=${samplename}.${params.timestamp}.filtered.combined.vcf.gz
        vt decompose -s ${samplename}.${params.timestamp}.filtered.combined.vcf.gz | bgzip -c > ${samplename}.${params.timestamp}.decomposed.vcf.gz
        vt normalize -r ${ref_fa} ${samplename}.${params.timestamp}.decomposed.vcf.gz | bgzip -c >  ${samplename}.${params.timestamp}.decomposed.normalized.vcf.gz
        tabix ${samplename}.${params.timestamp}.decomposed.normalized.vcf.gz
        
        cat <<-END_VERSIONS > versions.yml
                \$(echo "${task.process}" | sed 's/.*://')\tvt:\$(echo \$(vt --version 2>&1) | sed 's/vt //; s/The.*//')
        END_VERSIONS
        """
}
