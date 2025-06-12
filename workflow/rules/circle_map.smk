rule circle_map_extract_reads:
    input:
        "results/recal/{sample}.queryname_sort.bam",
    output:
        temp("results/candidate_reads/{sample}.circle_candidate_reads.bam"),
    log:
        "logs/candidate_reads/{sample}.circle_candidate_reads.log",
    conda:
        "../envs/circle_map.yaml"
    shell:
        "Circle-Map ReadExtractor -i {input} -o {output} 2>{log}"


rule samtools_sort_candidates:
    input:
        "results/candidate_reads/{sample}.circle_candidate_reads.bam",
    output:
        bam="results/candidate_reads/{sample}.circle_candidate_reads.coordinate_sort.bam",
        idx="results/candidate_reads/{sample}.circle_candidate_reads.coordinate_sort.bai",
    log:
        "logs/candidate_reads/{sample}.circle_candidate_reads.coordinate_sort.log",
    threads: 4
    wrapper:
        "v1.21.2/bio/samtools/sort"


ruleorder: samtools_sort_candidates > bam_index


rule circle_map_realign:
    input:
        full_coordinate_bam="results/recal/{sample}.coordinate_sort.bam",
        full_coordinate_bai="results/recal/{sample}.coordinate_sort.bai",
        full_queryname_bam="results/recal/{sample}.queryname_sort.bam",
        candidates_bam="results/candidate_reads/{sample}.circle_candidate_reads.coordinate_sort.bam",
        candidates_bai="results/candidate_reads/{sample}.circle_candidate_reads.coordinate_sort.bai",
        fasta=genome,
    output:
        "results/circle-map/{sample}.circles.bed",
    log:
        "logs/circle-map/{sample}.circles.log",
    conda:
        "../envs/circle_map.yaml"
    threads: 16
    resources:
        mem_mb=lambda wc, threads: threads * 5000,
    shell:
        "Circle-Map Realign "
        " -i {input.candidates_bam} "
        " -qbam {input.full_queryname_bam} "
        " -sbam {input.full_coordinate_bam} "
        " -fasta {input.fasta} "
        " -t {threads}"
        " -o {output}; "
        "2> {log} "


rule clean_circle_map_realign_output:
    input:
        "results/circle-map/{sample}.circles.bed",
    output:
        "results/circle-map/{sample}.circles.cleaned.tsv",
    log:
        "logs/circle-map/{sample}.circles.cleaned.log",
    conda:
        "../envs/pandas.yaml"
    params:
        min_circle_score=config["circle_filtering"]["min_circle_score"],
        min_split_reads=config["circle_filtering"]["min_split_reads"],
        min_discordant_read_pairs=config["circle_filtering"][
            "min_discordant_read_pairs"
        ],
        max_uncovered_fraction=config["circle_filtering"]["max_uncovered_fraction"],
        min_mean_coverage=config["circle_filtering"]["min_mean_coverage"],
        min_circle_length=config["circle_filtering"]["min_circle_length"],
        max_circle_length=config["circle_filtering"]["max_circle_length"],
    script:
        "../scripts/clean_circle_map_realign_output.py"


rule annotate_cleaned_circles:
    input:
        all_annotations="resources/ensembl_all_annotations.harmonized.gff3.gz",
        tsv="results/circle-map/{sample}.circles.cleaned.tsv",
    output:
        tsvs=directory("results/circle-map/{sample}.circles.cleaned.annotated/"),
    log:
        "logs/circle-map/{sample}.circles.cleaned.annotated.logs",
    conda:
        "../envs/annotatr.yaml"
    params:
        build=config["ref"]["build"],
    script:
        "../scripts/annotate_cleaned_circles.R"
