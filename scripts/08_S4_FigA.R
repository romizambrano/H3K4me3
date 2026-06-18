library(ggplot2)

plots_dir <- file.path("output", "figures")

dir.create(
  plots_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

ssrs_peaks_long <- ssrs_peaks %>% 
  pivot_longer(
    cols = c("EpiR1", "EpiR2", "TrypoR1", "TrypoR2"),
    names_to = "sample",
    values_to = "peaks_sum"
  )

dgc_boundaries_peaks <- dgc_boundaries %>% 
  left_join(ssrs_peaks_long)

(g_peaks_boundaries <- ggplot(
  dgc_boundaries_peaks %>%
    filter(!is.na(peaks_sum)) %>% 
    inner_join(peak_files_data),
  aes(
    x = factor(
      interaction(
        compartment,
        str_to_sentence(ssr_direction),
        sep = ";"
      ),
      levels = c(
        "Core;Convergent",
        "Disruptive;Convergent",
        "Core;Divergent",
        "Disruptive;Divergent"
      )
    ),
    y = log10(peaks_sum)
  )
) +
    
    geom_boxplot(
      outliers = FALSE,
      colour = "DarkGray"
    ) +
    
    geom_point(
      position = position_jitter(width = .25),
      size = .1
    ) +
    
    guides(
      x = legendry::guide_axis_nested(key = ";")
    ) +
    
    xlab("") +
    
    facet_wrap(
      . ~ sample_name,
      scales = "free_x"
    ) +
    
    ylab("log<sub>10</sub>(H3K4me3<sub>score sum</sub>)") +
    
    theme_bw() +
    
    theme(
      axis.title.y = element_markdown()
    )
)

ggsave(
  file.path(plots_dir, "S4 Fig A.pdf"),
  plot = g_peaks_boundaries,
  width = 15,
  height = 12,
  units = "cm"
)