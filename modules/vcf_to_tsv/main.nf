process VEP_VCF_TO_TSV {

        container 'jxprismdocker/prism_python3'
        publishDir ( params.genotyping_mode == 'single' ? "$params.publishdir/$samplename/vep" : "$params.publishdir/vep" ), mode: 'copy', exclude: '*.yml'

        input:
        tuple val(samplename), file(vep_output), file(vep_output_index)
        file(vcf_to_tsv)
        file(mane_transcript)

        output:
        tuple val(samplename), file("${samplename}.${params.timestamp}.vep.tsv.gz")
        tuple val(samplename), file("${samplename}.${params.timestamp}.vep.filtered.tsv")
        file("${samplename}.${params.timestamp}.vep.filtered.tsv")
        tuple val(samplename), file("${samplename}.${params.timestamp}.vep.filtered.highqual.tsv")
        path "versions.yml", emit: versions

        script:
        """
        python3 -W ignore ${vcf_to_tsv} ${vep_output} ${mane_transcript} ${samplename}.${params.timestamp}.vep.tsv ${samplename}.${params.timestamp}.vep.filtered.tsv ${samplename}.${params.timestamp}.vep.filtered.highqual.tsv --samplename ${samplename}
        bgzip -f ${samplename}.${params.timestamp}.vep.tsv

        cat <<-END_VERSIONS > versions.yml
                ${task.process}\tpython:\$(python --version 2>&1 | sed 's/Python //g' ); vcf to tsv script: ${vcf_to_tsv}
        END_VERSIONS
        """
}
