# Script corto para correr el pipeline con {targets}
#
# Yo lo uso como "botón" desde la consola:
#   Rscript Codes/run_targets.R
#
# Si querés, también podés correr estas mismas líneas dentro de RStudio/Positron.

suppressPackageStartupMessages({
  library(targets)
})

# Construyo todo lo que falte.
# Si nada cambió, targets no recalcula y termina rapidito.
tar_make()

# Si quiero “mirar” el workflow sin pelearme con visNetwork,
# uso herramientas livianas:
targets::tar_glimpse()
targets::tar_manifest()

# Y si quiero el grafo como objeto (sin intentar abrir un visor), uso tar_network().
# Esto me sirve para inspeccionar dependencias entre targets, o para guardar algo después.
net <- targets::tar_network()
net
