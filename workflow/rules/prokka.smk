rule prokka:
  input:
    CONTIGS = "results/{sample}/1_spades_assembly/contigs_200.fasta"

  output:
    TXT = "results/{sample}/4_prokka/{sample}.txt",
    GENOME = "results/{sample}/4_prokka/{sample}.fna"

  log:
    "results/{sample}/logs/prokka.log"

  params:
    conda_profile = "/mnt/apps/centos7/Conda/miniconda3/etc/profile.d/conda.sh",
    version = "results/{sample}/report/software.txt"

  threads:
    int(config['prokka']['prokka_threads'])

  resources:
    mem_mb = int(config['prokka']['prokka_mem_mb']),
    hours = int(config['prokka']['prokka_hours'])

  shell:
    " set +u ; "
    " source {params.conda_profile} ;"
    " conda activate gtdbtk ;"
    " gtdbtk --version >> {params.version} ;" # hack to get the gtdbtk version for each sample
    " conda deactivate ;"
    " conda activate prokka_1.14.6 ;"
    " prokka --version >> {params.version} ;"
    " srun prokka "
    "  --force "
    "  --cpus {threads} "
    "  --outdir results/{wildcards.sample}/4_prokka/ "
    "  --prefix {wildcards.sample} {input.CONTIGS} 2> {log} ;"

#-------------------------------------------------------------------------------

rule convert_prokka_summary:
  input:
    TSV = "results/{sample}/4_prokka/{sample}.txt"

  output:
    CSV = "results/{sample}/4_prokka/{sample}.csv",
    CSV_summary = "results/{sample}/4_prokka/{sample}_transformed.csv"

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
    "  > {output.CSV} ;"
    " srun /bin/sed 's/ *$//g' < {input.TSV} | "
    "  /bin/sed 's/ /_/g' | /bin/sed 's/:_/ /g' | "
    "  /bin/awk -v var={wildcards.sample} '{{print $1\",\"$2\",\"var}}' | "
    "  tail -n+2 > {output.CSV_summary} ;"

#-------------------------------------------------------------------------------

rule concatenate_prokka:
  input:
    CSV = expand("results/{sample}/4_prokka/{sample}_transformed.csv",
                 sample = samples)

  output:
    "results/summary_report/prokka_summary.csv"

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
    TXT =  "results/{sample}/4_prokka/{sample}.txt",
    GENOME = "results/{sample}/4_prokka/{sample}.fna"

  output:
    LINK = "results/genomes/{sample}.fna"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  run:
    dest_dir = "results/genomes/"
    shutil.copy(f'{input.GENOME}', dest_dir)

#-------------------------------------------------------------------------------

rule gtdb:
  input:
    GENOME = expand("results/genomes/{sample}.fna", sample=samples)

  output:
    LINK = "results/genomes/gtdb_link.txt",
    DIR = directory("results/taxonomy")

  log: "results/gtdbk.log"

  params:
    conda_profile = "/mnt/apps/centos7/Conda/miniconda3/etc/profile.d/conda.sh",

  threads:
    int(config['gtdb']['gtdb_threads'])

  resources:
    mem_mb = int(config['gtdb']['gtdb_mem_mb']),
    hours = int(config['gtdb']['gtdb_hours'])

  shell:
    " set +u ;"
    " source {params.conda_profile} ;"
    " conda activate gtdbtk ;"
    " /bin/mkdir -p results/taxonomy ;"
    " srun gtdbtk classify_wf "
    "  --genome_dir results/genomes/ "
    "  --out_dir results/taxonomy "
    "  --cpus {threads} 2> {log} ;"
    " /bin/touch {output.LINK} ;"

#-------------------------------------------------------------------------------
