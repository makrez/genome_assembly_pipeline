#!/bin/bash

mkdir -p "test";
rsync -rav "Snakefile" test/.;
rsync -rav "workflow" test/.;
rsync -rav "config" test/.;
rsync -rav "resources" test/.;
rsync -rav "data_testing" test/.;
rsync -rav "run_sbatch.sh" test/.;

## replace threads/hours/mem_mb in rules
#-------------------------------------------------------------------------------

for i in $(ls workflow/rules); do \
# replace threads-statement
 sed "s/.*_threads'])/    int(config['testing']['testing_threads'])/g"  < \
  workflow/rules/$i | \
# replace hours-statement
 sed "s/hours.*/hours = int(config['testing']['testing_hours']),/g" | \
#replace mem_mb-statement
 sed "s/mem_mb.*/mem_mb = int(config['testing']['testing_mem_mb']),/g" > \
  test/workflow/rules/$i; done

## replace DataFolder to DataFolder_testing in Snakefile
#-------------------------------------------------------------------------------

sed "s/config\['DataFolder'\]/config['DataFolder_testing']/g" < workflow/Snakefile \
 > test/Snakefile

## Specific change for rule gtdb (needs high memory)

sed '96,${s/mem_mb.*/mem_mb = int(config['gtdb']['gtdb_mem_mb']),/g}'  \
 < workflow/rules/prokka.smk > test/workflow/rules/prokka.smk
