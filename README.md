# wks_targets_atc26

Laboratorio Workshop ATC 2026: https://atc26.com/

## Presentación

La presentación sobre "Flujo de trabajo reproducible con R y {targets}" está disponible en:

**https://JDConejeros.github.io/wks_targets_atc26/Pres_Targets_RepWFL.html**

### Publicación en GitHub Pages

La presentación se publica automáticamente en GitHub Pages cuando se hace push a la rama `main`. El workflow de GitHub Actions renderiza la presentación y la publica automáticamente.

#### Configuración inicial (solo una vez)

1. Ve a **Settings** → **Pages** en tu repositorio de GitHub
2. En **Source**, selecciona **GitHub Actions**
3. Guarda los cambios

#### Publicación automática

Cada vez que hagas push a `main` con cambios en `Pres_TargetR/`, el workflow:

* Renderiza la presentación automáticamente
* Publica el HTML en GitHub Pages
* La presentación estará disponible en unos minutos

#### Publicación manual

Si necesitas forzar una publicación manual:

1. Ve a **Actions** en tu repositorio
2. Selecciona el workflow **Publish Presentation**
3. Haz clic en **Run workflow** → **Run workflow**

### Renderizar localmente

Para renderizar la presentación localmente:

```bash
cd Pres_TargetR
quarto render Pres_Targets_RepWFL.qmd
```

## Estructura del Proyecto

- `Pres_TargetR/`: Contiene la presentación en formato Quarto RevealJS
  - `Pres_Targets_RepWFL.qmd`: Archivo principal de la presentación
  - `custom.scss`: Estilos personalizados
  - `Images/`: Imágenes utilizadas en la presentación
- `Input/`: Datos de entrada del proyecto
- `.github/workflows/`: Configuración de GitHub Actions para publicación automática

## Pipeline reproducible con {targets}

Además del script de referencia `Codes/code_ref.R` (que NO se borra), dejé un pipeline completo con `{targets}` en `_targets.R`.

La idea es simple: yo corro una vez `tar_make()` y el proyecto genera los mismos productos (figuras, tablas y modelos). Si después cambiás algo (una función, el archivo de datos, etc.), targets recalcula solo lo que corresponde.

### Cómo correr

```r
library(renv)
renv::restore()

library(targets)
tar_make()
```

### Qué produce

- `Output/Figures/Nacimiento_trends.png`
- `Output/Tables/Descriptivos_muestra.xlsx`
- `Output/Models/Resultados_cox.xlsx`
- `Output/Figures/Forest_HW_p90_2d_bin.png`

### Cómo mirar lo que pasó

```r
library(targets)
tar_glimpse()
tar_manifest()
```

### Scripts listos para usar (desde Terminal)

```bash
Rscript Codes/run_targets.R
Rscript Codes/dependencies.R
Rscript Codes/dependencies_from_session.R
```

#### Nota sobre gráficos de dependencias

En macOS, algunas visualizaciones pueden arrastrar paquetes que necesitan compilación (por ejemplo, FORTRAN/gfortran).
Por eso dejé alternativas livianas (`tar_glimpse()` y `tar_manifest()`) para inspeccionar el pipeline sin trabas.
