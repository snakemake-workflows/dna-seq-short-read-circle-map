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
        "logs/circle-map/{sample}.circles.bed",
    conda:
        "../envs/circle_map.yaml"
    threads: 4
    shell:
        "Circle-Map Realign "
        " -i {input.candidates_bam} "
        " -qbam {input.full_queryname_bam} "
        " -sbam {input.full_coordinate_bam} "
        " -fasta {input.fasta} "
        " -t {threads}"
        " -o {output} "
        " 2> {log} "
