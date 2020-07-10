rule spades:
  input:
    FORWARD = "results/0_trim/{sample}/{sample}" + "_1" + f"{fastx_extension}",
    REVERSE = "results/0_trim/{sample}/{sample}" + "_2" + f"{fastx_extension}",
    LINK = "results/0_trim/{sample}/result_fastqc/{sample}" + config['mates']['mate1'] + "_fastqc.zip",

  output:
    "results/1_spades_assembly/{sample}/contigs.fasta"

  params:
    conda_profile = "/mnt/apps/centos7/Conda/miniconda3/etc/profile.d/conda.sh",

  threads:
    int(config['spades']['spades_threads'])

  resources:
    mem_mb = int(config['spades']['spades_mem_mb']),
    hours = int(config['spades']['spades_hours']),
    mem_gb = int(config['spades']['spades_mem_gb'])

  shell:
    " set +u ;"
    " source {params.conda_profile} ;"
    " conda activate spades ;"
    " srun spades.py "
    "  --isolate "
	  "  --cov-cutoff 'auto' "
    "  -t {threads} "
    "  -k 21,33,55,77,99,127 "
    "  -m {resources.mem_gb} "
    "  -1 {input.FORWARD} "
    "  -2 {input.REVERSE} "
    "  -o results/1_spades_assembly/{wildcards.sample} ;"

#-------------------------------------------------------------------------------
rule cleanup:
  input:
    "results/1_spades_assembly/{sample}/contigs.fasta"

  output:
    "results/1_spades_assembly/{sample}/contigs_200.fasta"

  params:
    scaffolds_filter = int(config['spades']['spades_min_scaffold_length'])

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " srun workflow/scripts/cleanup.sh -i={input} "
    "  -o={output} "
    "  -m={params.scaffolds_filter} "
    "  -s={wildcards.sample} ;"

#-------------------------------------------------------------------------------
rule parse_coverage:
  input:
    CONTIGS = expand("results/1_spades_assembly/{sample}/contigs_200.fasta", sample = samples)

  output:
    COVSTATS = "results/5_report/contig_coverage.txt"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " srun cat {input} | "
    "  grep '>' | "
    "  awk -F '[-_ ]' 'BEGIN {{print \"Sample,Scaffold,length,coverage\"}} "
    "   {{print $1\",\"$4\",\"$6\",\"$8}}' | "
    "  sed 's/>//g' > {output.COVSTATS} ;"
