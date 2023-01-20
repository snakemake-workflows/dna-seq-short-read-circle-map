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
        "results/circle-map/{sample}.circles.tsv",
    log:
        "logs/circle-map/{sample}.circles.log",
    conda:
        "../envs/circle_map.yaml"
    threads: 4
    shell:
        "( Circle-Map Realign "
        "   -i {input.candidates_bam} "
        "   -qbam {input.full_queryname_bam} "
        "   -sbam {input.full_coordinate_bam} "
        "   -fasta {input.fasta} "
        "   -t {threads}"
        "   -o {output}; "
        # add a header line, using FreeBSD / MacOSX safe sed:
        # * -i'' with empty backup extension: https://www.grymoire.com/Unix/Sed.html#uh-62h
        " sed -i'' "
        # * substitution at first line: https://superuser.com/a/1239832
        # * triple \\\t escapes to be compatible across shells:
        #   https://stackoverflow.com/questions/1421478/how-do-i-use-a-new-line-replacement-in-a-bsd-sed#comment38075898_19883696
        "   -e $'1s;^;chromosome\\\tstart\\\tend\\\tdiscordant_reads\\\tsplit_reads\\\tcircle_score\\\tmean_coverage\\\tstandard_deviation_coverage\\\tcov_increase_at_start\\\tcov_increase_at_end\\\tuncovered_fraction\\\n;' "
        "   {output} "
        ") 2> {log} "

