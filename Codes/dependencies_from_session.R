# Script para ver versiones instaladas en TU sesión
#
# Yo lo uso cuando quiero saber:
# - "¿Qué versión de dplyr estoy usando ahora mismo?"
# - "¿Qué R versión corre en esta máquina?"
#
# Tip:
#   Rscript Codes/dependencies_from_session.R

# Devuelvo un objeto (en vez de imprimirlo todo).
# Si lo corrés con Rscript, igual se va a imprimir algo, pero será más acotado.

pkgs <- installed.packages()[, c("Package", "Version")]

out <- list(
  r_version = R.version.string,
  packages = as.data.frame(pkgs, stringsAsFactors = FALSE)
)

out
