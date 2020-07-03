rule finish_pipeline:
  input:
    fastqc = "results/5_report/fastqc_summary_all.txt",
    quast = "results/5_report/quast_summary.csv",
    busco = "results/5_report/busco_summary/busco_figure.png",
    confindr = "results/5_report/confindr_summary.csv",
    gtdb = "results/4_prokka/genomes/gtdb_link.txt",
    coverage="results/5_report/contig_coverage.txt",
    prokka = "results/5_report/prokka_summary.csv"

  output:
    "results/5_report/pipeline_finished.txt"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " grep version config/config.json | "
    "  sed 's/\"//g' | sed 's/ //g' | sed 's/:/,/g'  "
    "  > results/5_report/software.txt ;"
    " sort results/5_report/conda_software_versions.txt | "
    "  uniq >> results/5_report/software.txt ;"
    " srun /bin/echo 'Pipeline finished' > {output} "
