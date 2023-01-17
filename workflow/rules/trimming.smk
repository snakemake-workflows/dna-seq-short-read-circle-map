rule cutadapt_pe:
    input:
        get_paired_read_files,
    output:
        fastq1="results/trimmed/{sample}/{unit}_R1.fastq.gz",
        fastq2="results/trimmed/{sample}/{unit}_R2.fastq.gz",
        qc="results/trimmed/{sample}/{unit}.paired.qc.txt",
    log:
        "logs/cutadapt/{sample}-{unit}.log",
    params:
        extra=config.get("params", {}).get("cutadapt", ""),
        adapters=get_adapters,
    threads: 8
    wrapper:
        "v1.21.2/bio/cutadapt/pe"
