process GET_TOOLS_VERSION {

        container 'jxprismdocker/prism_python3'
        publishDir "$params.publishdir/Log_files", mode: 'copy'

        input:
        file(versions_file)
        file(modify_script)

        output:
        file('versions.txt')

        """
        python3 ${modify_script} $versions_file versions.txt
        """
}
