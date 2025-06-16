log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

library("tidyverse")
rlang::global_entrace()

library("annotatr")
library("GenomicRanges")

circles <- read_tsv(
  snakemake@input[["tsv"]]
)

genome_build <- snakemake@params[["build"]]

circles_gr <- GRanges(
  seqnames = pull(circles, region),
  ecDNA_status = "ecDNA"
)

genome(circles_gr) <- genome_build

overlapping_annotations <- rtracklayer::import(
  snakemake@input[["all_annotations"]],
  which = circles_gr, #import only intervals overlapping circles
  genome = genome_build
)

dir.create(
  snakemake@output[["tsvs"]],
  recursive = TRUE
)

annotated_circles <- annotate_regions(
  regions = circles_gr,
  annotations = overlapping_annotations,
  ignore.strand = TRUE,
  quiet = FALSE
) |>
  as_tibble() |>
  dplyr::select(
    -c(
      strand,
      width,
      ecDNA_status,
      annot.width,
      annot.source,
      annot.score,
      annot.phase
    )
  ) |>
  arrange(
    annot.seqnames,
    annot.start,
    annot.end
  ) |>
  mutate(
    circle_region = str_c(
      seqnames,
      ":",
      start,
      "-",
      end
    ),
    region = str_c(
      annot.seqnames,
      ":",
      annot.start,
      "-",
      annot.end
    )
  ) |>
  dplyr::select(
    -c(
      seqnames,
      start,
      end,
      annot.seqnames,
      annot.start,
      annot.end
    )
  ) |>
  dplyr::rename(
    exon_rank = annot.rank
  ) |>
  dplyr::rename_with(
    ~ str_replace(.x, fixed("annot."), "")
  ) |>
  dplyr::select(
    region,
    strand,
    type,
    ensembl_id,
    name,
    ensembl_transcript_id,
    ensembl_gene_id,
    hgnc_symbol,
    genecards_id,
    exon_rank,
    circle_region,
  ) |>
  group_by(
    circle_region
  ) |>
  group_walk(
    ~ write_tsv(
      .x,
      file = file.path(
        snakemake@output[["tsvs"]],
        str_c(
          str_replace_all(.y$circle_region, "[:-]", "_"),
          ".tsv"
        )
      )
    )
  )