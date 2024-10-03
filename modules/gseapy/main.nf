process RUN_EXOMEDEPTH_GSEAPY {

        publishDir "$params.publishdir/exomedepth/gseapy_enrich", mode: 'copy'
        container 'jxprismdocker/prism_gseapy'
        errorStrategy 'ignore'

        input:
        tuple val(samplename), file(del_output), file(dup_output)
        file(gene_sets)
        file(gseapy_enrich_script)

        output:
        tuple val(samplename), file('*.merged.del.counts.genes.gseapy.filtered.tsv'), optional: true
        tuple val(samplename), file('*.merged.dup.counts.genes.gseapy.filtered.tsv'), optional: true
        path "versions.yml", emit: versions, optional: true

        script:
        """
        python ${gseapy_enrich_script} ${samplename}.${params.timestamp}.merged.del.counts.genes.tsv ${gene_sets} ${samplename}.${params.timestamp}.merged.del.counts.genes.gseapy.tsv
        python ${gseapy_enrich_script} ${samplename}.${params.timestamp}.merged.dup.counts.genes.tsv ${gene_sets} ${samplename}.${params.timestamp}.merged.dup.counts.genes.gseapy.tsv
        cat ${samplename}.${params.timestamp}.merged.del.counts.genes.gseapy.tsv | awk -F'\t' '{temp = \$5 + 0; if(temp < 0.05) print \$0}' > ${samplename}.${params.timestamp}.merged.del.counts.genes.gseapy.filtered.tsv
        cat ${samplename}.${params.timestamp}.merged.dup.counts.genes.gseapy.tsv | awk -F'\t' '{temp = \$5 + 0; if(temp < 0.05) print \$0}' > ${samplename}.${params.timestamp}.merged.dup.counts.genes.gseapy.filtered.tsv

        cat <<-END_VERSIONS > versions.yml
                EXOMEDEPTH_GSEAPY\tpython:\$(python --version 2>&1 | sed 's/Python //g' ); gseapy:\$(python -c 'import gseapy; print(gseapy.__version__)' 2>&1)
        END_VERSIONS
        """
}
