rule get_genome:
    output:
        genome,
    log:
        "logs/get-genome.log",
    params:
        species=config["ref"]["species"],
        datatype="dna",
        build=config["ref"]["build"],
        release=config["ref"]["release"],
        chromosome=config["ref"].get("chromosome"),
    cache: "omit-software"
    wrapper:
        "v1.21.2/bio/reference/ensembl-sequence"


rule bwa_index:
    input:
        genome,
    output:
        idx=multiext(genome, ".amb", ".ann", ".bwt", ".pac", ".sa"),
    log:
        "logs/bwa_index.log",
    resources:
        mem_mb=369000,
    cache: True
    wrapper:
        "v1.21.1/bio/bwa/index"


rule genome_faidx:
    input:
        genome,
    output:
        genome_fai,
    log:
        "logs/genome-faidx.log",
    cache: "omit-software"
    wrapper:
        "v1.21.2/bio/samtools/faidx"


rule genome_dict:
    input:
        genome,
    output:
        genome_dict,
    log:
        "logs/samtools/create_dict.log",
    conda:
        "../envs/samtools.yaml"
    cache: "omit-software"
    shell:
        "samtools dict {input} > {output} 2> {log} "


rule get_known_variants:
    input:
        # use fai to annotate contig lengths for GATK BQSR
        fai=genome_fai,
    output:
        vcf="resources/variation.vcf.gz",
    log:
        "logs/get-known-variants.log",
    params:
        species=config["ref"]["species"],
        release=config["ref"]["release"],
        build=config["ref"]["build"],
        type="all",
        chromosome=config["ref"].get("chromosome"),
    cache: "omit-software"
    wrapper:
        "v1.21.2/bio/reference/ensembl-variation"


rule remove_iupac_codes:
    input:
        "resources/variation.vcf.gz",
    output:
        "resources/variation.noiupac.vcf.gz",
    log:
        "logs/fix-iupac-alleles.log",
    conda:
        "../envs/rbt.yaml"
    cache: "omit-software"
    shell:
        "(rbt vcf-fix-iupac-alleles < {input} | bcftools view -Oz > {output}) 2> {log}"


rule tabix_known_variants:
    input:
        "resources/{prefix}.vcf.gz",
    output:
        "resources/{prefix}.vcf.gz.tbi",
    log:
        "logs/tabix/{prefix}.vcf.log",
    cache: "omit-software"
    params:
        "-p vcf",
    wrapper:
        "v1.21.2/bio/tabix/index"
