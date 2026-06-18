library(ggplot2)
library(ggtext)
library(dplyr)
library(stringr)

plots_dir <- file.path("output", "figures")

dir.create(
  plots_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

peak_locations <- peaks %>%
  left_join(
    strand_switches %>%
      select(ssrId, ssr_direction)
  ) %>%
  mutate(
    location = if_else(
      !is.na(ssr_direction),
      paste0(str_to_sentence(ssr_direction), ";SSR"),
      if_else(!is.na(dgcId), "DGC", "Other")
    )
  )

(g_peak_locations <- ggplot(
  peak_locations,
  aes(
    x = factor(
      location,
      levels = c(
        "Convergent;SSR",
        "Divergent;SSR",
        "DGC",
        "Other"
      )
    ),
    y = log10(Score)
  )
) +
    
    geom_boxplot(
      outliers = FALSE,
      colour = "DarkGray"
    ) +
    
    geom_point(
      position = position_jitter(width = 0.25),
      size = 0.1
    ) +
    
    guides(
      x = legendry::guide_axis_nested(key = ";")
    ) +
    
    xlab("") +
    
    facet_wrap(
      ~sample_name,
      scales = "free_x"
    ) +
    
    ylab("log<sub>10</sub>(H3K4me3<sub>score</sub>)") +
    
    theme_bw() +
    
    theme(
      axis.title.y = element_markdown()
    )
)

ggsave(
  file.path(plots_dir, "S1 Fig (peak locations).pdf"),
  plot = g_peak_locations,
  width = 15,
  height = 12,
  units = "cm"
)