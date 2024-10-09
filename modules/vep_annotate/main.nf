process ANNOTATE_VEP {
        
        container = 'ensemblorg/ensembl-vep:release_109.3'
        publishDir ( params.genotyping_mode == 'single' ? "$params.publishdir/$samplename/vep" : "$params.publishdir/vep" ), mode: 'copy', exclude: '*.yml'

        input:
        tuple val(samplename), file(filtered_decomp_norm_vcf), file(filtered_decomp_norm_vcf_index)
        file(vep_cache_files)
        file(vep_plugin_files)

        output:
        tuple val(samplename), file("${samplename}.${params.timestamp}.vep.vcf.gz"), file("${samplename}.${params.timestamp}.vep.vcf.gz.tbi")
        path "versions.yml", emit: versions

        script:
        """
        vep --assembly GRCh38 --refseq --exclude_predicted --cache --dir ${vep_cache_files} --dir_plugins ${params.vep_cache_plugin_dir} --fork 20 -i ${filtered_decomp_norm_vcf} -o ${samplename}.${params.timestamp}.vep.vcf \
        ${params.vep_commands} \
        --plugin dbNSFP,${params.dbNSFP},PrimateAI_pred,PrimateAI_rankscore,PrimateAI_score,REVEL_rankscore,REVEL_score,Aloft_Fraction_transcripts_affected,Aloft_prob_Tolerant,Aloft_prob_Recessive,Aloft_prob_Dominant,Aloft_pred,Aloft_Confidence \
        --plugin AlphaMissense,file=${params.AlphaMissense} \
        --plugin SpliceAI_WK2,snv=${params.SpliceAI_snp},indel=${params.SpliceAI_indel} \
        -custom ${params.gnomad_exomes},gnomADe,vcf,exact,0,AC,AF,AN,controls_AF,controls_AF_nfe,controls_AF_eas,controls_AF_asj,controls_AF_amr,controls_AF_afr,controls_AF_oth,controls_AF_sas,controls_nhomalt \
        -custom ${params.gnomad_genomes},gnomADg_3,vcf,exact,0,AC,AF,AN,AF_nfe,AF_eas,AF_asj,AF_amr,AF_afr,AF_oth,AF_sas,nhomalt \
        -custom ${params.clinvar},ClinVar,vcf,exact,0,CLNREVSTAT,CLNSIG,CLNVC,CLNDN,CLNSIGCONF \
        -custom ${params.SEC},SEC_3523,vcf,exact,0,AC,AF \
        -custom ${params.PRISM_Interpretation},PRISM_InterpretedVariants,vcf,exact,0,Review_process,Final_classification \
        -custom ${params.sg10k},SG10K,vcf,exact,0,AC,AF,AN,NHOMALT \
        --fields ${params.fields_recipe} 
        bgzip -f ${samplename}.${params.timestamp}.vep.vcf; tabix -p vcf ${samplename}.${params.timestamp}.vep.vcf.gz

        cat <<-END_VERSIONS > versions.yml
                \$(echo "${task.process}" | sed 's/.*://')\tensemblvep:\$( echo \$(vep --help 2>&1) | sed 's/^.*Versions:.*ensembl-vep : //;s/ .*\$//')
        END_VERSIONS
        """
}
