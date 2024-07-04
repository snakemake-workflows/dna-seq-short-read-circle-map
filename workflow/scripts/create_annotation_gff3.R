log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

library("tidyverse")
rlang::global_entrace()

library("GenomicRanges")
library("rtracklayer")

transcripts_to_genes_mappings <- read_tsv(
  snakemake@input[["mappping"]]
)

genome_build <- snakemake@params[["build"]]

genomic_annotations <- rtracklayer::import(
  snakemake@input[["genomic_annotations"]],
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
  dplyr::rename(name = Name)

regulatory_annotations <- rtracklayer::import(
  snakemake@input[["regulatory_annotations"]],
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
    rank = NA
  )


transcript_id_to_gene_id_mapping <- transcripts_to_genes_mappings |>
  dplyr::select(
    c(
      ensembl_transcript_id,
      ensembl_gene_id
    )
  ) |>
  distinct()

gene_id_annotations <- transcripts_to_genes_mappings |>
  dplyr::select(
    -ensembl_transcript_id
  ) |>
  distinct() |>
  dplyr::rename(
    hgnc_symbol = external_gene_name,
    genecards_id = genecards
  )

all_annotations <- bind_rows(
    genomic_annotations,
    regulatory_annotations
  ) |>
  mutate(
    ensembl_transcript_id = case_when(
      str_detect(parent_id, "^ENST") ~ parent_id,
      str_detect(id, "^ENST") ~ id
    ),
    gene_id = case_when(
      str_detect(parent_id, "^ENSG") ~ parent_id,
      str_detect(id, "^ENSG") ~ id,
    )
  ) |>
  dplyr::select(
    -c(
      parent_type,
      parent_id,
      phase
    )
  ) |>
  left_join(
    transcript_id_to_gene_id_mapping,
    by = join_by(
      ensembl_transcript_id
    )
  ) |>
  mutate(
    ensembl_gene_id =  if_else(
      is.na(ensembl_gene_id),
      gene_id,
      ensembl_gene_id
    )
  ) |>
  dplyr::select(
    -gene_id
  ) |>
  # bring in the gene symbols
  left_join(
    gene_id_annotations,
    by = join_by(
      ensembl_gene_id
    )
  ) |>
  # make sure, everything has an `id`
  mutate(
    id = case_when(
      is.na(id) & str_detect(name, "^ENS") ~ name,
      is.na(id) & str_detect(type, "_UTR$") ~ ensembl_transcript_id,
      .default = id
    )
  ) |>
  dplyr::rename(
    ensemble_id = id
  ) |>
  GRanges()

seqlevels(all_annotations) <- sort(seqlevels(all_annotations))
all_annotations <- sort(all_annotations, ignore.strand = TRUE)

rtracklayer::export(all_annotations, snakemake@output[["all_annotations"]])