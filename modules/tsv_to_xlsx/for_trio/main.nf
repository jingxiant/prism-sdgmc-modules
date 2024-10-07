process TSV_TO_XLSX_TRIO {

        publishDir "$params.publishdir/excel", mode: 'copy', exclude: '*.yml'
        container 'jxprismdocker/prism_python3'
        errorStrategy 'ignore'

        input:
        file(slivar_tsv_files)
        tuple val(samplename), file(rarecoding_tsv)
        file(tsv_to_xlsx)
        file(col_file)

        output:
        tuple val(samplename), file("${samplename}_${params.timestamp}_Variants.xlsx")
        path "versions.yml", emit: versions

        script:
        """
        python3 -W ignore ${tsv_to_xlsx} $rarecoding_tsv ${samplename}_${params.timestamp}_Variants.xlsx ${col_file} --slivar_denovo_tsv ${samplename}.${params.timestamp}.slivar.denovo.vcf.vep.tsv --slivar_comphet_tsv ${samplename}.${params.timestamp}.slivar.comphet.vcf.vep.tsv --slivar_recessive_tsv ${samplename}.${params.timestamp}.slivar.recessive.vcf.vep.tsv

        cat <<-END_VERSIONS > versions.yml
                ${task.process}\tpython:\$(python --version 2>&1 | sed 's/Python //g' ); tsv to xlsv script:${tsv_to_xlsx}
        END_VERSIONS
        """
}
