process EXOMEDEPTH_POSTPROCESS_COHORT {

        publishDir "$params.publishdir/exomedepth_postprocess", mode: 'copy'
        container 'jxprismdocker/prism_python3'

        input:
        tuple val(samplename), file(exomedepth)
        file(vep)
        file(process_script_single)
        file(panel)
        file(clingen)
        file(mutation_spectrum)
        file(decipher)

        output:
        path("*.tsv"), optional: true
    
        """
        python3 ${process_script_single} ${panel} ${clingen} ${mutation_spectrum} ${decipher} ${exomedepth} ${vep} ${samplename} ${samplename}.exomedepth.postprocess.tsv
        """
}
