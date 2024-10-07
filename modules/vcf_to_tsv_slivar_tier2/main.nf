process VEP_VCF_TO_TSV_SLIVAR_TIER2 {

        publishDir "$params.publishdir/slivar_tier2", mode: 'copy', exclude: '*.yml'
        container 'jxprismdocker/prism_python3'
        errorStrategy 'ignore'

        input:
        tuple val(samplename), file(slivar_output), file(slivar_output_index)
        file(vcf_to_tsv)
        file(mane_transcript)

        output:
        tuple val(samplename), file("*.vep.tsv")
        path "versions.yml", emit: versions

        script:
        filename="\$(echo ${slivar_output.baseName} | cut -d'.' -f1-7)"

        """
        python3 -W ignore ${vcf_to_tsv} $slivar_output ${mane_transcript} ${filename}.tsv ${filename}.filtered.tsv ${filename}.filtered.highqual.tsv --samplename ${samplename}

        cat <<-END_VERSIONS > versions.yml
                ${task.process}\tpython:\$(python --version 2>&1 | sed 's/Python //g' ); vcf to tsv script:${vcf_to_tsv}
        END_VERSIONS
        """
}
