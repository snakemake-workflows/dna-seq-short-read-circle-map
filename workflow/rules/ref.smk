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


rule get_annotation:
    output:
        "resources/genomic_annotations.gff3.gz",
    params:
        species=config["ref"]["species"],
        release=config["ref"]["release"],
        build=config["ref"]["build"],
    log:
        "logs/get-annotation.log",
    cache: "omit-software"
    localrule: True
    wrapper:
        "v3.13.0/bio/reference/ensembl-annotation"


rule get_regulatory_features_gff3_gz:
    output:
        "resources/regulatory_annotations.gff3.gz",  # presence of .gz determines if downloaded is kept compressed
    params:
        species=config["ref"]["species"],
        release=config["ref"]["release"],
        build=config["ref"]["build"],
    log:
        "logs/get_regulatory_features.log",
    cache: "omit-software"  # save space and time with between workflow caching (see docs)
    wrapper:
        "v3.13.0/bio/reference/ensembl-regulation"


rule create_transcripts_to_genes_mappings:
    output:
        mapping="resources/transcripts_to_genes_mappings.tsv.gz",
    params:
        species=get_bioc_species_name,
        release=config["ref"]["release"],
        build=config["ref"]["build"],
        chromosome=config["ref"].get("chromosome", ""),
    log:
        "logs/transcripts_to_genes_mappings.log",
    conda:
        "../envs/biomart.yaml"
    cache: "omit-software"  # save space and time with between workflow caching (see docs)
    script:
        "../scripts/create_transcripts_to_genes_mappings.R"


rule create_annotation_gff:
    input:
        genomic_annotations="resources/genomic_annotations.gff3.gz",
        mapping="resources/transcripts_to_genes_mappings.tsv.gz",
        regulatory_annotations="resources/regulatory_annotations.gff3.gz",
    output:
        all_annotations="resources/all_annotations.harmonized.gff3.gz",
    log:
        "logs/all_annotations.harmonized.gff3.log"
    conda:
        "../envs/rtracklayer.yaml"
    params:
        build=config["ref"]["build"],
    script:
        "../scripts/create_annotation_gff3.R"
