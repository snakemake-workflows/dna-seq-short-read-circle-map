rule render_datavzrd_config:
    input:
        template=workflow.source_path("../resources/circles.datavzrd.yaml"),
        circles="results/circle-map/{sample}.circles.cleaned.tsv",
    output:
        "resources/datavzrd/circle-map/{sample}.circles.yaml",
    log:
        "logs/datavzrd/circle-map/{sample}.circles.rendering.log",
    template_engine:
        "yte"


rule datavzrd:
    input:
        config="resources/datavzrd/circle-map/{sample}.circles.yaml",
        circles_overview="results/circle-map/{sample}.circles.cleaned.tsv",
        circles_tables="results/circle-map/{sample}.circles.cleaned.annotated/"
    output:
        report(
            directory("results/datavzrd/circles/{sample}"),
            htmlindex="index.html",
            category="extrachromosomal circular DNA",
            labels={"tool": "Circle-Map", "sample": "{sample}"},
            caption="../report/circle_map.rst",
        ),
    log:
        "logs/datavzrd/circles/{sample}.log",
    wrapper:
        "v3.8.0/utils/datavzrd"
