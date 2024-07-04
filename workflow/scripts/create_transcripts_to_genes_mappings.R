log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

library("tidyverse")
rlang::global_entrace()
library("cli")

library("biomaRt")

wanted_species <- snakemake@params[["species"]]
wanted_release <- snakemake@params[["release"]]
wanted_build <- snakemake@params[["build"]]
wanted_chromosome <- snakemake@params[["chromosome"]]

if (wanted_build == "GRCh37") {
  grch <- "37"
  version <- NULL
  cli_warn(c(
    "As you specified build 'GRCH37' in your configuration yaml, biomart forces",
    "us to ignore the release you specified ('{release}')."
  ))
} else {
  grch <- NULL
  version <- wanted_release
}

get_mart <- function(species, build, version, grch, dataset) {
  mart <- useEnsembl(
    biomart = "genes",
    dataset = str_c(species, "_", dataset),
    version = version,
    GRCh = grch
  )
  
  if (build == "GRCh37") {
    retrieved_build <- str_remove(listDatasets(mart)$version, "\\..*")
  } else {
    retrieved_build <- str_remove(searchDatasets(mart, species)$version, "\\..*")
  }
  
  if (retrieved_build != build) {
    cli_abort(c(
            "Ensembl release and genome build number in your configuration are not compatible.",
      "x" = "Genome build '{build}' not available via biomart for Ensembl release '{release}''.",
      "i" = "Ensembl release '{release}' only provides build '{retrieved_build}'.",
      " " = "Please fix your configuration yaml file's reference entry, you have two options:",
      "*" = "Change the build entry to '{retrieved_build}'.",
      "*" = "Change the release entry to one that provides build '{build}'. You have to determine this from biomart by yourself."
    ))
  }
  mart
}


# <species>_gene_ensembl dataset provides the following entries of interesting
# in the respective `page`s:
# 1. sequences:
#   * 5' UTR: 5utr
#   * 3' UTR: 3utr
#   * upstream_flank
# 2. feature_page:
#   * ensembl_gene_id_version
#   * ensembl_transcript_id_version
# 3. structure:
#   * currently none interesting, but possibly relevant
gene_ensembl <- get_mart(wanted_species, wanted_build, version, grch, "gene_ensembl")

wanted_attributes <- c(
  "ensembl_transcript_id",
  "ensembl_gene_id",
  "external_gene_name",
  "genecards"
)

if (wanted_chromosome != "") {
  mapping <- getBM(
    attributes = wanted_attributes,
    filters = 'chromosome_name',
    values = wanted_chromosome,
    mart = gene_ensembl
  ) |> as_tibble()
} else {
  mapping <- getBM(
    attributes = wanted_attributes,
    mart = gene_ensembl
  ) |> as_tibble()
}

write_tsv(
  mapping,
  file = snakemake@output[["mapping"]]
)
