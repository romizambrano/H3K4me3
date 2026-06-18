output_dir <- file.path(
  "output",
  "DGC_Boundaries"
)

dir.create(
  output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

#agregado lo de arriba

export_dgc_boundaries <- function(
    dgc_data,
    output_subdirectory,
    output_file_name,
    boundary_type
) {
  if (boundary_type == "starts") {
    boundary_data <- dgc_data %>%
      mutate(
        from = position - if_else(strand == "+", 0, 1),
        to = position + if_else(strand == "+", 1, 0)
      )
  } else {
    boundary_data <- dgc_data %>%
      mutate(
        from = position - if_else(strand == "+", 1, 0),
        to = position + if_else(strand == "+", 0, 1)
      )
  }
  
  boundary_data <- boundary_data %>% select(seqid, strand, from, to)
  
  output_connection <- file(
    file.path(
      output_subdirectory,
      paste0(if_else(boundary_type == "starts", "5'", "3'"),
             output_file_name,
             ".gff")
    ),
    "w"
  )
  
  writeLines("##gff-version 3", output_connection)
  
  for (row_index in seq_len(nrow(boundary_data))) {
    
    current_row <- boundary_data[row_index, ]
    
    writeLines(
      paste(
        current_row$seqid,
        "StrandSwitches_R",
        ".",
        current_row$from,
        current_row$to,
        0,
        current_row$strand,
        0,
        ".",
        sep = "\t"
      ),
      output_connection
    )
  }
  
  close(output_connection)
}

export_dgc_boundary_groups <- function(
    filtered_dgcs,
    output_subdirectory,
    dgc_group_name,
    boundary_types
) {
  
  for (boundary_type in boundary_types) {
    
    export_dgc_boundaries(
      filtered_dgcs,
      output_subdirectory,
      dgc_group_name,
      boundary_type
    )
  }
  
  for (cmp in c("Core", "Disruptive")) {
    
    for (boundary_type in boundary_types) {
      
      export_dgc_boundaries(
        filtered_dgcs %>%
          filter(compartment == cmp),
        output_subdirectory,
        paste0(dgc_group_name, "_", cmp),
        boundary_type
      )
    }
  }
}

filtered_boundaries <- dgc_boundaries %>%
  inner_join(dgcs %>% select(dgcId, dgc_length = length)) %>% 
  filter(dgc_length >= 10000
         & !is.na(ssrId))

filter_description <- "+10000"

dir.create(
  file.path(output_dir, filter_description),
  recursive = TRUE,
  showWarnings = FALSE
)

for (boundary_type in c("starts", "ends")) {
  
  export_dgc_boundary_groups(
    filtered_boundaries %>%
      filter(ssr_direction == if_else(boundary_type == "starts",
                                       "divergent",
                                       "convergent")),
    #file.path(getwd(), "DGC_Boundaries", filter_description),
    file.path(output_dir, filter_description),
    filter_description,
    c(boundary_type)
  )
}

