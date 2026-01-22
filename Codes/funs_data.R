# Funciones para cargar y preparar datos
#
# La idea es que el pipeline (targets) llame funciones chicas y claras.
# Así, si algo cambia en los datos, targets vuelve a correr solo lo necesario.

suppressPackageStartupMessages({
  library(dplyr)
  library(rio)
})

cargar_datos_nacimientos <- function(path_rdata) {
  # Leo el .RData con rio, que me devuelve el objeto que esté guardado adentro.
  # Si el archivo cambia, targets lo detecta y vuelve a correr este paso.
  rio::import(path_rdata)
}

crear_outcomes_gestacionales <- function(data) {
  # Acá genero las variables de interés (outcomes) tal como en el código de referencia.
  # Lo dejo en una función para que sea fácil de testear y re-usar.
  data |>
    mutate(
      birth_preterm = if_else(weeks < 37, 1, 0),
      birth_very_preterm = if_else(weeks >= 28 & weeks < 32, 1, 0),
      birth_moderately_preterm = if_else(weeks >= 32 & weeks < 33, 1, 0),
      birth_late_preterm = if_else(weeks >= 34 & weeks < 37, 1, 0),
      birth_term = if_else(weeks >= 37 & weeks < 42, 1, 0)
    )
}
