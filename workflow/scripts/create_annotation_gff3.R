log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

library("tidyverse")
rlang::global_entrace()

library("GenomicRanges")
library("rtracklayer")

genome_build <- snakemake@params[["build"]]

genomic_annotations <- rtracklayer::import(
  snakemake@input[["genomic_annotations"]],
  which = circles_gr, #import only intervals overlapping circles
  genome = genome_build,
  feature.type = c(
    "five_prime_UTR",
    "three_prime_UTR",
    "exon",
    "gene",
    "lnc_RNA",
    "miRNA",
    "snRNA",
    "snoRNA",
    "scRNA",
    "rRNA",
    "tRNA",
    "V_gene_segment",
    "D_gene_segment",
    "J_gene_segment",
    "C_gene_segment"
  ),
  colnames = c(
    "type",
    "Name",
    "ID",
    "Parent",
    "rank",
    "phase"
  )
) |>
  as_tibble() |>
  separate_wider_delim(
    ID,
    delim = ":",
    names = c("id_type", "id")
  ) |>
  dplyr::select(-id_type) |>
  unnest(
    Parent,
    keep_empty = TRUE
  ) |>
  separate_wider_delim(
    Parent,
    delim = ":",
    names = c("parent_type", "parent_id")
  ) |>
  mutate(
    id = case_when(
      !is.na(id) ~ id,
      type == "exon" ~ Name,
      type %in% c("five_prime_UTR", "three_prime_UTR") ~ parent_id
    )
  ) |>
  dplyr::rename(name = Name) |>
  GRanges()

regulatory_annotations <- rtracklayer::import(
  snakemake@input[["regulatory_annotations"]],
  which = circles_gr, #import only intervals overlapping circles
  genome = genome_build,
  # make sure to expand parent_type generation below, if you add
  # further types right here
  feature.type = c(
    "promoter",
    "enhancer",
    "TF_binding_site",
    "CTCF_binding_site"
  ),
  colnames = c(
    "type",
    "ID",
    "gene_id",
    "gene_name",
    "phase"
  )
) |>
  as_tibble() |>
  unnest_wider(
    c(gene_id, gene_name),
    names_sep = "-"
  ) |> 
  pivot_longer(
    starts_with("gene_"),
    names_to = c("id_type", "gene_nr"),
    values_to = "val",
    names_sep = "-"
  ) |>
  pivot_wider(
    names_from = id_type,
    values_from = val
  ) |>
  mutate(
    gene_name = na_if(gene_name, "")
  ) |>
  filter(
    !( gene_nr > 1 & is.na(gene_id) & is.na(gene_name) )
  ) |>
  dplyr::select(
    !gene_nr
  ) |>
  dplyr::rename(
    name = gene_name,
    id = ID,
    parent_id = gene_id,
  ) |>
  mutate(
    parent_type = if_else(
      (!is.na(parent_id) & str_detect(parent_id, "^ENSG")),
      "gene",
      NA
    ),
    rank = NA
  ) |>
  GRanges()

all_annotations <- c(genomic_annotations, regulatory_annotations)
seqlevels(all_annotations) <- sort(seqlevels(all_annotations))
all_annotations <- sort(all_annotations, ignore.strand = TRUE)

rtracklayer::export(all_annotations, snakemake@output[["all_annotations"]])