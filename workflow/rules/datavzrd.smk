rule datavzrd:
    input:
        config=workflow.source_path("../resources/circles.datavzrd.yaml"),
        circles_overview="results/circle-map/{sample}.circles.cleaned.tsv",
        circles_tables="results/circle-map/{sample}.circles.cleaned.annotated/",
    output:
        report(
            directory("results/datavzrd/circles/{sample}"),
            htmlindex="index.html",
            category="extrachromosomal circular DNA",
            labels={"tool": "Circle-Map", "sample": "{sample}"},
            caption="../report/circle_map.rst",
        ),
        config="resources/datavzrd/circle-map/{sample}.circles.datavzrd.rendered.yaml",
    log:
        "logs/datavzrd/circles/{sample}.log",
    wrapper:
        "v7.0.0/utils/datavzrd"
