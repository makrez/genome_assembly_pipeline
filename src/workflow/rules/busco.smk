rule busco:
  input:
    SCAFFOLDS = "results/{sample}/1_spades_assembly/scaffolds_200.fasta"

  output:
    LINK = "results/{sample}/2_busco/busco/link.txt"

  params:
    conda_profile = "/mnt/apps/centos7/Conda/miniconda3/etc/profile.d/conda.sh",
    version = "results/{sample}/report/software.txt"

  threads:
    int(config['busco']['busco_threads'])

  resources:
    mem_mb = int(config['busco']['busco_mem_mb']),
    hours = int(config['busco']['busco_hours'])

  shell:
    " set +u ;"
    " source {params.conda_profile} ;"
    " conda activate busco4 ;"
    " busco --version >> {params.version} ;"
    " srun busco -m genome "
    "  -i {input.SCAFFOLDS} "
    "  -o {wildcards.sample}_busco "
    "  --out_path results/{wildcards.sample}/2_busco/busco/ "
    "  --download_path /data/databases/busco5/busco_database "
    "  -c {threads} "
    "  --auto-lineage-prok "
    "  --offline ;"
    " cp results/{wildcards.sample}/2_busco/busco/{wildcards.sample}_busco/logs/busco.log "
    "  results/{wildcards.sample}/logs/busco.log ;"
    " srun /bin/touch {output.LINK} ;"
    " srun /bin/rm -rf /tmp/sepp ;"

#-------------------------------------------------------------------------------

rule move_busco_files:
  input:
    LINK =  "results/{sample}/2_busco/busco/link.txt"

  output:
    LINK = "results/summary_report/busco_summary/{sample}_buscolink.log"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  run:
    dest_dir = "results/summary_report/busco_summary/"
    for file in glob.glob(f'results/{wildcards.sample}/2_busco/busco/{wildcards.sample}_busco/*.txt'):
        print(file)
        shutil.copy(file, dest_dir)
    f = open(f'{output.LINK}', 'w')
    f.write(" Created file")
    f.close()

#-------------------------------------------------------------------------------

rule make_busco_plots:
  input:
    LINKS = expand("results/summary_report/busco_summary/{sample}_buscolink.log",
                   sample = samples)

  output:
    FIGURE = "results/summary_report/busco_summary/busco_figure.png"

  log: "results/logs/busco_plot.log"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  params:
    conda_profile = "/mnt/apps/centos7/Conda/miniconda3/etc/profile.d/conda.sh"

  shell:
    " set +u ;"
    " source {params.conda_profile} ;"
    " conda activate busco4 ;"
    " srun python workflow/scripts/scripts_generate_plot.py "
    "  -wd results/summary_report/busco_summary 2> {log} ;"

#-------------------------------------------------------------------------------

rule make_busco_plots_per_sample:
  input:
    LINKS = "results/{sample}/2_busco/busco/link.txt",

  output:
    FIGURE = "results/{sample}/2_busco/busco/{sample}_busco/busco_figure.png"

  log: "results/{sample}/logs/busco_plot.log"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  params:
    conda_profile = "/mnt/apps/centos7/Conda/miniconda3/etc/profile.d/conda.sh"

  shell:
    " set +u ;"
    " source {params.conda_profile} ;"
    " conda activate busco4 ;"
    " srun python workflow/scripts/scripts_generate_plot_per_sample.py "
    "  -wd results/{wildcards.sample}/2_busco/busco/{wildcards.sample}_busco/ 2> {log} ;"
