rule quast:
  input:
    "results/1_spades_assembly/{sample}/contigs_200.fasta"

  output:
    "results/1_spades_assembly/{sample}/quast/report.txt"

  log:
    "results/logs/{sample}/quast.log"

  params:
    quast = config['quast']['quast_version']

  threads:
    int(config['quast']['quast_threads'])

  resources:
    mem_mb = int(config['quast']['quast_mem_mb']),
    hours = int(config['quast']['quast_hours']),

  shell:
    " module add UHTS/Quality_control/quast/4.6.0 ;"
    " srun quast.py {input} "
    "  -o  results/1_spades_assembly/{wildcards.sample}/quast/ "
    "  -m 200 &> {log} ;"

#-------------------------------------------------------------------------------

rule extract_quast_qual:
  input:
    QUAST_report = "results/1_spades_assembly/{sample}/quast/report.txt"

  output:
    CSV = "results/5_report/{sample}/{sample}_quast.csv"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " srun /bin/cat {input.QUAST_report} | "
    "  grep -A 6 Largest | "
    "  /bin/sed 's/ /_/' | "
    "  /bin/awk -v var={wildcards.sample} -F ' ' '{{print $1','$2','var }}' | "
    "  /bin/sed 's/ /,/g' | /bin/sed 's/_,/,/g'> {output.CSV} ;"

#-------------------------------------------------------------------------------

rule concatenate_qust:
  input:
    CSV = expand("results/5_report/{sample}/{sample}_quast.csv", sample = samples)

  output:
    "results/5_report/quast_summary.csv"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " srun /bin/cat {input.CSV} > {output} "

#-------------------------------------------------------------------------------
