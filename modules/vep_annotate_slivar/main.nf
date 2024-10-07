process ANNOTATE_VEP_SLIVAR{

        container = 'ensemblorg/ensembl-vep:release_109.3'
        publishDir "$params.publishdir/slivar", mode: 'copy', exclude: '*.yml'
        errorStrategy 'ignore'

        input:
        file(slivarvcf)
        file(vep_cache_files)
        file(vep_plugin_files)
        
        output:
        tuple val(slivarvcf.simpleName), file("${slivarvcf.baseName}.vep.vcf.gz"), file("${slivarvcf.baseName}.vep.vcf.gz.tbi")
        path "versions.yml", emit: versions

        """
        echo $slivarvcf
        vep --assembly GRCh38 --refseq --exclude_predicted --cache --dir ${vep_cache_files} --dir_plugins ${params.vep_cache_plugin_dir} --fork 20 -i ${slivarvcf} -o ${slivarvcf.baseName}.vep.vcf \
        ${params.vep_commands} \
        --plugin dbNSFP,${params.dbNSFP},PrimateAI_pred,PrimateAI_rankscore,PrimateAI_score,REVEL_rankscore,REVEL_score,Aloft_Fraction_transcripts_affected,Aloft_prob_Tolerant,Aloft_prob_Recessive,Aloft_prob_Dominant,Aloft_pred,Aloft_Confidence \
        --plugin AlphaMissense,file=${params.AlphaMissense} \
        --plugin SpliceAI_WK2,snv=${params.SpliceAI_snp},indel=${params.SpliceAI_snp} \
        -custom ${params.gnomad_exomes},gnomADe,vcf,exact,0,AC,AF,AN,controls_AF,controls_AF_nfe,controls_AF_eas,controls_AF_asj,controls_AF_amr,controls_AF_afr,controls_AF_oth,controls_AF_sas,controls_nhomalt \
        -custom ${params.gnomad_genomes},gnomADg_3,vcf,exact,0,AC,AF,AN,AF_nfe,AF_eas,AF_asj,AF_amr,AF_afr,AF_oth,AF_sas,nhomalt \
        -custom ${params.clinvar},ClinVar,vcf,exact,0,CLNREVSTAT,CLNSIG,CLNVC,CLNDN,CLNSIGCONF \
        -custom ${params.SEC},SEC_3523,vcf,exact,0,AC,AF \
        -custom ${params.PRISM_Interpretation},PRISM_InterpretedVariants,vcf,exact,0,Review_process,Final_classification \
        -custom ${params.sg10k},SG10K,vcf,exact,0,AC,AF,AN,NHOMALT \
        --fields ${params.fields_recipe}
        bgzip -f ${slivarvcf.baseName}.vep.vcf; tabix -p vcf ${slivarvcf.baseName}.vep.vcf.gz
        
        cat <<-END_VERSIONS > versions.yml
                ${task.process}\tensemblvep:\$( echo \$(vep --help 2>&1) | sed 's/^.*Versions:.*ensembl-vep : //;s/ .*\$//')
        END_VERSIONS
        """
}
