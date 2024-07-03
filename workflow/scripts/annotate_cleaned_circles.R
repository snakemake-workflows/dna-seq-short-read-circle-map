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
  ecDNA_status = "ecDNA",
  length = pull(circles, length),
  circle_score = pull(circles, circle_score),
  discordant_reads = pull(circles, discordant_reads),
  split_reads = pull(circles, split_reads),
  mean_coverage = pull(circles, mean_coverage),
  standard_deviation_coverage = pull(circles, standard_deviation_coverage),
  cov_increase_at_start = pull(circles, cov_increase_at_start),
  cov_increase_at_end = pull(circles, cov_increase_at_end),
  uncovered_fraction = pull(circles, uncovered_fraction)
)

genome(circles_gr) <- genome_build

overlapping_annotations <- rtracklayer::import(
  snakemake@input[["all_annotations"]],
  which = circles_gr, #import only intervals overlapping circles
  genome = genome_build
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
      phase,
      strand
    )
  ) |>
  dplyr::rename(
    chromosome = seqnames,
    exon_rank = rank
  ) |>
  mutate(
    region = str_c(
      chromosome,
      ":",
      start,
      "-",
      end
    )
  ) |>
  dplyr::select(
    region,
    type,
    id,
    name,
    parent_type,
    parent_id,
    rank,
    chromosome,
    start,
    end
  )