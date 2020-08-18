rule spades:
  input:
    FORWARD = "results/{sample}/0_trim/{sample}" + "_1" + f"{fastx_extension}",
    REVERSE = "results/{sample}/0_trim/{sample}" + "_2" + f"{fastx_extension}",
    LINK = "results/{sample}/0_trim/result_fastqc/{sample}" + config['mates']['mate1'] + "_fastqc.zip",

  output:
    "results/{sample}/1_spades_assembly/contigs.fasta"

  log: "results/{sample}/logs/spades.log"

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
    " conda activate spades_3.14.0 ;" #// TODO: software version will not add to report/software.txt; workaround see below.
    " srun spades.py --version >> results/{wildcards.sample}/report/software.txt ;"
    " srun spades.py "
    "  --isolate "
	  "  --cov-cutoff 'auto' "
    "  -t {threads} "
    "  -k 21,33,55,77,99,127 "
    "  -m {resources.mem_gb} "
    "  -1 {input.FORWARD} "
    "  -2 {input.REVERSE} "
    "  -o results/{wildcards.sample}/1_spades_assembly ;"
    " grep 'SPAdes version' results/{wildcards.sample}/1_spades_assembly/spades.log " # Extract Version and append to software.txt
    "  >> results/{wildcards.sample}/report/software.txt ;"
    " cp results/{wildcards.sample}/1_spades_assembly/spades.log " # Copy log file to logs.
    "  results/{wildcards.sample}/logs/spades.log ;"

#-------------------------------------------------------------------------------
rule cleanup:
  input:
    "results/{sample}/1_spades_assembly/scaffolds.fasta"

  output:
    "results/{sample}/1_spades_assembly/scaffolds_200.fasta"

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
    CONTIGS = expand("results/{sample}/1_spades_assembly/scaffolds_200.fasta",
                     sample = samples)

  output:
    COVSTATS = "results/summary_report/contig_coverage.txt"

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
