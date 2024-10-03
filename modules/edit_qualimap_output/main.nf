process EDIT_QUALIMAP_OUTPUT {

        input:
        tuple val(samplename), file(qualimap_output)

        output:
        tuple val(samplename), file("${samplename}.genome_results.txt"), file("${samplename}.qualimapReport.html")

        """
        mv genome_results.txt ${samplename}.genome_results.txt
        mv qualimapReport.html ${samplename}.qualimapReport.html
        """
}
