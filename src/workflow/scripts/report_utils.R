library(tidyverse)
library(kableExtra)
library(RJSONIO)

#===============================================================================
# Syling
#-------------------------------------------------------------------------------

# Global table styling
#-------------------------------------------------------------------------------

table_styling <- function(table, caption){
  table <- table %>% mutate_if(is.numeric, formatC, digits=2, big.mark = '\'',
                              drop0trailing=TRUE, format = "f")
  knitr::kable(table, format = "html", escape = F, caption = caption) %>%
    kableExtra::kable_styling(
      bootstrap_options = c("striped", "hover", "condensed", "responsive"),
      fixed_thead = T,
      position = "left"
  )
}
#-------------------------------------------------------------------------------


#===============================================================================
# Transform Data Functions
#-------------------------------------------------------------------------------

# Fastp Data
#-------------------------------------------------------------------------------

transform_fastp_comparison <- function(jsonlist){
  jsonlist$summary %>%
    bind_rows(.id="status")
}

transform_fastp_result <- function(jsontable){
  jsontable$filtering_result %>% as_tibble(rownames = "Statistics") %>%
  rename(Value = value)
}

# FastQC Data
#-------------------------------------------------------------------------------

transform_fastqc <- function(fastqc_table){
  names(fastqc_table) <- c("Sample",
                           "Reads", "Deduplicated", "Adapter", "direction")
  fastqc_table <- fastqc_table %>%
                    arrange(Sample) %>%
                    mutate(
                      Adapter = cell_spec(Adapter, "html",
                        color = ifelse(Adapter == 'pass', "green", "red"))
                    )
  return(fastqc_table)
}

# Quast for summary report

transform_quast_summary <- function(table){
  names(table) <- c("Metric", "Value", "Sample")
  table <- table %>%
    pivot_wider(Sample, names_from = "Metric", values_from = "Value") %>%
    select('Sample','# contigs', 'Largest contig', 'Total length', 'GC (%)',
          'N50', 'N75', 'L50','L75','# N\'s per 100 kbp') %>%
          rename(N_per100kbp = '# N\'s per 100 kbp')
  return(table)
}

# Confindr
#-------------------------------------------------------------------------------

transform_confindr_csv <- function(table){
  table <- table %>%
    mutate(
      ContamStatus = cell_spec(ContamStatus, "html",
        color = ifelse(ContamStatus == 'False', "green", "red"))
    )
}

# Prokka csv
#-------------------------------------------------------------------------------

transform_prokka_csv <- function(csv){
  csv <- csv[,1:2]
  names(csv) <- c("Feature", "Count")
  return(csv)
}

transform_prokka_csv_summary <- function(csv){
  names(csv) <- c("Feature", "Count", "Sample")
  csv <- csv %>%
      pivot_wider(Sample, names_from = "Feature", values_from = "Count")
  return(csv)
}


# Taxonomy Table
#-------------------------------------------------------------------------------

transform_taxonomy <- function(tax, sample){
  sample <- enquo(sample)
  tax <- tax %>%
    filter(user_genome == !!sample)

  tax <- tax %>% select(user_genome, classification, classification_method) %>%
    rename(Sample = user_genome) %>%
    separate(classification, sep =";.__",
      into = c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species"))
  return(tax)
}

transform_taxonomy_summary <- function(tax){
  tax <- tax %>% select(user_genome, classification, classification_method) %>%
    rename(Sample = user_genome) %>%
    separate(classification, sep =";.__",
      into = c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species"))
  return(tax)
}
