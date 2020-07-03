rule busco:
  input:
    SCAFFOLDS = "results/1_spades_assembly/{sample}/contigs_200.fasta"

  output:
    LINK = "results/2_busco/{sample}/busco/link.txt"

  log:
    "results/2_busco/{sample}/busco/busco.log"

  params:
    conda_profile = "/mnt/apps/centos7/Conda/miniconda3/etc/profile.d/conda.sh",
    version = "results/5_report/conda_software_versions.txt"

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
    "  --out_path results/2_busco/{wildcards.sample}/busco/ "
    "  -c {threads} "
    "  --auto-lineage-prok "
    "  --offline 2> {log} ;"
    " srun /bin/touch {output.LINK} ;"

#-------------------------------------------------------------------------------

rule move_busco_files:
  input:
    LINK =  "results/2_busco/{sample}/busco/link.txt"

  output:
    LINK = "results/5_report/busco_summary/{sample}_buscolink.log"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  run:
    dest_dir = "results/5_report/busco_summary/"
    for file in glob.glob(f'results/2_busco/{wildcards.sample}/busco/{wildcards.sample}_busco/*.txt'):
        print(file)
        shutil.copy(file, dest_dir)
    f = open(f'{output.LINK}', 'w')
    f.write(" Created file")
    f.close()

#-------------------------------------------------------------------------------

rule make_busco_plots:
  input:
    LINKS = expand("results/5_report/busco_summary/{sample}_buscolink.log", sample = samples)

  output:
    FIGURE = "results/5_report/busco_summary/busco_figure.png"

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
    "  -wd results/5_report/busco_summary ;"
