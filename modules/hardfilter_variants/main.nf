process HARDFILTER_VARIANTS {

        container 'jxprismdocker/prism_bwa_gatk'
        publishDir ( params.genotyping_mode == 'single' ? "$params.publishdir/$samplename/vcf" : "$params.publishdir/jointcalling" ), mode: 'copy', exclude: '*.yml'

        input:
        tuple val(samplename), file(rawvcf), file(rawvcf_index)
        file(ref_fa)
        file(ref_fai)

        output:
        tuple val(samplename), file("${samplename}.${params.timestamp}.filtered_snp.vcf.gz"), file("${samplename}.${params.timestamp}.filtered_snp.vcf.gz.tbi"), file("${samplename}.${params.timestamp}.filtered_indel.vcf.gz"), file("${samplename}.${params.timestamp}.filtered_indel.vcf.gz.tbi")
        path "versions.yml", emit: versions

        script:
        """
        gatk SelectVariants -R $params.ref -V $rawvcf -select-type SNP -O "${samplename}.raw.snp"
        gatk SelectVariants -R $params.ref -V $rawvcf -select-type INDEL -O "${samplename}.raw.indel"
        gatk VariantFiltration -R $params.ref -V "${samplename}.raw.snp" --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" --filter-name "snp_hardfilter" -O "${samplename}.${params.timestamp}.filtered_snp.vcf.gz"
        gatk VariantFiltration -R $params.ref -V "${samplename}.raw.indel" --filter-expression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0" --filter-name "indel_hardfilter" -O "${samplename}.${params.timestamp}.filtered_indel.vcf.gz"
        
        cat <<-END_VERSIONS > versions.yml
                \$(echo "${task.process}" | sed 's/.*://')\tgatk:\$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
        END_VERSIONS
        """
}
