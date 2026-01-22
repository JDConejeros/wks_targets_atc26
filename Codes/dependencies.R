# Script para revisar dependencias y versiones
#
# Yo lo uso para responder preguntas tipo:
# - "¿Qué paquetes usa este proyecto?"
# - "¿Con qué versiones está congelado?"
#
# Tip:
#   Rscript Codes/dependencies.R

suppressPackageStartupMessages({
  library(renv)
  library(jsonlite)
})

# 1) Qué paquetes detecta renv que usa el proyecto (a partir del código)
# Esto NO instala nada: solo inspecciona archivos.
deps <- renv::dependencies()

# 2) Qué versiones quedaron guardadas (si existe renv.lock)
# renv.lock es un JSON, así que lo puedo leer con jsonlite sin depender de funciones internas.
lock <- if (file.exists("renv.lock")) jsonlite::read_json("renv.lock", simplifyVector = TRUE) else NULL

# Devuelvo una lista para poder inspeccionarla desde R sin imprimir demasiadas páginas.
list(
  dependencies_detected = deps,
  lockfile = lock
)
