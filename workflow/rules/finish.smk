rule finish_pipeline:
  input:
    report = expand("results/{sample}/report/{sample}_report.html", \
                    sample = samples),
    report_summary = "results/summary_report/summary_report.html"

  output:
    "results/{sample}/report/pipeline_finished.txt"

  threads:
    int(config['short_sh_commands_threads'])

  resources:
    mem_mb = int(config['short_commands_mb']),
    hours = int(config['short_sh_commands_hours'])

  shell:
    " /bin/echo 'Pipeline finished' > {output} ;"
