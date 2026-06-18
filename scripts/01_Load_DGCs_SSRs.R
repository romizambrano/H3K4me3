library(ape)
library(data.table)
library(dplyr)
library(stringr)
library(tidyr)

raw_data_dir <- "raw_data"
#raw_data_dir <- file.path(getwd(), "Raw data")

annotation <- read.gff(file.path(raw_data_dir, "TcDm28cT2T_manualCurated.gff"),
                       na.strings = c(".", "?"),
                       GFF3 = TRUE) %>%
  separate_rows(attributes, sep = ";") %>%
  separate(attributes, into = c("key", "value"), sep = "=") %>%
  pivot_wider(names_from = key, values_from = value) %>%
  arrange(seqid, start)

compartments <- read.table(file.path(raw_data_dir, "Core_disrruptivo_Balouz_T2Tgenome.csv"),
                           sep = ";",
                           header = TRUE)

previous_row <- NULL

strand_switches <- data.table(
  ssrId = character(),
  seqid = character(),
  ssr_start = numeric(),
  ssr_end = numeric(),
  length = numeric(),
  ssr_direction = character(),
  minus_dgc = character(),
  plus_dgc = character(),
  minus_gene = character(),
  plus_gene = character()
)

dgcs <- data.table(
  dgcId = character(),
  d_ssrId = character(),
  c_ssrId = character(),
  seqid = character(),
  start = numeric(),
  end = numeric(),
  strand = character()
)

ssr_count <- 0
divergent_ssr_count <- 0
convergent_ssr_count <- 0

current_dgc_index <- 0
current_chromosome_dgc_number <- 0
current_dgc_id <- NA_character_

annotation$dgcId <- NA_character_

for (row_index in seq_len(nrow(annotation))) {
  current_row <- annotation[row_index, ]
  
  chromosome <- str_sub(current_row$seqid, -2)
  
  if (is.null(previous_row) ||
      previous_row$seqid != current_row$seqid) {
    
    if (current_dgc_index != 0) {
      dgcs[current_dgc_index, ]$end <- previous_row$end
    }
    
    divergent_ssr_count <- 0
    convergent_ssr_count <- 0
    current_chromosome_dgc_number <- 1
    
    current_dgc_index <- current_dgc_index + 1
    
    current_dgc_id <- paste0("DGC", chromosome, ".",
                             str_sub(paste0("000", current_chromosome_dgc_number), -3))
    
    dgcs <- dgcs %>%
      rbind(
        list(
          dgcId = current_dgc_id,
          seqid = current_row$seqid,
          start = current_row$start,
          strand = current_row$strand
        ),
        fill = TRUE
      )
    
  } else if (current_row$strand != previous_row$strand) {
    
    dgcs[current_dgc_index, ]$end <- previous_row$end

    if (current_row$strand == "+" &&
        previous_row$strand == "-") {
      direction <- "divergent"
      divergent_ssr_count <- divergent_ssr_count + 1
      
      ssrId <- paste0("dSSR", chromosome, ".",
                      str_sub(paste0("00", divergent_ssr_count), -2))
      
      dgcs[current_dgc_index, ]$d_ssrId <- ssrId
      
    } else {
      direction <- "convergent"
      convergent_ssr_count <- convergent_ssr_count + 1
      
      ssrId <- paste0("cSSR", chromosome, ".",
                      str_sub(paste0("00", convergent_ssr_count), -2))
      
      dgcs[current_dgc_index, ]$c_ssrId <- ssrId
    }
    
    ssr_start <- previous_row$end + 1
    ssr_end <- current_row$start - 1
    
    ssr_count <- ssr_count + 1
    
    strand_switches <- strand_switches %>%
      rbind(
        list(
          ssrId = ssrId,
          seqid = current_row$seqid,
          ssr_start = ssr_start,
          ssr_end = ssr_end,
          length = ssr_end - ssr_start + 1,
          ssr_direction = direction,
          minus_dgc = if_else(direction == "divergent", current_dgc_id, NA_character_),
          plus_dgc = if_else(direction == "divergent", NA_character_, current_dgc_id),
          minus_gene = if_else(direction == "divergent", previous_row$ID, current_row$ID),
          plus_gene = if_else(direction == "divergent", current_row$ID, previous_row$ID)
        ),
        fill = TRUE
      )
    
    current_dgc_index <- current_dgc_index + 1
    current_chromosome_dgc_number <- current_chromosome_dgc_number + 1
    
    current_dgc_id <- paste0("DGC", chromosome, ".",
                             str_sub(paste0("000", current_chromosome_dgc_number), -3))
    
    dgcs <- dgcs %>%
      rbind(
        list(
          dgcId = current_dgc_id,
          seqid = current_row$seqid,
          start = current_row$start,
          strand = current_row$strand,
          d_ssrId = if_else(direction == "divergent", ssrId, NA_character_),
          c_ssrId = if_else(direction == "convergent", ssrId, NA_character_)
        ),
        fill = TRUE
      )
    
    if (direction == "divergent") {
      strand_switches[ssr_count, ]$plus_dgc <- current_dgc_id
    } else {
      strand_switches[ssr_count, ]$minus_dgc <- current_dgc_id
    }
  }
  
  annotation[row_index, ]$dgcId <- current_dgc_id
  previous_row <- current_row
}

dgcs[current_dgc_index, ]$end <- previous_row$end

dgcs <- dgcs %>%
  mutate(length = end - start + 1) %>%
  left_join(
    annotation %>%
      mutate(gene_length = end - start + 1) %>%
      group_by(dgcId) %>%
      summarise(
        genes_total_length = sum(gene_length),
        gene_count = n(),
        .groups = "drop"
      )
  )

find_compartment_by_position <- function(seqid, position) {
  filtered_rows <- compartments %>%
    filter(
      Sequence.name == seqid,
      Start <= position,
      End >= position
    )
  
  if (nrow(filtered_rows) == 1) {
    return(first(filtered_rows$Region.Type))
  }
  
  NA_character_
}

dgc_boundaries <- dgcs %>%
  select(dgcId, ssrId = d_ssrId, seqid, strand, start, end) %>%
  rowwise() %>%
  mutate(
    ssr_direction = "divergent",
    boundary = paste0("divergent_", if_else(strand == "+", "plus", "minus")),
    position = if_else(strand == "+", start - 1, end + 1),
  ) %>% 
  mutate(compartment = find_compartment_by_position(seqid, position)) %>%
  union_all(
    dgcs %>%
      select(dgcId, ssrId = c_ssrId, seqid, strand, start, end) %>%
      rowwise() %>%
      mutate(
        ssr_direction = "convergent",
        boundary = paste0("convergent_", if_else(strand == "+", "plus", "minus")),
        position = if_else(strand == "+", end + 1, start - 1)
      ) %>% 
      mutate(compartment = find_compartment_by_position(seqid, position))
  ) %>% 
  select(-c(start, end)) %>% 
  arrange(seqid, position)
