rule fastp:
  input:
    FORWARD = f"{DataFolder}" + "{sample}" + config['mates']['mate1'] + f"{fastx_extension}",
    REVERSE = f"{DataFolder}" + "{sample}" + config['mates']['mate2'] + f"{fastx_extension}"

  output:
    FORWARD = "results/0_trim/{sample}/{sample}" + "_1" + f"{fastx_extension}",
    REVERSE = "results/0_trim/{sample}/{sample}" + "_2" + f"{fastx_extension}",
    JSON = "results/0_trim/{sample}/{sample}.json",
    HTML = "results/0_trim/{sample}/{sample}.html"

  log: "results/0_trim/{sample}/fastp.log"

  params:
    fastp=config['fastp']['fastp_version']

  threads:
    int(config['fastp']['fastp_threads'])

  resources:
    mem_mb = int(config['fastp']['fastp_mem_mb']),
    hours = int(config['fastp']['fastp_hours'])

  shell:
    " module add UHTS/Quality_control/fastp/{params.fastp} ;"
    " mkdir -p results ;"
    " mkdir -p results/5_report ;"
    " /bin/touch results/5_report/conda_software_versions.txt ;"
    " srun fastp "
    " -i {input.FORWARD} -o {output.FORWARD} "
    " -I {input.REVERSE} -O {output.REVERSE} "
    " -j {output.JSON} -h {output.HTML} "
    " --detect_adapter_for_pe 2> {log} ;"

#-------------------------------------------------------------------------------

rule fastqc_run:
  input:
    R1= "results/0_trim/{sample}/{sample}" + config['mates']['mate1'] + f"{fastx_extension}",
    R2= "results/0_trim/{sample}/{sample}" + config['mates']['mate2'] + f"{fastx_extension}"

  output:
    ZIP_1 = "results/0_trim/{sample}/result_fastqc/{sample}" + config['mates']['mate1'] + "_fastqc.zip",
    ZIP_2 = "results/0_trim/{sample}/result_fastqc/{sample}" + config['mates']['mate2'] + "_fastqc.zip"

  log:
    LOG_1 = "results/0_trim/{sample}/result_fastqc/fastqc_forward.log",
    LOG_2 = "results/0_trim/{sample}/result_fastqc/fastqc_reverse.log"

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
    "  -o results/0_trim/{wildcards.sample}/result_fastqc/ 2> {log.LOG_1} ;"
    " srun fastqc {input.R2} -t {threads} "
    "  -o results/0_trim/{wildcards.sample}/result_fastqc/ 2> {log.LOG_2} ;"

#-------------------------------------------------------------------------------
rule parse_fastqc_output:
  input:
    fastqc_F= "results/0_trim/{sample}/result_fastqc/{sample}" + config['mates']['mate1'] + "_fastqc.zip",
    fastqc_R= "results/0_trim/{sample}/result_fastqc/{sample}" + config['mates']['mate2'] + "_fastqc.zip"

  output:
    FORWARD = "results/5_report/{sample}/{sample}_summary_fastqc_F.txt",
    REVERSE = "results/5_report/{sample}/{sample}_summary_fastqc_R.txt"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " srun workflow/scripts/parse_fastqc.sh -s={wildcards.sample}  "
    "  -F={input.fastqc_F} "
    "  -R={input.fastqc_R} "
    "  -o=results/5_report/{wildcards.sample} ;"

#-------------------------------------------------------------------------------

rule concatenate_results:
  input:
    fastqc_F=expand("results/5_report/{sample}/{sample}_summary_fastqc_F.txt", sample=samples),
    fastqc_R=expand("results/5_report/{sample}/{sample}_summary_fastqc_R.txt", sample=samples)

  output:
    "results/5_report/fastqc_summary_all.txt"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " srun /bin/cat {input.fastqc_F} {input.fastqc_R}  > {output} ;"
      #"srun /bin/cat{input.fastqc_F} {input.fastqc_R} > {output}"

#-------------------------------------------------------------------------------
