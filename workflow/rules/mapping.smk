rule bwa_mem:
    input:
        reads=get_mapping_input,
        idx=multiext(genome, ".amb", ".ann", ".bwt", ".pac", ".sa"),
    output:
        "results/mapped/{sample}/{unit}.bam",
    log:
        "logs/mapped/{sample}/{unit}.log",
    params:
        extra=get_bwa_extra,
        sorting="samtools",  # Can be 'none', 'samtools' or 'picard'.
        sort_order="coordinate",  # Can be 'queryname' or 'coordinate'.
        sort_extra="",  # Extra args for samtools/picard.
    threads: 8
    wrapper:
        "v1.21.2/bio/bwa/mem"


rule merge_unit_bams_per_sample:
    input:
        lambda wc: expand(
            "results/mapped/{{sample}}/{unit}.bam",
            unit = units.loc[units["sample_name" == wildcards.sample], "unit_name"].tolist(),
        ),
    output:
        "results/merged/{sample}.bam",
    log:
        "logs/merged/{sample}.bam",
    threads: 8
    wrapper:
        "v1.21.2/bio/samtools/merge"


rule recalibrate_base_qualities:
    input:
        bam="results/merged/{sample}.bam",
        bai="results/merged/{sample}.bai",
        ref=genome,
        dict=genome_dict,
        ref_fai=genome_fai,
        known="resources/variation.noiupac.vcf.gz",
        tbi="resources/variation.noiupac.vcf.gz.tbi",
    output:
        recal_table=temp("results/recal/{sample}.grp"),
    params:
        extra=config.get("params", {}).get("gatk", {}).get("BaseRecalibrator", ""),
        java_opts="",
    log:
        "logs/recal/baserecalibrator/{sample}.log",
    threads: 8
    wrapper:
        "v1.21.2/bio/gatk/baserecalibratorspark"


ruleorder: apply_bqsr > bam_index


rule apply_bqsr:
    input:
        bam=get_recalibrate_quality_input,
        bai=lambda w: get_recalibrate_quality_input(w, bai=True),
        ref=genome,
        dict=genome_dict,
        ref_fai=genome_fai,
        recal_table="results/recal/{sample}.grp",
    output:
        bam=protected("results/recal/{sample}.coordinate_sort.bam"),
        bai="results/recal/{sample}.coordinate_sort.bai",
    log:
        "logs/recal/apply_bqsr/{sample}.log",
    params:
        extra=config.get("params", {}).get("gatk", {}).get("applyBQSR", ""),
        java_opts="",  # optional
    wrapper:
        "v1.21.2/bio/gatk/applybqsr"


rule samtools_queryname_sort:
    input:
        "results/recal/{sample}.coordinate_sort.bam",
    output:
        protected("results/recal/{sample}.queryname_sort.bam"),
    log:
        "logs/recal/{sample}.queryname_sort.log",
    params:
        extra="-n",
    threads: 4
    wrapper:
        "v1.21.2/bio/samtools/sort"