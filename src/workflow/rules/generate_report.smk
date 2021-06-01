rule get_softare_for_summary_report:
  input:
    expand("results/{sample}/report/software.txt", sample =samples)

  output:
    "results/summary_report/software.txt"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " /bin/cat {input} | sort | uniq > {output} ;"

rule generate_report:
  input:
    RMD = "workflow/scripts/report_assembly.Rmd",
    fastqc = "results/summary_report/fastqc_summary_all.txt",
    coverage = "results/summary_report/contig_coverage.txt",
    busco = "results/summary_report/busco_summary/busco_figure.png",
    quast_table = "results/summary_report/quast_summary.csv",
    confindr = "results/summary_report/confindr_summary.csv",
    prokka = "results/summary_report/prokka_summary.csv",
    gtdb = "results/genomes/gtdb_link.txt",
    SOFTWARE = "results/summary_report/software.txt"

  output:
    "results/summary_report/summary_report.html"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  params:
    R_path = "/mnt/apps/centos7/R-3.6.1/bin",
    title = config['Project_Title'],
    author = config['author'],
    email = config['email'],
    institute = config['institute'],
    fastqc = '../../results/summary_report/fastqc_summary_all.txt',
    quast_table = "../../results/summary_report/quast_summary.csv",
    busco_plot = "../../results/summary_report/busco_summary/busco_figure.png",
    confindr_csv = "../../results/summary_report/confindr_summary.csv",
    prokka_csv = "../../results/summary_report/prokka_summary.csv",
    taxonomy = "../../results/taxonomy/classify/gtdbtk.bac120.summary.tsv",
    software = "../../results/summary_report/software.txt",
    config = "../../config/config.json"

  shell:
    " srun xvfb-run -a {params.R_path}/Rscript -e \"rmarkdown::render('{input.RMD}', "
    "  output_file='../../results/summary_report/summary_report.html' , "
    "  params = list("
    "                title = '{params.title}', "
    "                author = '{params.author}', "
    "                email = '{params.email}', "
    "                institute = '{params.institute}', "
    "                fastqc_table = '{params.fastqc}', "
    "                busco_plot = '{params.busco_plot}', "
    "                quast_table = '{params.quast_table}', "
    "                confindr_csv = '{params.confindr_csv}', "
    "                prokka_csv = '{params.prokka_csv}', "
    "                taxonomy = '{params.taxonomy}', "
    "                software = '{params.software}', "
    "                config = '{params.config}' "
    ") ) \""
