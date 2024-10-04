process EXOMEDEPTH_POSTPROCESS_FAMILY {

        publishDir "$params.publishdir/exomedepth_postprocess", mode: 'copy'
        container 'jxprismdocker/prism_python3'
       
        input:
        tuple val(samplename), file(exomedepth), file(vep), file(pedfile)
        file(process_script_family)
        file(panel)
        file(clingen)
        file(mutation_spectrum)
        file(decipher)


        output:
        path("*.tsv"), optional: true
    
      """
      python3 ${process_script_family} ${panel} ${clingen} ${mutation_spectrum} ${decipher} ${exomedepth} ${vep} ${pedfile} ${samplename}.exomedepth.postprocess.tsv
      """
}
