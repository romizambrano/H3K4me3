library(writexl)

dir.create(
  file.path("output", "tables"),
  recursive = TRUE,
  showWarnings = FALSE
)
#agregado

ssrs_exporting <- strand_switches %>%
       inner_join(dgc_boundaries %>%
                    filter(strand == "-") %>% 
                    select(ssrId, start_compartment = compartment)) %>% 
       inner_join(dgc_boundaries %>%
                    filter(strand == "+") %>% 
                    select(ssrId, end_compartment = compartment)) %>% 
       mutate(length_bin = if_else(length >= 5000,
                                   "5000-longer",
                                   if_else(length >= 2500,
                                           "2500-5000",
                                           if_else(length >= 750,
                                                   "750-2500",
                                                   if_else(length > 0,
                                                           "0-750",
                                                           NA))))) %>% 
       select(seqid, 
              start = ssr_start, 
              end = ssr_end,
              length,
              direction = ssr_direction,
              start_compartment,
              end_compartment,
              length_bin)


#write_xlsx(ssrs_exporting, 
#           path = file.path(getwd(), "StrandSwitches.xlsx"))

write_xlsx(
  ssrs_exporting,
  path = file.path(
    "output",
    "tables",
    "S2_Table_StrandSwitches.xlsx"
  )
)