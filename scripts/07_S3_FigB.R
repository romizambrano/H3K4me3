library(ggplot2)
library(ggtext)

plots_dir <- file.path("output", "figures")

dir.create(
  plots_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

ssr_cutoffs <- data.table(
  length = c(750, 2500, 5000, NA)
)

(g_ssr_cutoffs <- ggplot(
  strand_switches %>%
    filter(
      ssr_direction == "divergent",
      length > 0
    ),
  aes(x = log10(length))
) +
    
    geom_density() +
    
    geom_vline(
      data = ssr_cutoffs,
      aes(xintercept = log10(length)),
      colour = "gray",
      linetype = "dotted"
    ) +
    
    geom_text(
      data = ssr_cutoffs,
      aes(
        x = log10(length),
        label = length
      ),
      y = 1.32,
      hjust = 0,
      size = 4,
      angle = 45
    ) +
    
    scale_x_continuous(
      limits = c(0.5, 5),
      breaks = c(1, 2, 3, 4, 5)
    ) +
    
    scale_y_continuous(
      limits = c(0, 1.2),
      breaks = c(0, 0.4, 0.8, 1.2)
    ) +
    
    coord_cartesian(
      clip = "off"
    ) +
    
    xlab("log<sub>10</sub>(dSSR length)") +
    ylab("Density") +
    
    theme_bw() +
    
    theme(
      panel.grid = element_blank(),
      axis.title.x = element_markdown(),
      plot.margin = margin(
        t = 40,
        r = 5,
        b = 5,
        l = 5
      )
    )
)

ggsave(
  file.path(plots_dir, "S3 Fig B (dSSR lengths).pdf"),
  plot = g_ssr_cutoffs,
  width = 10,
  height = 8,
  units = "cm"
)