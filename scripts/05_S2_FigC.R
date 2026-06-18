library(ggplot2)
library(ggtext) 
plots_dir <- file.path("output", "figures")

dir.create(
  plots_dir,
  recursive = TRUE,
  showWarnings = FALSE
)
#plots_dir <- file.path(getwd(), "Plots")

average_ssr_peaks <- ssrs_peaks %>%
  filter(ssr_direction == "divergent") %>%
  mutate(epimastigote_mean = (coalesce(EpiR1, 0) + coalesce(EpiR2, 0)) / 2,
         trypomastigote_mean = (coalesce(TrypoR1, 0) + coalesce(TrypoR2, 0)) / 2)

filtered_average_ssr_peaks <- average_ssr_peaks %>%
  filter(epimastigote_mean != 0 &
           trypomastigote_mean != 0)

spearman_epi_trypo_peaks <- cor(
  log10(filtered_average_ssr_peaks$epimastigote_mean),
  log10(filtered_average_ssr_peaks$trypomastigote_mean),
  method = "spearman"
)

(g_epi_vs_trypo_mean <- ggplot(filtered_average_ssr_peaks,
                               aes(x = log10(epimastigote_mean),
                                   y = log10(trypomastigote_mean))) +
    geom_point(size = 0.25) +
    geom_smooth(method = "lm") +
    annotate(geom = "text",
             label = paste0("Spearman = ",
                            round(spearman_epi_trypo_peaks, 2),
                            "\nN = ",
                            nrow(filtered_average_ssr_peaks),
                            " dSSRs"),
             x = 3.25,
             y = 1.55,
             vjust = 0.5,
             size = 3) +
    xlab("log<sub>10</sub>(Epimastigote<sub>H3K4me3</sub>)") +
    ylab("log<sub>10</sub>(Trypomastigote<sub>H3K4me3</sub>)") +
    theme_bw() +
    theme(axis.title.x = element_markdown(),
          axis.title.y = element_markdown()))

ggsave(
  file.path(plots_dir, "S2 Fig C (Epimastigote_vs_Trypomastigote_Average_Peaks).pdf"),
  plot = g_epi_vs_trypo_mean,
  width = 8,
  height = 8,
  units = "cm"
)
