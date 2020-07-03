rule prokka:
  input:
    CONTIGS = "results/1_spades_assembly/{sample}/contigs_200.fasta"

  output:
    TXT = "results/4_prokka/{sample}/{sample}.txt",
    GENOME = "results/4_prokka/{sample}/{sample}.fna"

  log:
    "results/4_prokka/{sample}/prokka/prokka.log"

  params:
    conda_profile = "/mnt/apps/centos7/Conda/miniconda3/etc/profile.d/conda.sh",
    version = "results/5_report/conda_software_versions.txt"

  threads:
    int(config['prokka']['prokka_threads'])

  resources:
    mem_mb = int(config['prokka']['prokka_mem_mb']),
    hours = int(config['prokka']['prokka_hours'])

  shell:
    " set +u ;"
    " source {params.conda_profile} ;"
    " conda activate prokka_1.14.6 ;"
    " prokka --version >> {params.version} ;"
    " srun prokka "
    "  --force "
    "  --cpus {threads} "
    "  --outdir results/4_prokka/{wildcards.sample}/ "
    "  --prefix {wildcards.sample} {input.CONTIGS} ;"

#-------------------------------------------------------------------------------

rule convert_prokka_summary:
  input:
    TSV = "results/4_prokka/{sample}/{sample}.txt"

  output:
    CSV = "results/4_prokka/{sample}/{sample}.csv"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    # remove trailing white spaces
    " srun /bin/sed 's/ *$//g' < {input.TSV} | "
    "  /bin/sed 's/ /_/g' | /bin/sed 's/:_/ /g' | "
    "  /bin/awk -v var={wildcards.sample} '{{print $1\",\"$2\",\"var}}' "
    "  > {output.CSV}"

#-------------------------------------------------------------------------------

rule concatenate_prokka:
  input:
    CSV = expand("results/4_prokka/{sample}/{sample}.csv", sample = samples)

  output:
    "results/5_report/prokka_summary.csv"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " srun /bin/cat {input.CSV} > {output} "

#-------------------------------------------------------------------------------

rule move_genomes:
  input:
    TXT =  "results/4_prokka/{sample}/{sample}.txt",
    GENOME = "results/4_prokka/{sample}/{sample}.fna"

  output:
    LINK = "results/4_prokka/genomes/{sample}.fna"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  run:
    dest_dir = "results/4_prokka/genomes/"
    shutil.copy(f'{input.GENOME}', dest_dir)

#-------------------------------------------------------------------------------

rule gtdb:
  input:
    GENOME = expand("results/4_prokka/genomes/{sample}.fna", sample=samples)

  output:
    LINK = "results/4_prokka/genomes/gtdb_link.txt",
    DIR = directory("results/4_prokka/taxonomy")

  params:
    conda_profile = "/mnt/apps/centos7/Conda/miniconda3/etc/profile.d/conda.sh",
    version = "results/5_report/conda_software_versions.txt"

  threads:
    int(config['gtdb']['gtdb_threads'])

  resources:
    mem_mb = int(config['gtdb']['gtdb_mem_mb']),
    hours = int(config['gtdb']['gtdb_hours'])

  shell:
    " set +u ;"
    " source {params.conda_profile} ;"
    " conda activate gtdbtk ;"
    " gtdbtk --version >> {params.version} ;"
    " srun mkdir -p results/4_prokka/taxonomy ;"
    " srun gtdbtk classify_wf "
    "  --genome_dir results/4_prokka/genomes/ "
    "  --out_dir results/4_prokka/taxonomy "
    "  --cpus {threads} ;"
    " srun /bin/touch {output.LINK} ;"

#-------------------------------------------------------------------------------
