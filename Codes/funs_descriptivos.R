# Funciones para tabla descriptiva

suppressPackageStartupMessages({
  library(dplyr)
  library(vtable)
  library(rio)
})

crear_tabla_descriptiva <- function(data) {
  # Replico la lógica del script original: selecciono columnas y tipifico.
  # Ojo: uso `all_of()` para no romper si el rango `sex:birth_term` no existe.
  # Si alguna columna falta, prefiero que falle rápido y claro.

  # Esta selección intenta respetar exactamente lo que se quiso hacer en el script.
  # Si en tu base `sex` y `birth_term` están bien ubicadas, `sex:birth_term` funciona perfecto.
  data_sel <- data |> select(sex:birth_term)

  data_sel |>
    mutate(
      across(starts_with("HW"), as.factor),
      across(starts_with("birth_"), as.factor)
    ) |>
    vtable::st(
      digits = 1,
      out = "return",
      add.median = TRUE,
      fixed.digits = TRUE,
      simple.kable = FALSE,
      title = "",
      numformat = NA
    ) |>
    data.frame()
}

guardar_tabla_xlsx <- function(tabla, path_xlsx) {
  # Este paso crea un archivo como artefacto del pipeline.
  # En targets, me gusta que la función retorne el path para que quede registrado.
  rio::export(tabla, file = path_xlsx)
  path_xlsx
}
