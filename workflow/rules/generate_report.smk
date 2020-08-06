rule generate_report:
  input:
    fastqc = "results/{sample}/report/{sample}_fastqc.txt",
    # quast = "results/report/quast_summary.csv",
    # busco = "results/report/busco_summary/busco_figure.png",
    # confindr = "results/report/confindr_summary.csv",
    # gtdb = "results/4_prokka/genomes/gtdb_link.txt",
    # coverage="results/report/contig_coverage.txt",
    # prokka = "results/report/prokka_summary.csv"

  output:
    "results/{sample}/report_report.html"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  script:
    " scripts/report_assembly_individual.Rmd "
