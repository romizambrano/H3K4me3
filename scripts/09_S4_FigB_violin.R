library(ggplot2)
library(ggtext) 
library(ggsignif)


plots_dir <- file.path("output", "figures")

dir.create(
  plots_dir,
  recursive = TRUE,
  showWarnings = FALSE
)
#plots_dir <- file.path(getwd(), "Plots")

dssrs_boundaries <- strand_switches %>% 
  filter(ssr_direction == "divergent") %>% 
  select(ssrId, length) %>% 
  left_join(dgc_boundaries %>%
              filter(boundary  == "divergent_minus") %>% 
              select(ssrId, minus = compartment)) %>% 
  left_join(dgc_boundaries %>%
              filter(boundary  == "divergent_plus") %>% 
              select(ssrId, plus = compartment)) %>% 
  mutate(compartment = if_else(minus == "Core" & plus == "Core",
                               "Core",
                               if_else(minus == "Disruptive" & plus == "Disruptive",
                                       "Disruptive",
                                       "Both")))

(g_ssr_compartments <- ggplot(dssrs_boundaries %>% 
                                filter(compartment  %in% c("Core", "Disruptive")),
                              aes(x = compartment,
                                  y = log10(length))) +
    geom_violin() +
    geom_point(position = position_jitter(width = .25),
               size = .25) +
    geom_signif(comparisons = list(c("Core", "Disruptive")), 
                test = "t.test", 
                map_signif_level = TRUE,
                y_position = c(4.5)) +
    expand_limits(y = 4.75) +
    xlab("Compartment") +
    ylab("log<sub>10</sub>(dSSR length)") +
    theme_bw() +
    theme(axis.title.y = element_markdown()))

ggsave(
  file.path(plots_dir, "S4 Fig B (dSSR lengths by compartment)_violin.pdf"),
  plot = g_ssr_compartments,
  width = 8,
  height = 8,
  units = "cm"
)
