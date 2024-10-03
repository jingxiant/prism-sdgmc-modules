process EXOMEDEPTH_FILTER_MERGE_TSV {

        container 'jxprismdocker/prism_python3'
        publishDir ( params.case == 'known' ? "$params.publishdir/exomedepth/known_case/mergedchr_tsv" : "$params.publishdir/exomedepth/all_sample/mergedchr_tsv" ), mode: 'copy'

        input:
        file(tsv)
        file(svafotate_vcf)
        file(exomedepth_annotate_counts_script)
        file(exomedepth_deletion_db)
        file(exomedepth_duplication_db)
        file(add_svaf_script)

        output:
        path("*.merged.filtered.tsv")

        script:
        """
        python3 ${exomedepth_annotate_counts_script} ${svafotate_vcf.simpleName}.${params.timestamp}.exomedepth.merged.tsv ${exomedepth_deletion_db} ${exomedepth_duplication_db} ${svafotate_vcf.simpleName}.merged.del.counts.tsv ${svafotate_vcf.simpleName}.merged.dup.counts.tsv
        python3 ${add_svaf_script} ${svafotate_vcf} ${svafotate_vcf.simpleName}.merged.del.counts.tsv ${svafotate_vcf.simpleName}.merged.del.counts.svaf.temp.tsv
        python3 ${add_svaf_script} ${svafotate_vcf} ${svafotate_vcf.simpleName}.merged.dup.counts.tsv ${svafotate_vcf.simpleName}.merged.dup.counts.svaf.temp.tsv
        head -n1 ${svafotate_vcf.simpleName}.merged.del.counts.svaf.temp.tsv > header
        awk -F'\t' '{if(\$14 <= 3) print \$0}' ${svafotate_vcf.simpleName}.merged.del.counts.svaf.temp.tsv > ${svafotate_vcf.simpleName}.exomedepth.merged.del.filtered.tsv
        awk -F'\t' '{if(\$14 <= 3) print \$0}' ${svafotate_vcf.simpleName}.merged.dup.counts.svaf.temp.tsv > ${svafotate_vcf.simpleName}.exomedepth.merged.dup.filtered.tsv
        cat header ${svafotate_vcf.simpleName}.exomedepth.merged.del.filtered.tsv ${svafotate_vcf.simpleName}.exomedepth.merged.dup.filtered.tsv > ${svafotate_vcf.simpleName}.${params.timestamp}.exomedepth.merged.filtered.tsv
        """
}
