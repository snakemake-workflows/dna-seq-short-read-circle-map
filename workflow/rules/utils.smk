rule bam_index:
    input:
        "{prefix}.bam",
    output:
        "{prefix}.bai",
    log:
        "logs/{prefix}.log",
    threads: 2
    wrapper:
        "v1.21.2/bio/samtools/index"
