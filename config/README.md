Describe how to configure the workflow (using config.yaml and maybe additional files).
All of them need to be present with example entries inside of the config folder.

# General settings
To configure this workflow, modify `config/config.yaml` according to your needs, following the explanations provided in the file.

# Sample sheet

Add samples to the `TSV` file specified via the `samples:` directive in `config/config.yaml`.
For each sample, the columns `sample_name`, `alias`, `platform`, and `group` have to be defined. 
* Samples within the same `group` will be handled jointly. This can for example be multiple samples from the same individual. 
* `alias`es represent the name of the sample within its group (they can be the same as the sample name, or something simpler / more abstract, like `tumor` or `normal`).
* The `platform` column needs to contain the used sequencing plaform (with this workflow focused on `Circle-Map`, this will always be 'ILLUMINA', for now -- but we keep this info for compatibility with other workflows).

Missing values can be specified by empty columns or by writing `NA`. Lines can be commented out with `#`.

# Unit sheet

For each sample, add one or more sequencing units (runs, lanes or replicates) to the `TSV` file specified via the `units:` directive in `config/config.yaml`.
For each unit, the columns `unit_name`, `sample_name`, `fq1`, and `fq2` have to be defined. 
* Each unit has a `unit_name`, which can be for example be a running number, or an actual run, lane or replicate id.
* Each unit has a `sample_name`, which associates it with the biological sample it comes from.
* For each unit, define the two paired FASTQ files (columns `fq1`, `fq2`, these can point to anywhere on your system). 
* Optional: Define adapters in the `adapters` column, by putting [cutadapt arguments](https://cutadapt.readthedocs.org) in quotation marks (e.g. `"-a ACGCGATCG -A GCTAGCGTACT"`). If adapters have already been removed in your raw data, or if you don't want to remove them, just leave this column empty for the respective units.

Missing values can be specified by empty columns or by writing `NA`. Lines can be commented out with `#`.
