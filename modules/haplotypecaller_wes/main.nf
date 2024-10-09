process HAPLOTYPECALLER_WES{

        container 'jxprismdocker/prism_bwa_gatk'
        publishDir "$params.publishdir/$samplename", mode: 'copy', exclude: '*.yml'
        input:
                tuple val(samplename), file(recalbam), file(recalbam_index)
                file(ref_fa)
                file(ref_fai)
                file(known_snps_dbsnp_index)
                file(known_indels_index)
                file(known_snps_dbsnp)
                file(known_indels)
                file(target_bed)

        output:
                val(samplename)
                file("${recalbam.simpleName}.${params.timestamp}.g.vcf.gz")
                file("${recalbam.simpleName}.${params.timestamp}.g.vcf.gz.tbi")
                path "versions.yml", emit: versions

        script:
        """
        gatk HaplotypeCaller -I $recalbam -O ${recalbam.simpleName}.${params.timestamp}.g.vcf.gz --emit-ref-confidence GVCF -R $params.ref -L $target_bed
        
        cat <<-END_VERSIONS > versions.yml
                $(echo "${task.process}" | sed 's/.*://')\tgatk:\$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
                //${task.process}\tgatk:\$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
        END_VERSIONS
        """
}
