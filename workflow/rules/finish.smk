rule finish_pipeline:
  input:
    fastqc = expand("results/{sample}/report/report_fastqc.txt", \
                    sample = samples),
    report = expand("results/{sample}/report/{sample}_report.html", \
                    sample = samples)

    # fastqc_all = "results/summary_report/fastqc_summary_all.txt"
    # quast = "results/report/quast_summary.csv",
    # busco = "results/report/busco_summary/busco_figure.png",
    # confindr = "results/report/confindr_summary.csv",
    # gtdb = "results/genomes/gtdb_link.txt",
    # coverage="results/report/contig_coverage.txt",
    # prokka = "results/report/prokka_summary.csv",
#    HTML = expand("results/{sample}/report_report.html", sample = samples)

  output:
    "results/{sample}/report/pipeline_finished.txt"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " /bin/echo 'Pipeline finished' > {output} ;"

    #
    # " #sort results/report/conda_software_versions.txt | "
    # "  #uniq >> results/report/software.txt ;"
