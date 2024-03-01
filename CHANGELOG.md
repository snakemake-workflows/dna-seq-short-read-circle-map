# Changelog

### [1.2.1](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/compare/v1.2.0...v1.2.1) (2024-03-01)


### Bug Fixes

* try making Circle-Map Realign memory requests dynamic (1.2 * input.size_mb) ([#11](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/issues/11)) ([f01fd3b](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/commit/f01fd3b78ae033abcfce20a020c467682e5eda6d))

## [1.2.0](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/compare/v1.1.1...v1.2.0) (2024-02-29)


### Features

* add mem_mb resource annotation to bwa_mem ([#8](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/issues/8)) ([c9b6629](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/commit/c9b662984921a48857b58048a31435d62f44ae24))

### [1.1.1](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/compare/v1.1.0...v1.1.1) (2024-01-12)


### Bug Fixes

* adjust schema to allow lowercase platform spec ([#6](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/issues/6)) ([aecf851](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/commit/aecf851a0d11995a57079c6936dd50e6a5e02deb))

## [1.1.0](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/compare/v1.0.0...v1.1.0) (2024-01-11)


### Features

* allow for lowercase platform specification in samples.tsv ([#4](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/issues/4)) ([dae2140](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/commit/dae21408f949fe7b999f29226d1eb0a1e388ed8c))

## 1.0.0 (2023-03-16)

Initial release, with working GitHub Actions CI testing, a basic working report and with Zenodo archiving set up.

### Bug Fixes

* include circle_map_realign BAI dependencies ([7096b4d](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/commit/7096b4d3900fa46eef29f3dd273fe19c8841b1a3))
