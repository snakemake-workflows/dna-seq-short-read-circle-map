log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

library("tidyverse")
rlang::global_entrace()
library("cli")

library("rtracklayer")
library("biomaRt")

wanted_species <- snakemake@params[["species"]]
wanted_release <- snakemake@params[["release"]]
wanted_build <- snakemake@params[["build"]]

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
annotations <- getBM(
  attributes = c("chromosome_start", "feature_type_name"),
  filters = c('feature_type_name', 'chromosome_name'),
  values = c(c("5utr", "3utr", "upstream_flank", "ensembl_gene_id_version", "ensembl_transcript_id_version" ), c("22")),
  mart = gene_ensembl
)

# <species>_regulatory_feature dataset provides the following `feature_type_name`s:
# * Enhancer         
# * CTCF Binding Site
# * TF binding       
# * Open chromatin   
# * Promoter
regulatory_features <- get_mart(wanted_species, wanted_build, version, grch, "regulatory_feature")

#  # <species>_external_feature dataset provides the following feature_type: feature_type_class:
#  # 1. VISTA Enhancers: Enhancer
#  # 2. FANTOM predictions: Enhancer
#  # 3. FANTOM predictions: Transcription Star Site
#  # We should probably get the following fields for useful annotation:
#  # * chromosome_name
#  # * chromosome_start
#  # * chromosome_enc
#  # * feature_type
#  # * feature_type_class
#  # * db_display_name (check if dprimary_acc contains this info)
#  # * dbprimary_acc
#  external_features <- get mart(wanted_species, wanted_build, wanted_version, grch, "external_feature") {


