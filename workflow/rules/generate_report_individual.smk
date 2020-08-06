rule software_versions:
  input:
    fastqc = "results/{sample}/report/report_fastqc.txt",

  output:
    "results/{sample}/report/software.txt"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " grep version config/config.json | "
    "  sed 's/\"//g' | sed 's/ //g' | sed 's/:/,/g'  "
    "  > {output} ;"

rule generate_report_individual:
  input:
    RMD = "workflow/scripts/report_assembly_individual.Rmd",
    SOFTWARE = "results/{sample}/report/software.txt",
    fastqc = "results/{sample}/report/report_fastqc.txt",
    quast = "results/{sample}/report/{sample}_quast.csv",
    busco = "results/{sample}/2_busco/busco/{sample}_busco/busco_figure.png",
    quast_table = "results/{sample}/report/{sample}_quast.csv",
    confindr_csv = "results/{sample}/3_confindr/confindr_report.csv",
    prokka_csv = "results/{sample}/4_prokka/{sample}.csv",
    gtdbk = "results/genomes/gtdb_link.txt",
    quast_nxplot =      "results/{sample}/1_spades_assembly/quast/basic_stats/Nx_plot.png"
    #fastqc = expand("results/{sample}/report/{sample}_fastqc.txt", sample = samples),
    #fastqc_2 = "results/report/fastqc_summary_all.txt"

    # quast = "result s/report/quast_summary.csv",
    # busco = "results/report/busco_summary/busco_figure.png",
    # confindr = "results/report/confindr_summary.csv",
    # gtdb = "results/4_prokka/genomes/gtdb_link.txt",
    # coverage="results/report/contig_coverage.txt",
    # prokka = "results/report/prokka_summary.csv"

  output:
    "results/{sample}/report/{sample}_report.html"

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
    fastqc = '../../results/{sample}/report/report_fastqc.txt',
    fastp_json = '../../results/{sample}/0_trim/{sample}.json',
    quast_cov_hist = "../../results/{sample}/1_spades_assembly/quast/basic_stats/contigs_200_coverage_histogram.png",
    quest_coverage_line = "../../results/{sample}/1_spades_assembly/quast/basic_stats/coverage_histogram.png",
    quast_cumulative_plot = "../../results/{sample}/1_spades_assembly/quast/basic_stats/cumulative_plot.png",
    quast_gc_content_plot = "../../results/{sample}/1_spades_assembly/quast/basic_stats/GC_content_plot.png",
    busco_plot = "../../results/{sample}/2_busco/busco/{sample}_busco/busco_figure.png",
    quast_table = "../../results/{sample}/report/{sample}_quast.csv",
    confindr_csv = "../../results/{sample}/3_confindr/confindr_report.csv",
    prokka_csv = "../../results/{sample}/4_prokka/{sample}.csv",
    taxonomy = "../../results/taxonomy/classify/gtdbtk.bac120.summary.tsv",
    software = "../../results/{sample}/report/software.txt"

  shell:
    " srun xvfb-run -a {params.R_path}/Rscript -e \"rmarkdown::render('{input.RMD}', "
    "  output_file='../../results/{wildcards.sample}/report/{wildcards.sample}_report.html' , "
    "  params = list(sample = '{wildcards.sample}' , "
    "                title = '{params.title}', "
    "                author = '{params.author}', "
    "                email = '{params.email}', "
    "                institute = '{params.institute}', "
    "                fastqc_table = '{params.fastqc}', "
    "                fastp_json = '{params.fastp_json}', "
    "                quast_cov_hist = '{params.quast_cov_hist}', "
    "                quest_coverage_line = '{params.quest_coverage_line}', "
    "                quast_cumulative_plot = '{params.quast_cumulative_plot}', "
    "                quast_gc_content_plot = '{params.quast_gc_content_plot}', "
    "                busco_plot = '{params.busco_plot}', "
    "                quast_table = '{params.quast_table}', "
    "                confindr_csv = '{params.confindr_csv}', "
    "                prokka_csv = '{params.prokka_csv}', "
    "                taxonomy = '{params.taxonomy}', "
    "                software = '{params.software}' "
    ") ) \""
