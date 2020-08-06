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
      #full_width = F,
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
