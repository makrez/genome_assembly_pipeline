rule fastp:
  input:
    FORWARD = f"{DataFolder}" + "{sample}" + config['mates']['mate1'] + f"{fastx_extension}",
    REVERSE = f"{DataFolder}" + "{sample}" + config['mates']['mate2'] + f"{fastx_extension}"

  output:
    FORWARD = temp("results/{sample}/0_trim/{sample}" + "_1" + f"{fastx_extension}"),
    REVERSE = temp("results/{sample}/0_trim/{sample}" + "_2" + f"{fastx_extension}"),
    JSON = "results/{sample}/0_trim/{sample}.json",
    HTML = "results/{sample}/0_trim/{sample}.html"

  log: "results/{sample}/logs/fastp.log"

  params:
    conda_profile = "/mnt/apps/centos7/Conda/miniconda3/etc/profile.d/conda.sh",    
    fastp=config['fastp']['fastp_version']

  threads:
    int(config['fastp']['fastp_threads'])

  resources:
    mem_mb = int(config['fastp']['fastp_mem_mb']),
    hours = int(config['fastp']['fastp_hours'])

  shell:
    " set +u ;"
    " source {params.conda_profile} ;"
    " conda activate seqtk_1.3 ; "
    " mkdir -p results/{wildcards.sample}/report ;"
    " /bin/touch results/{wildcards.sample}/report/software.txt ;"
    " srun fastp "
    " -i {input.FORWARD} -o {output.FORWARD} "
    " -I {input.REVERSE} -O {output.REVERSE} "
    " -r -j {output.JSON} -h {output.HTML} "
    " --detect_adapter_for_pe 2> {log} ;"

#-------------------------------------------------------------------------------

rule fastqc_run:
  input:
    R1= "results/{sample}/0_trim/{sample}" + config['mates']['mate1'] + f"{fastx_extension}",
    R2= "results/{sample}/0_trim/{sample}" + config['mates']['mate2'] + f"{fastx_extension}"

  output:
    ZIP_1 = "results/{sample}/0_trim/result_fastqc/{sample}" + config['mates']['mate1'] + "_fastqc.zip",
    ZIP_2 = "results/{sample}/0_trim/result_fastqc/{sample}" + config['mates']['mate2'] + "_fastqc.zip"

  log:
    LOG_1 = "results/{sample}/logs/fastqc_forward.log",
    LOG_2 = "results/{sample}/logs/fastqc_reverse.log"

  params:
    fastqc=config['fastqc']['fastqc_version']

  threads:
    int(config['fastqc']['fastqc_threads'])

  resources:
    mem_mb = int(config['fastqc']['fastqc_mem_mb']),
    hours = int(config['fastqc']['fastqc_hours'])

  shell:
    " module add UHTS/Quality_control/fastqc/{params.fastqc} ;"
    " srun fastqc {input.R1} -t {threads} "
    "  -o results/{wildcards.sample}/0_trim/result_fastqc/ 2> {log.LOG_1} ;"
    " srun fastqc {input.R2} -t {threads} "
    "  -o results/{wildcards.sample}/0_trim/result_fastqc/ 2> {log.LOG_2} ;"

#-------------------------------------------------------------------------------
rule parse_fastqc_output:
  input:
    fastqc_F= "results/{sample}/0_trim/result_fastqc/{sample}" + config['mates']['mate1'] + "_fastqc.zip",
    fastqc_R= "results/{sample}/0_trim/result_fastqc/{sample}" + config['mates']['mate2'] + "_fastqc.zip"

  output:
    FORWARD = "results/{sample}/0_trim/{sample}_summary_fastqc_F.txt",
    REVERSE = "results/{sample}/0_trim/{sample}_summary_fastqc_R.txt",
    CONCATENATE =  "results/{sample}/report/report_fastqc.txt",

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " srun workflow/scripts/parse_fastqc.sh -s={wildcards.sample}  "
    "  -F={input.fastqc_F} "
    "  -R={input.fastqc_R} "
    "  -o=results/{wildcards.sample}/0_trim ;"
    " /bin/cat results/{wildcards.sample}/0_trim/{wildcards.sample}_summary_fastqc_F.txt "
    "  results/{wildcards.sample}/0_trim/{wildcards.sample}_summary_fastqc_R.txt "
    "  > {output.CONCATENATE} ;"

#-------------------------------------------------------------------------------

rule concatenate_results:
  input:
    CONCATENATE =  expand("results/{sample}/report/report_fastqc.txt", \
                          sample = samples)

  output:
    "results/summary_report/fastqc_summary_all.txt"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " srun /bin/cat {input.CONCATENATE} > {output} ;"
      #"srun /bin/cat{input.fastqc_F} {input.fastqc_R} > {output}"

#-------------------------------------------------------------------------------
