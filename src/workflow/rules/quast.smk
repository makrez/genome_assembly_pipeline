rule quast:
  input:
    "results/{sample}/1_spades_assembly/scaffolds_200.fasta"

  output:
    "results/{sample}/1_spades_assembly/quast/report.txt"

  log:
    "results/{sample}/logs/quast.log"

  params:
    quast = config['quast']['quast_version']

  threads:
    int(config['quast']['quast_threads'])

  resources:
    mem_mb = int(config['quast']['quast_mem_mb']),
    hours = int(config['quast']['quast_hours']),

  shell:
    " module add UHTS/Quality_control/quast/{params.quast} ;"
    " srun quast.py {input} "
    "  -o  results/{wildcards.sample}/1_spades_assembly/quast/ "
    "  -m 200 &> {log} ;"

#-------------------------------------------------------------------------------

rule extract_quast_qual:
  input:
    QUAST_report = "results/{sample}/1_spades_assembly/quast/report.txt"

  output:
    TMP1 = temp("results/{sample}/report/tmp1"),
    TMP2 = temp("results/{sample}/report/tmp2"),

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " /bin/cat {input.QUAST_report} | "
    "  tail -n 22 | "
    "  awk '{{print substr($0,0,28)}}' | sed 's/[ ]*$//' > {output.TMP1} ;"
    " /bin/cat {input.QUAST_report} | "
    "  tail -n 22 | "
    "  awk '{{print substr($0,29,30)}}' | sed 's/[ ]*$//' > {output.TMP2} ;"

rule create_CSV:
  input:
    TMP1 = "results/{sample}/report/tmp1",
    TMP2 = "results/{sample}/report/tmp2",

  output:
    CSV = "results/{sample}/report/{sample}_quast.csv",

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
   " /bin/paste -d ',' {input.TMP1} {input.TMP2} > {output.CSV} ;"


rule convert_pdf_png:
    input:
      TMP1 = "results/{sample}/report/tmp1",
      TMP2 = "results/{sample}/report/tmp2",

    output:
      "results/{sample}/1_spades_assembly/quast/basic_stats/Nx_plot.png"

    threads:
      int(config['short_sh_commands_threads'])

    resources:
      mem_mb = int(config['short_commands_mb']),
      hours = int(config['short_sh_commands_hours'])

    params:
      conda_profile = "/mnt/apps/centos7/Conda/miniconda3/etc/profile.d/conda.sh",
      version = "results/report/conda_software_versions.txt",

    shell:
      " set +u ;"
      " source {params.conda_profile} ;"
      " conda activate imagemagick ;"
      " mogrify -density 300 -format png "
      "  results/{wildcards.sample}/1_spades_assembly/quast/basic_stats/*.* ;"

#-------------------------------------------------------------------------------
rule transform_quast:
  input:
    CSV = "results/{sample}/report/{sample}_quast.csv"

  output:
    "results/{sample}/report/{sample}_quast_tranformed.csv"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " /bin/awk -v var={wildcards.sample} 'NR>2 {{print $0\",\"var}}' {input.CSV} "
    "  | tail -n+2 > {output} ;"

rule concatenate_qust:
  input:
    CSV = expand("results/{sample}/report/{sample}_quast_tranformed.csv",
                 sample = samples)

  output:
    "results/summary_report/quast_summary.csv"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " srun /bin/cat {input.CSV} > {output} "

#-------------------------------------------------------------------------------
