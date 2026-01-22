# Funciones para figuras

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(ggplot2)
  library(rio)
})

crear_tabla_tendencias <- function(data) {
  # Armo la tabla anual con prevalencias (x 100), y la dejo en formato largo.
  data |>
    group_by(year_nac) |>
    summarise(
      tasa_pt = mean(birth_preterm, na.rm = TRUE) * 100,
      tasa_vpt = mean(birth_very_preterm, na.rm = TRUE) * 100,
      tasa_mpt = mean(birth_moderately_preterm, na.rm = TRUE) * 100,
      tasa_lpt = mean(birth_late_preterm, na.rm = TRUE) * 100,
      tasa_t = mean(birth_term, na.rm = TRUE) * 100,
      .groups = "drop"
    ) |>
    pivot_longer(
      cols = !year_nac,
      names_to = "preterm",
      values_to = "prev"
    ) |>
    mutate(
      preterm = case_when(
        preterm == "tasa_pt" ~ "Preterm",
        preterm == "tasa_vpt" ~ "Very Preterm",
        preterm == "tasa_mpt" ~ "Moderately Preterm",
        preterm == "tasa_lpt" ~ "Late Preterm",
        preterm == "tasa_t" ~ "Term"
      ),
      preterm = factor(
        preterm,
        levels = c(
          "Preterm",
          "Very Preterm",
          "Moderately Preterm",
          "Late Preterm",
          "Term"
        )
      )
    )
}

titulos_tendencias <- function() {
  c(
    "A. Preterm (<37 weeks)",
    "B. Very Preterm (28-32 weeks)",
    "C. Moderately Preterm (32-33 weeks)",
    "D. Late Preterm (34-37 weeks)",
    "E. Term (>38 weeks)"
  )
}

crear_figuras_tendencias <- function(tabla_tendencias, titulos = titulos_tendencias()) {
  # Divido por categoría y creo una lista de ggplots.
  plots_data <- split(tabla_tendencias, tabla_tendencias$preterm)

  purrr::map2(
    plots_data,
    titulos,
    \(.x, .y) {
      ggplot(.x, aes(y = prev, x = year_nac)) +
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
    }
  )
}

armar_panel_tendencias <- function(figuras) {
  # En el script original se usa ggarrange con common.legend.
  # Lo hago opcional: si ggpubr no está, podemos devolver una patchwork,
  # pero para mantener lo mismo, intento ggpubr.
  if (!requireNamespace("ggpubr", quietly = TRUE)) {
    stop("Me falta el paquete 'ggpubr' para armar el panel. Instalalo y reintenta.")
  }

  ggpubr::ggarrange(
    plotlist = figuras,
    nrow = 3,
    ncol = 2,
    common.legend = TRUE
  )
}

guardar_png <- function(gg, path_png, width_cm = 20, height_cm = 17, res = 300) {
  # Guardo con ragg si está disponible, porque suele producir PNG muy limpios.
  # Si no está, uso el device por defecto.
  if (requireNamespace("ragg", quietly = TRUE)) {
    ggplot2::ggsave(
      filename = path_png,
      plot = gg,
      res = res,
      width = width_cm,
      height = height_cm,
      units = "cm",
      scaling = 0.90,
      device = ragg::agg_png
    )
  } else {
    ggplot2::ggsave(
      filename = path_png,
      plot = gg,
      res = res,
      width = width_cm,
      height = height_cm,
      units = "cm",
      scaling = 0.90
    )
  }

  path_png
}
