# Changelog

## [1.3.0](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/compare/v1.2.4...v1.3.0) (2024-04-23)


### Features

* remove circle_score < 50, improve color scale ([#20](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/issues/20)) ([5f45fa6](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/commit/5f45fa6589eefcca8291f90892e7c61dad0ddcf6))

### [1.2.4](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/compare/v1.2.3...v1.2.4) (2024-04-04)


### Bug Fixes

* extend upper domain limit for circle_score in circles.datavzrd.yaml ([#18](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/issues/18)) ([87d69a7](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/commit/87d69a7fe991b03162eff23caa604b9a7329beb6))

### [1.2.3](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/compare/v1.2.2...v1.2.3) (2024-03-05)


### Bug Fixes

* extend circle_score range/domain in datavzrd template to zero ([#16](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/issues/16)) ([3841997](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/commit/3841997af6365ae4894318a7d7e6a66989e28fb2))

### [1.2.2](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/compare/v1.2.1...v1.2.2) (2024-03-01)


### Bug Fixes

* increase mem_mb for circle_map_realign to `2.5 * input.size_mb` ([#14](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/issues/14)) ([1404fad](https://www.github.com/snakemake-workflows/dna-seq-short-read-circle-map/commit/1404fad9a751a3df6ee4e294885b7004d73850f0))

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
