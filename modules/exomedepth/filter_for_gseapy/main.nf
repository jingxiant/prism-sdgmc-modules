process EXOMEDEPTH_FILTER_FOR_GSEAPY {
    
    publishDir "$params.publishdir/exomedepth/gseapy_enrich", mode: 'copy'
    container 'jxprismdocker/prism_python3'

    input:
    tuple val(samplename), file(tsv)
    file(exomedepth_annotate_counts_script)
    file(exomedepth_deletion_db)
    file(exomedepth_duplication_db)

    output:
    tuple val(samplename), file("${samplename}.${params.timestamp}.merged.del.counts.genes.tsv")
    tuple val(samplename), file("${samplename}.${params.timestamp}.merged.dup.counts.genes.tsv")

    """
    python3 ${exomedepth_annotate_counts_script} ${tsv} ${exomedepth_deletion_db} ${exomedepth_duplication_db} ${samplename}.${params.timestamp}.merged.del.counts.tsv ${samplename}.${params.timestamp}.merged.dup.counts.tsv
    awk -F'\t' '{if(\$14 <= 3) print \$13}' ${samplename}.${params.timestamp}.merged.del.counts.tsv | tr "," "\n" | sort | uniq > ${samplename}.${params.timestamp}.merged.del.counts.genes.tsv
    awk -F'\t' '{if(\$14 <= 3) print \$13}' ${samplename}.${params.timestamp}.merged.dup.counts.tsv | tr "," "\n" | sort | uniq > ${samplename}.${params.timestamp}.merged.dup.counts.genes.tsv
    """
}
