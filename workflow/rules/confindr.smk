rule confindr:
  input:
    LINK = "results/{sample}/1_spades_assembly/contigs_200.fasta",

  output:
    CSV = "results/{sample}/3_confindr/confindr_report.csv"

  log:
    "results/{sample}/logs/confindr.log"

  params:
    conda_profile = "/mnt/apps/centos7/Conda/miniconda3/etc/profile.d/conda.sh",
    version = "results/{sample}/report/software.txt"

  threads:
    int(config['confindr']['confindr_threads'])

  resources:
    mem_mb = int(config['confindr']['confindr_mem_mb']),
    hours = int(config['confindr']['confindr_hours'])

  shell:
    " set +u ;"
    " source {params.conda_profile} ;"
    " conda activate confindr ;"
    " confindr.py --version >> {params.version} ;"
    " srun confindr.py "
    "  -i results/{wildcards.sample}/0_trim/ "
    "  -o results/{wildcards.sample}/3_confindr "
    "  -d /data/projects/p446_Dialact_Phoenix/7_sw_and_dbs/confindr_dbs "
    "  -t {threads} "
    "  --cross_details 2> {log};"

#-------------------------------------------------------------------------------

rule confindr_summary:
  input:
    TXT = expand("results/{sample}/3_confindr/confindr_report.csv", \
                 sample = samples)

  output:
    CSV = "results/summary_report/confindr_summary.csv"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " set +u ;"
    " srun /bin/cat {input.TXT} | /bin/awk 'NR<2{{print $0;next}}{{print $0 | "
    "  \"grep -v 'Sample' | sort -r | uniq -u \"}}' "
    "  > {output.CSV} ;"
