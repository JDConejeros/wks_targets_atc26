# Pipeline targets para este proyecto
#
# Acá transformé el flujo de `Codes/code_ref.R` a targets.
# Mi idea es que puedas correr TODO con `targets::tar_make()`
# y que el sistema recalcule solo lo que cambió.

suppressPackageStartupMessages({
  library(targets)
})

# Acá declaro paquetes que se van a usar en los targets.
# Ojo: no los cargo "por costumbre". Los declaro para que targets
# se encargue de tenerlos disponibles al correr cada target.
# (Si falta alguno, vas a ver el error y lo instalas una vez.)

tar_option_set(
  packages = c(
    "dplyr",
    "tidyr",
    "purrr",
    "rio",
    "ggplot2",
    "vtable",
    "survival",
    "broom",
    "ggpubr"
  ),
  format = "rds",
  memory = "transient",
  garbage_collection = TRUE
)

# Cargo mis funciones (las dejé en Codes/ para que conviva con tu `code_ref.R`).
# Si editás alguna función, targets detecta el cambio y actualiza lo necesario.
source("Codes/funs_data.R")
source("Codes/funs_figuras.R")
source("Codes/funs_descriptivos.R")
source("Codes/funs_modelos.R")

# Un detalle: no meto `Sys.setlocale()` acá porque puede ser frágil
# según el sistema operativo. Si lo necesitas para un reporte específico,
# lo podemos agregar después donde haga falta.

list(
  # --- Carpetas de salida ---
  # Las creo al inicio para que los targets que guardan archivos no fallen.
  tar_target(
    dir_output_figures,
    {
      dir.create("Output/Figures", recursive = TRUE, showWarnings = FALSE)
      "Output/Figures"
    }
  ),
  tar_target(
    dir_output_tables,
    {
      dir.create("Output/Tables", recursive = TRUE, showWarnings = FALSE)
      "Output/Tables"
    }
  ),
  tar_target(
    dir_output_models,
    {
      dir.create("Output/Models", recursive = TRUE, showWarnings = FALSE)
      "Output/Models"
    }
  ),

  # --- Entradas (rutas como targets) ---
  tar_target(
    path_datos,
    "Input/data/Nacimientos_Santiago_muestra10_1992_2020.RData",
    format = "file"
  ),

  # --- Datos ---
  tar_target(
    nacimientos_raw,
    cargar_datos_nacimientos(path_datos)
  ),
  tar_target(
    nacimientos,
    crear_outcomes_gestacionales(nacimientos_raw)
  ),

  # --- Figura de tendencias ---
  tar_target(
    tendencias_tabla,
    crear_tabla_tendencias(nacimientos)
  ),
  tar_target(
    tendencias_figuras,
    crear_figuras_tendencias(tendencias_tabla)
  ),
  tar_target(
    tendencias_panel,
    armar_panel_tendencias(tendencias_figuras)
  ),
  tar_target(
    fig_tendencias_png,
    {
      dir_output_figures
      guardar_png(tendencias_panel, "Output/Figures/Nacimiento_trends.png")
    },
    format = "file"
  ),

  # --- Tabla descriptiva ---
  tar_target(
    descriptivos_tabla,
    crear_tabla_descriptiva(nacimientos)
  ),
  tar_target(
    descriptivos_xlsx,
    {
      dir_output_tables
      guardar_tabla_xlsx(descriptivos_tabla, "Output/Tables/Descriptivos_muestra.xlsx")
    },
    format = "file"
  ),

  # --- Modelo Cox ---
  tar_target(cox_dependent, "birth_preterm"),
  tar_target(cox_predictor, "HW_p90_2d_bin"),
  tar_target(
    formula_cox,
    armar_formula_cox(dependent = cox_dependent, predictor = cox_predictor)
  ),
  tar_target(
    modelo_cox,
    ajustar_cox(nacimientos, formula_cox)
  ),
  tar_target(
    modelo_cox_resultados,
    extraer_resultados_cox(modelo_cox)
  ),
  tar_target(
    modelo_xlsx,
    {
      dir_output_models
      guardar_resultados_xlsx(modelo_cox_resultados, "Output/Models/Resultados_cox.xlsx")
    },
    format = "file"
  ),
  tar_target(
    modelo_fig,
    figura_forest_predictor(modelo_cox_resultados, predictor = cox_predictor)
  ),
  tar_target(
    modelo_fig_png,
    {
      dir_output_figures
      guardar_png(
        modelo_fig,
        "Output/Figures/Forest_HW_p90_2d_bin.png",
        width_cm = 16,
        height_cm = 8
      )
    },
    format = "file"
  )
)
