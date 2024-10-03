process EXOMEDEPTH_MERGE_TSV {
    
    container 'jxprismdocker/prism_python3'
    publishDir ( params.case == 'known' ? "$params.publishdir/exomedepth/known_case/mergedchr_tsv" : "$params.publishdir/exomedepth/all_sample/mergedchr_tsv" ), mode: 'copy'
    
    input:
    path(tsv)

    output:
    path("*.exomedepth.merged.tsv")
        
    """
    #!/usr/bin/env python
    import os

    tsv_path = "${tsv}".split()
    print(tsv_path)
    
    tsv_dict = {}
    tsv_name_dict = {}
    for file in tsv_path: 
        sampleid = file.split('.')[0]
        
        #print(sampleid)
        tsv_name = file

        #if tsv_name in tsv_name_dict:
        #    tsv_name_dict[tsv_name].append(sampleid)
        #else:
        #    tsv_name_dict[tsv_name] = [sampleid]

        if sampleid in tsv_dict:
            tsv_dict[sampleid].append(tsv_name)
        else:
            tsv_dict[sampleid] = [tsv_name]
    print(tsv_dict)
    for sampleid in tsv_dict:
        tsv_list = tsv_dict[sampleid]
        #print(tsv_list)
        header_flag = 0
        for i in tsv_list:
            if header_flag == 0:
                cmd1 = "head -n1 " + i + " > header.tsv"
                os.system(cmd1)
                header_flag = 1
            
            cmd2 = "cat " + i + '''| awk 'FNR!=1{print}' >>''' + sampleid + ".${params.timestamp}.exomedepth.merged.noheader.tsv"
            
            os.system(cmd2)
            print(cmd2)
        cmd3 = "cat header.tsv " + sampleid + ".${params.timestamp}.exomedepth.merged.noheader.tsv > " + sampleid + ".${params.timestamp}.exomedepth.merged.tsv"
        print(cmd3)
        os.system(cmd3)
        
    """
}
