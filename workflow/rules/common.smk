import yaml
import pandas as pd
from snakemake.utils import validate

## Loading of configuration and sample files

validate(config, schema="../schemas/config.schema.yaml")

samples = (
    pd.read_csv(
        config["samples"],
        sep="\t",
        dtype={"sample_name": str, "group": str},
        comment="#",
    )
    .set_index("sample_name", drop=False)
    .sort_index()
)

# construct genome name
datatype = "dna"
species = config["ref"]["species"]
build = config["ref"]["build"]
release = config["ref"]["release"]
genome_name = f"genome.{datatype}.{species}.{build}.{release}"
genome_prefix = f"resources/{genome_name}"
genome = f"{genome_prefix}.fasta"
genome_fai = f"{genome}.fai"
genome_dict = f"{genome_prefix}.dict"


def _group_or_sample(row):
    group = row.get("group", None)
    if pd.isnull(group):
        return row["sample_name"]
    return group


samples["group"] = [_group_or_sample(row) for _, row in samples.iterrows()]
validate(samples, schema="../schemas/samples.schema.yaml")


groups = samples["group"].unique()

if "groups" in config:
    group_annotation = (
        pd.read_csv(config["groups"], sep="\t", dtype={"group": str})
        .set_index("group")
        .sort_index()
    )
    group_annotation = group_annotation.loc[groups]
else:
    group_annotation = pd.DataFrame({"group": groups}).set_index("group")

units = pd.read_csv(
    config["units"],
    sep="\t",
    dtype={"sample_name": str, "unit_name": str},
    comment="#",
)

validate(units, schema="../schemas/units.schema.yaml")


## final workflow output


def get_final_output(wildcards):
    final_output = expand(
        "results/datavzrd/circles/{sample}",
        sample=samples["sample_name"],
    )

    return final_output


## rule helper functions


def get_adapters(wildcards):
    units.loc[units["sample_name"] == wildcards.sample].loc[
        units["unit_name"] == wildcards.unit
    ].get("adapters", ""),


def get_bioc_species_name():
    first_letter = config["resources"]["ref"]["species"][0]
    subspecies = config["resources"]["ref"]["species"].split("_")[1]
    return first_letter + subspecies


def get_bioc_species_pkg():
    """Get the package bioconductor package name for the the species in config.yaml"""
    species_letters = get_bioc_species_name()[0:2].capitalize()
    return "org.{species}.eg.db".format(species=species_letters)


def render_annotation_env():
    species_pkg = f"bioconductor-{get_bioc_species_pkg()}"
    with open(workflow.source_path("../envs/annotation_gff_from_biomart.yaml")) as f:
        env = yaml.load(f, Loader=yaml.SafeLoader)
    env["dependencies"].append(species_pkg)
    env_path = Path("resources/envs/annotation_gff_from_biomart.yaml")
    env_path.parent.mkdir(parents=True, exist_ok=True)
    with open(env_path, "w") as f:
        yaml.dump(env, f)
    return env_path.absolute()


bioc_species_name = get_bioc_species_name()
annotate_circles_env = render_annotate_circles_env()


def get_bwa_extra(wildcards):
    """
    Denote sample name and platform in read group.
    Set -q option for independent mapping qualities for split reads (Circle-Map uses this).
    """
    return r"-q -R '@RG\tID:{sample}\tSM:{sample}\tPL:{platform}'".format(
        sample=wildcards.sample,
        platform=samples.loc[wildcards.sample, "platform"].upper(),
    )


def get_paired_read_files(wildcards):
    return [
        units.loc[units["sample_name"] == wildcards.sample]
        .loc[units["unit_name"] == wildcards.unit, "fq1"]
        .squeeze(),
        units.loc[units["sample_name"] == wildcards.sample]
        .loc[units["unit_name"] == wildcards.unit, "fq2"]
        .squeeze(),
    ]


## rule input functions


def get_mapping_input(wildcards):
    adapters = get_adapters(wildcards)
    if adapters:
        return [
            "results/trimmed/{sample}/{unit}_R1.fastq.gz",
            "results/trimmed/{sample}/{unit}_R2.fastq.gz",
        ]
    else:
        return get_paired_read_files(wildcards)
