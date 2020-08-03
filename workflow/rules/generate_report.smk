rule generate_report:
  input:
    fastqc = "results/5_report/{sample}/{sample}_fastqc.txt",
    # quast = "results/5_report/quast_summary.csv",
    # busco = "results/5_report/busco_summary/busco_figure.png",
    # confindr = "results/5_report/confindr_summary.csv",
    # gtdb = "results/4_prokka/genomes/gtdb_link.txt",
    # coverage="results/5_report/contig_coverage.txt",
    # prokka = "results/5_report/prokka_summary.csv"

  output:
    "results/5_report/{sample}_report.html"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  script:
    " scripts/report_assembly_individual.Rmd "
