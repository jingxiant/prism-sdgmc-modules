process RUN_SLIVAR_TRIO_ANALYSIS{

        container 'jxprismdocker/prism_slivar'
        publishDir "$params.publishdir/slivar", mode: 'copy', exclude: '*.yml'

        input:
        tuple val(samplename), file(filtered_decomp_norm_vcf), file(filtered_decomp_norm_vcf_index)
        file(ref_fa)
        file(ref_fai)
        file(gff3)
        file(pedfile)
        file(slivar_gnomadpath)
        file(slivar_jspath)

        output:
        tuple file("${samplename}.${params.timestamp}.slivar.comphet.vcf.gz"), file("${samplename}.${params.timestamp}.slivar.denovo.vcf.gz"), file("${samplename}.${params.timestamp}.slivar.recessive.vcf.gz")
        path "versions.yml", emit: versions

        script:
        """
        #Quickly annotate with consequence
        bcftools csq -s - --ncsq 40 -g $gff3 -l -f $ref_fa $filtered_decomp_norm_vcf | bgzip -c > ${samplename}.${params.timestamp}.bcsq.vcf.gz

        # 1. GET COMPHET
        slivar expr --vcf ${samplename}.${params.timestamp}.bcsq.vcf.gz --ped $pedfile --trio 'comphet_side:comphet_side(kid, mom, dad) && INFO.gnomad_nhomalt_controls < 10 && INFO.gnomad_popmax_af < 0.05' --js ${slivar_jspath} --pass-only --info 'variant.FILTER == "PASS" && INFO.impactful' -g ${slivar_gnomadpath} | bgzip -c > ${samplename}.${params.timestamp}.comphet_candidates.vcf.gz
        slivar compound-hets -v ${samplename}.${params.timestamp}.comphet_candidates.vcf.gz --sample-field comphet_side -p $pedfile | bgzip -c > ${samplename}.${params.timestamp}.slivar.comphet.vcf.gz

        # 2. GET DENOVO
        slivar expr --vcf ${samplename}.${params.timestamp}.bcsq.vcf.gz --ped $pedfile --family-expr 'denovo:fam.every(segregating_denovo) && INFO.gnomad_popmax_af < 0.001' --family-expr 'x_denovo:(variant.CHROM == "X" || variant.CHROM == "chrX") && fam.every(segregating_denovo_x) && INFO.gnomad_popmax_af < 0.001' --js ${slivar_jspath} --pass-only --info 'variant.FILTER == "PASS" && INFO.impactful' -g ${slivar_gnomadpath} | bgzip -c > ${samplename}.${params.timestamp}.slivar.denovo.vcf.gz

        # 3. GET RECESSIVE
        slivar expr --vcf ${samplename}.${params.timestamp}.bcsq.vcf.gz --ped $pedfile --family-expr 'recessive:fam.every(segregating_recessive)' --family-expr 'x_recessive:(variant.CHROM == "X" || variant.CHROM == "chrX") && fam.every(segregating_recessive_x)' --js ${slivar_jspath} --pass-only --info 'variant.FILTER == "PASS" && INFO.impactful && INFO.gnomad_popmax_af < 0.05' -g ${slivar_gnomadpath} | bgzip -c > ${samplename}.${params.timestamp}.slivar.recessive.vcf.gz

        cat <<-END_VERSIONS > versions.yml
                \$(echo "${task.process}" | sed 's/.*://')\tbcftools:\$(bcftools --version 2>&1 | sed -n '1p' | sed 's/bcftools //g; s/ .*//'); slivar:\$(slivar 2>&1 | sed -n '1p' |sed 's/^> slivar version: //g; s/ .*//g')
        END_VERSIONS
        """
}
