rule generate_report_individual:
  input:
    RMD = "workflow/scripts/report_assembly_individual.Rmd",
    fastqc = expand("results/5_report/{sample}/{sample}_fastqc.txt", sample = samples),
    #fastqc_2 = "results/5_report/fastqc_summary_all.txt"

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

  params:
    R_path = "/mnt/apps/centos7/R-3.6.1/bin",
    title = config['Project_Title'],
    fastq = '../../results/0',
    fastqc = '../../results/5_report/{sample}/{sample}_fastqc.txt',
    fastp_json = '../../results/0_trim/{sample}/{sample}.json"',


  shell:
    " mkdir -p result/{wildcards.sample} ;"
    " xvfb-run -a {params.R_path}/Rscript -e \"rmarkdown::render('{input.RMD}', "
    " output_file='../../results/5_report/{wildcards.sample}_report.html' , "
    "  params = list(sample = '{wildcards.sample}' , "
    "                title = '{params.title}', "
    "                fastqc_table = '{params.fastqc}', "
    "                fastp_json = '{params.fastp_json}'"
    ") ) \""
