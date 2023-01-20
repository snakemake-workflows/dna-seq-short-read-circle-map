rule render_datavzrd_config:
    input:
        template=workflow.source_path("../resources/circles.datavzrd.yaml"),
        circles="results/circle-map/{sample}.circles.cleaned.tsv",
    output:
        "resources/datavzrd/circle-map/{sample}.circles.yaml",
    template_engine:
        "yte"


rule datavzrd:
    input:
        config="resources/datavzrd/circle-map/{sample}.circles.yaml",
        circles="results/circle-map/{sample}.circles.cleaned.tsv",
    output:
        report(
            directory("results/datavzrd/circles/{sample}"),
            htmlindex="index.html",
            # see https://snakemake.readthedocs.io/en/stable/snakefiles/reporting.html
            # for additional options like caption, categories and labels
            category="extrachromosomal circular DNA",
            labels={"tool": "Circle-Map", "sample": "{sample}"},
            caption="../report/circle_map.rst",
        ),
    log:
        "logs/datavzrd/circles/{sample}.log",
    wrapper:
        "v1.21.2/utils/datavzrd"