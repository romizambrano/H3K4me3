library(data.table)
library(dplyr)
library(stringr)

raw_data_dir <- "raw_data"
#raw_data_dir <- file.path(getwd(), "Raw data")

peak_files <- list.files(
  file.path(raw_data_dir, "H3K4me3"),
  pattern = "\\.bed$",
  full.names = TRUE
)

peak_files_data <- as.data.table(tribble(
  ~file_name, ~sample, ~sample_name, ~life_stage,
  "Epis_H3K4me3_1_IgG", "EpiR1", "Epimastigote - rep 1", "Epimastigote",
  "Epis_H3K4_me3_2_IgG", "EpiR2", "Epimastigote - rep 2", "Epimastigote",
  "Tryp_H3K4me3_1_igGc", "TrypoR1", "Trypomastigote - rep 1", "Trypomastigote",
  "Try_H3K4me3_2_IgG", "TrypoR2","Trypomastigote - rep 2",  "Trypomastigote",
))

peaks <- data.table()

for (file_path in peak_files) {
  sample_name <- str_trim(
    str_remove(
      basename(file_path),
      fixed("(narrow Peaks)].bed")
    )
  )
  
  loaded_peaks <- read.table(
    file_path,
    col.names = c(
      "Chrom",
      "Start",
      "End",
      "Name",
      "Score",
      "Strand",
      "ThickStart",
      "ThickEnd",
      "ItemRGB",
      "BlockCount"
    )
  ) %>%
    mutate(file_name = sample_name, .before = 1)
  
  peaks <- peaks %>%
    rbind(loaded_peaks)
}

peaks <- peaks %>%
  inner_join(peak_files_data)
# peaks<- peaks %>% 
#   inner_join(files_data)

peaks$ssrId <- NA_character_

for (peak_index in seq_len(nrow(peaks))) {
  current_peak <- peaks[peak_index, ]
  
  filtered_ssrs <- strand_switches %>%
    filter(
      seqid == current_peak$Chrom &
        ssr_start <= current_peak$End &
        ssr_end >= current_peak$Start
    )
  
  if (nrow(filtered_ssrs) == 1) {
    peaks[peak_index, ]$ssrId <- first(filtered_ssrs)$ssrId
  }
}

peaks$dgcId <- NA_character_

for (peak_index in seq_len(nrow(peaks))) {
  current_peak <- peaks[peak_index, ]
  
  if (!is.na(current_peak$ssrId)) {
    next
  }
  
  filtered_dgcs <- dgcs %>%
    filter(
      seqid == current_peak$Chrom &
        start <= current_peak$End &
        end >= current_peak$Start
    )
  
  if (nrow(filtered_dgcs) == 1) {
    peaks[peak_index, ]$dgcId <- first(filtered_dgcs)$dgcId
  }
}

ssrs_peaks <- strand_switches %>% 
  select(ssrId, ssr_direction) %>% 
  left_join(peaks %>% 
              inner_join(peak_files_data) %>% 
              group_by(sample, ssrId) %>% 
              summarise(peaks_sum = sum(Score))) %>% 
  mutate(column = coalesce(sample, "EpiR1")) %>% 
  pivot_wider(id_cols = c(ssrId, ssr_direction), 
              names_from = column, 
              values_from = peaks_sum)

