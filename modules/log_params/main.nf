process LOG_PARAMS {
        
        publishDir "$params.publishdir/Log_files", mode: 'copy'
        
        input:
        file(input_params_file)

        output:
        file('resources.log')

        script:
        """
        cat ${input_params_file} > resources.log
        """
}
