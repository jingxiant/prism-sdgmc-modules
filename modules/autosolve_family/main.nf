process AUTOSOLVE_TIER1_TIER2_TRIO {

        publishDir "$params.publishdir/autosolve", mode: 'copy'
        container 'jxprismdocker/prism_python3'

        input:
        tuple val(samplename), file(slivar_output)
        file(pedfile)
        file(autosolve_script)
        file(clingen)
        file(panel_monoallelic)
        file(panel_biallelic)
        file(mutation_spectrum)

        output:
        path("*.tsv"), optional: true

        script:
        """
        python3 ${autosolve_script} ${clingen} ${panel_monoallelic} ${panel_biallelic} ${mutation_spectrum} ${samplename} ${slivar_output} 
        """
}
