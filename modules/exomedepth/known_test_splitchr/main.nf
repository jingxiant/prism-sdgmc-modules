process EXOMEDEPTH_KNOWN_TEST_SPLITCHR {
    publishDir "$params.publishdir/exomedepth/known_case", mode: 'copy'
    container 'limwwan/exomedepth'

    input:
    file(exomedepth_control)
    file(exomedepth_case)
    file(ref_fa)
    file(ref_fai)
    file(target_bed)
    file(gene_bed)
    each chr 
    file(test_sample)

    output: 
    stdout
    path("*/*.tsv"), optional: true
    path("*/*/*/*.png"), optional: true
    path("*/*.rds"), optional: true
    path "versions.yml", emit: versions
 
    """
    #!/usr/bin/env Rscript
    library(ExomeDepth)
    library(Rsamtools)
    r = as.character(R.version\$version.string)
    x = as.character(packageVersion("ExomeDepth"))
    y = as.character(packageVersion("Rsamtools"))
    filepath <- getwd()
    outfile = paste(filepath,"versions.yml",sep='/')
    version_lines <- c(r,paste("ExomeDepth:", x), paste("Rsamtools:", y))
    version_lines_collapse <- paste(version_lines, collapse = ";")
    final_version_lines <- paste("EXOMEDEPTH", version_lines_collapse, sep = "\t")
    writeLines(final_version_lines, outfile)
    fasta <- "${ref_fa}"
    target_bed <- "${target_bed}"
    gene_bed <- "${gene_bed}"
    chr <- "${chr}"
    bam <- list.files("./", pattern = "*.bam\$")
    bai <- list.files("./", pattern = "*.bai\$")
    print("Reading target regions for $chr from $target_bed")
    print(chr)

    read.bed = function(f) {
      read.table(f, col.names=c("chromosome","start","end","name"))
    }

    exon.bed = read.bed(pipe("grep '$chr[^0-9]' $target_bed")) 
    print(head(exon.bed))
    
    gene38 <- read.table("$gene_bed", header = FALSE, sep = '\t')
    colnames(gene38) <- c('chromosome','start','end','name')
    gene38.GRanges <- GenomicRanges::GRanges(seqnames = gene38\$chromosome,
                                         IRanges::IRanges(start=gene38\$start,end=gene38\$end),
                                         names = gene38\$name)
    print(gene38.GRanges)

    bam.files.temp <- unlist(strsplit(bam, " ")) 
    print(bam.files.temp)
    
    filepath <- getwd()

    bam.files <- paste(filepath, "/", bam.files.temp, sep="")
    print(bam.files)
    
    all.samples = sapply(bam.files, function(file.name) {
        # Scan the bam header and parse out the sample name from the first read group
        read.group.info = strsplit(scanBamHeader(file.name)[[1]]\$text[["@RG"]],":")
        names(read.group.info) = sapply(read.group.info, function(field) field[[1]])
        return(read.group.info\$SM[[2]])
    })
    print(sprintf("Processing %d samples",length(all.samples)))
    print(all.samples)

    bam.counts <- getBamCounts(bed.frame = exon.bed,
                              bam.files = bam.files,
                              include.chr = F,
                              referenceFasta = fasta)
    print("Successfully counted reads in BAM files")
    print(head(bam.counts))

    colnames(bam.counts)[6:ncol(bam.counts)] = c(all.samples)
    print(head(bam.counts))

    
    samples = readLines("$test_sample")
    samples_list <- strsplit(samples, ",")[[1]]
    for (i in samples_list) {
        edited_i = gsub("\\\\..*","",i)
        test.sample = all.samples[match(edited_i, all.samples)]
        #test.sample = all.samples[match(sub("^([A-Z0-9]+)\\..*", "\\1", i), all.samples)]
        #test.sample = all.samples[match(i, all.samples)]
        test.sample.count = bam.counts[test.sample][[1]]
        reference.sample.temp = head(all.samples[-match(test.sample,all.samples)],n=20)
        reference.sample.count = as.matrix(bam.counts[,reference.sample.temp])
        reference = select.reference.set(test.counts = test.sample.count, 
                                    reference.counts = reference.sample.count,
                                    bin.length = (bam.counts\$end - bam.counts\$start)/1000,
                                    n.bins.reduced = 10000)

        print(test.sample)
        print(head(test.sample.count))
        print(reference.sample.temp)
        print(head(reference.sample.count))
        print(reference)

        # Get counts just for the reference set
        selected.reference = apply(X=reference.sample.count[,reference\$reference.choice,drop=F],MARGIN=1,FUN=sum)
        #print(selected.reference)

        # Run Exomedepth
        all.exons = new("ExomeDepth",
                    test = test.sample.count, 
                    reference = selected.reference,
                    formula = "cbind(test, reference) ~ 1")

        found.cnvs = CallCNVs(x = all.exons,
                    transition.probability = 0.0001,
                    chromosome = bam.counts\$chromosome,
                    start = bam.counts\$start,
                    end = bam.counts\$end,
                    name = bam.counts\$exon)
        
        results = found.cnvs@CNV.calls
        print(results)
        
        dir.create(test.sample)

           if(length(found.cnvs@CNV.calls) != 0){
            found.cnvs.annotate <- AnnotateExtra(x = found.cnvs,
                            reference.annotation = gene38.GRanges,
                            min.overlap = 0.0001,
                            column.name = 'gene.hg38')
            results.annotate = found.cnvs.annotate@CNV.calls[order(found.cnvs.annotate@CNV.calls\$BF, decreasing = TRUE),]
            print(results.annotate)
            outfile = paste(test.sample, "${params.timestamp}", "exomedepth.${chr}.tsv", sep='.')
            write.table(file=paste(file.path(".",test.sample),outfile,sep='/'),
                        x=results.annotate,
                        row.names=F,
                        sep='\t')

            #datalist = list(all.samples, bam.counts, found.cnvs.annotate@CNV.calls, results.annotate)
            #saveRDS(datalist, paste(file.path(".",test.sample,paste(test.sample,".RData",sep='')),sep='/'))
            
            saveRDS(found.cnvs.annotate, paste(file.path(".",test.sample,paste(test.sample, "${params.timestamp}", "found.cnvs.annotate.${chr}.rds",sep='.')),sep='/'), compress=TRUE)
            saveRDS(results.annotate, paste(file.path(".",test.sample,paste(test.sample, "${params.timestamp}", "results.annotate.${chr}.rds",sep='.')),sep='/'), compress=TRUE)

            dir.create(file.path(test.sample, 'plot', '${chr}'), recursive = TRUE, showWarnings = FALSE)

            for(x in 1:nrow(results.annotate)){
                file = paste(paste(test.sample,results.annotate\$chromosome[x],results.annotate\$start[x],results.annotate\$end[x],sep="_"),".${params.timestamp}",".png",sep="")
                
                png(paste(file.path(".",test.sample,'plot','${chr}'),file,sep='/'))
                plot (found.cnvs.annotate,
                    sequence = results.annotate\$chromosome[x],
                    xlim = c(results.annotate\$start[x] - 100000, results.annotate\$end[x] + 100000),
                    count.threshold = 20,
                    main = results.annotate\$id[x],
                    cex.lab = 0.8,
                    with.gene = TRUE)
                dev.off()
            }
        }
    }
    """
}
