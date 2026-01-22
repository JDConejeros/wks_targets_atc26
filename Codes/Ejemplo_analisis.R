# Code de referencia

# Settings ---- 

options(scipen=999)
options(max.print = 99999999)
options(knitr.kable.NA = '', OutDec = ".") 
knitr::opts_chunk$set("ft.shadow" = FALSE)
#rm(list=(ls()))

# Local figures text
#Sys.setlocale(category = "LC_ALL", "es_ES.UTF-8") #LAT
Sys.setlocale(category = "LC_ALL", "en_US.UTF-8") #USA

# Function install/load packages
install_load <- function(packages){
  for (i in packages) {
    if (i %in% rownames(installed.packages())) {
      library(i, character.only=TRUE)
    } else {
      install.packages(i)
      library(i, character.only = TRUE)
    }
  }
}

# Apply function common packages 
install_load(c("rio", 
               "vtable",
               "janitor", 
               "tidyverse", 
               "openxlsx",
               "parallel", 
               "future", 
               "purrr", 
               "furrr",
               "future.apply", 
               "zoo",
               "tidymodels",
               "tictoc",
               "paletteer",
               "broom",
               "survival",
               "flexsurv",
               "survminer",
               "ggsurvfit",
               "RColorBrewer", 
               "coxme"
               ))

# Open data ---- 

data <- rio::import("Input/data/Nacimientos_Santiago_muestra10_1992_2020.RData")
glimpse(data)

# Process data ---- 

# Generemos los outcomes 
data <- data |> 
  mutate(
    birth_preterm = if_else(weeks < 37, 1, 0),
    birth_very_preterm = if_else(weeks >= 28 & weeks <32, 1, 0),
    birth_moderately_preterm = if_else(weeks >= 32 & weeks <33, 1, 0),
    birth_late_preterm = if_else(weeks >= 34 & weeks <37, 1, 0),
    birth_term = if_else(weeks >= 37 & weeks < 42, 1, 0)) 

glimpse(data)


# Visualize data ---- 

table <- data |> 
  group_by(year_nac) |> 
  summarise(
    tasa_pt=mean(birth_preterm, na.rm=TRUE)*100,
    tasa_vpt=mean(birth_very_preterm, na.rm=TRUE)*100,
    tasa_mpt=mean(birth_moderately_preterm, na.rm=TRUE)*100,
    tasa_lpt=mean(birth_late_preterm, na.rm=TRUE)*100,
    tasa_t=mean(birth_term, na.rm=TRUE)*100
  ) |> 
  pivot_longer(
    cols=!year_nac, 
    names_to="preterm",
    values_to="prev"
  ) |> 
  mutate(preterm=case_when(
    preterm=="tasa_pt" ~ "Preterm",  
    preterm=="tasa_vpt" ~ "Very Preterm",
    preterm=="tasa_mpt" ~ "Moderately Preterm",
    preterm=="tasa_lpt" ~ "Late Preterm",
    preterm=="tasa_t" ~  "Term"
  )) |> 
  mutate(preterm=factor(preterm, levels=c(
    "Preterm",
    "Very Preterm",
    "Moderately Preterm",
    "Late Preterm",
    "Term"
  )))

  titles <- c(
    "A. Preterm (<37 weeks)", 
    "B. Very Preterm (28-32 weeks)", 
    "C. Moderately Preterm (32-33 weeks)", 
    "D. Late Preterm (34-37 weeks)", 
    "E. Term (>38 weeks)"
  )

plots_data <- split(table, table$preterm)

figures <- map2(
  plots_data,
  titles,
  ~ ggplot(.x, aes(y = prev, x = year_nac)) +
    geom_line(color = "#08519c") +
    geom_point(color = "#08519c", size = 0.5) +
    geom_smooth(
      method = "lm",
      formula = y ~ x + I(x^2),
      color = "gray30",
      alpha = 0.5,
      linewidth = 0.5
    ) +
    labs(
      title = .y,
      y = "Prevalence (per 100)",
      x = NULL
    ) +
    scale_x_continuous(breaks = seq(1992, 2020, by = 4)) +
    scale_y_continuous(n.breaks = 4) +
    theme_light() +
    theme(
      plot.title = element_text(size = 11, hjust = 0, face = "bold"),
      panel.grid = element_blank()
    )
)

#wrap_plots(figures, ncol = 2)
do.call(ggarrange, c(figures, list(nrow = 3, ncol = 2, common.legend=TRUE)))

ggsave(filename = paste0("Output/", "Figures/", "Nacimiento_trends", ".png"), # "Preterm_trendsrm1991"
       res = 300,
       width = 20,
       height = 17,
       units = 'cm',
       scaling = 0.90,
       device = ragg::agg_png)


# Descriptive table ---- 

tab1 <- data |> 
   select(
     sex:birth_term,     
   ) |>
  mutate(
    across(starts_with("HW"), as.factor),
    across(starts_with("birth_"), as.factor)
  ) |>  
   st(,
   digits = 1, 
   out="return", 
   add.median = TRUE,
   fixed.digits = TRUE, 
   simple.kable = FALSE,
   title="",
   numformat = NA) |> 
   data.frame() 

tab1

rio::export(tab1, file =  paste0("Output/", "Tables/",  "Descriptivos_muestra", ".xlsx"))

# Models ---- 
glimpse(data)

dependent <- "birth_preterm"
predictor <- "HW_p90_2d_bin"

formula <- as.formula(paste("Surv(weeks, ", dependent, ") ~ ", predictor, 
                              "+ sex + age_group_mom + educ_group_mom + job_group_mom +",
                              "age_group_dad + educ_group_dad + job_group_dad +",
                              "cluster(com)"))
  
# Fit Cox model 
model_fit <- coxph(formula, data = data)
summary(model_fit)

# Extract results with tidy
results <- broom::tidy(model_fit, exponentiate = TRUE, conf.int = TRUE, conf.level = 0.95) |> 
    mutate(estimate = round(estimate, 3), 
           std.error = round(std.error, 3),
           statistic = round(statistic, 3),
           p.value = round(p.value, 3),
           conf.low = round(conf.low, 3),
           conf.high = round(conf.high, 3)) %>%
    select(term, estimate, std.error, statistic, p.value, conf.low, conf.high)

results
rio::export(results, file =  paste0("Output/", "Models/",  "Descriptivos_muestra", ".xlsx"))

# Figure
results |> 
  filter(term == predictor) |>
  ggplot(aes(x = estimate, y = term, color = term)) +
    geom_point(size = 3, shape = 15) +
    geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2) +
    geom_vline(xintercept = 1, linetype = "dashed", color = "red", alpha = 0.5) +
    scale_colour_manual(name = "Duration HW:", values = c("#e59866", "#d35400", "#873600")) +
    scale_x_continuous(limits = c(0,2)) + 
    labs(title = NULL,
         x = "HRs and 95% CI", 
         y = NULL) +
    theme_light() +
    theme(panel.grid = element_blank(),
          legend.position = "top",
          axis.text.y = element_blank(),
          legend.text = element_text(size = 11))
  