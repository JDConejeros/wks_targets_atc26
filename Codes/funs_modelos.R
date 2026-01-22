# Funciones para modelos

suppressPackageStartupMessages({
  library(dplyr)
  library(survival)
  library(broom)
  library(ggplot2)
  library(rio)
})

armar_formula_cox <- function(dependent, predictor) {
  # Armo la fórmula tal como en el script.
  # Uso `paste()` para que sea fácil cambiar el outcome o el predictor.
  as.formula(
    paste(
      "Surv(weeks,", dependent, ") ~", predictor,
      "+ sex + age_group_mom + educ_group_mom + job_group_mom +",
      "age_group_dad + educ_group_dad + job_group_dad +",
      "cluster(com)"
    )
  )
}

ajustar_cox <- function(data, formula) {
  # Ajusto el modelo.
  survival::coxph(formula, data = data)
}

extraer_resultados_cox <- function(model_fit, conf_level = 0.95) {
  # Dejo una tablita ordenada, igual que en el código de referencia.
  broom::tidy(model_fit, exponentiate = TRUE, conf.int = TRUE, conf.level = conf_level) |>
    mutate(
      estimate = round(estimate, 3),
      std.error = round(std.error, 3),
      statistic = round(statistic, 3),
      p.value = round(p.value, 3),
      conf.low = round(conf.low, 3),
      conf.high = round(conf.high, 3)
    ) |>
    select(term, estimate, std.error, statistic, p.value, conf.low, conf.high)
}

guardar_resultados_xlsx <- function(resultados, path_xlsx) {
  rio::export(resultados, file = path_xlsx)
  path_xlsx
}

figura_forest_predictor <- function(resultados, predictor, x_limits = c(0, 2)) {
  # Grafico solo el término del predictor, como en el script.
  resultados |>
    filter(term == predictor) |>
    ggplot(aes(x = estimate, y = term, color = term)) +
    geom_point(size = 3, shape = 15) +
    geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2) +
    geom_vline(xintercept = 1, linetype = "dashed", color = "red", alpha = 0.5) +
    scale_colour_manual(
      name = "Duration HW:",
      values = c("#e59866", "#d35400", "#873600")
    ) +
    scale_x_continuous(limits = x_limits) +
    labs(
      title = NULL,
      x = "HRs and 95% CI",
      y = NULL
    ) +
    theme_light() +
    theme(
      panel.grid = element_blank(),
      legend.position = "top",
      axis.text.y = element_blank(),
      legend.text = element_text(size = 11)
    )
}
