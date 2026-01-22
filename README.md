# Flujo de trabajo reproducible con R y {targets}

**Laboratorio Abre Tu Ciencia - ATC 2026**

Este repositorio contiene los materiales del laboratorio sobre construcción de flujos de trabajo reproducibles usando el paquete `{targets}` de R. El objetivo es aprender a automatizar análisis complejos, gestionar dependencias entre pasos y mantener trazabilidad completa de los procesos de investigación.

🔗 [Workshop ATC 2026](https://atc26.com/)

## 📊 Presentación

La presentación completa del laboratorio está disponible en:

**👉 [Ver presentación](https://jdconejeros.github.io/wks_targets_atc26/Pres_Targets_RepWFL.html#/title-slide)**

### Publicación en GitHub Pages

La presentación se publica automáticamente en GitHub Pages cuando se hace push a la rama `main`. El workflow de GitHub Actions publica el HTML automáticamente.

#### Configuración inicial (solo una vez)

1. Ve a **Settings** → **Pages** en tu repositorio de GitHub
2. En **Source**, selecciona **GitHub Actions**
3. Guarda los cambios

#### Publicación automática

Cada vez que hagas push a `main` con cambios en `Pres_TargetR/`, el workflow publica el HTML en GitHub Pages automáticamente.

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

## 🎯 Pipeline reproducible con {targets}

En este proyecto transformé un análisis tradicional de R en un pipeline reproducible usando `{targets}`. La idea es simple: corro una vez `tar_make()` y el proyecto genera todos los productos (figuras, tablas y modelos). Si después cambio algo (una función, el archivo de datos, etc.), `targets` recalcula automáticamente solo lo que corresponde, ahorrando tiempo y asegurando reproducibilidad.

### ¿Cómo funciona {targets}?

`{targets}` funciona como un sistema de construcción inteligente para análisis de datos. Te explico cómo lo estructuré en este proyecto:

1. **Definición de targets**: Cada paso del análisis (cargar datos, crear variables, generar gráficos, ajustar modelos) es un "target" que defino en `_targets.R`. Cada target tiene un nombre y una función que lo produce.

2. **Dependencias automáticas**: `targets` detecta automáticamente qué targets dependen de otros. Por ejemplo, si cambio una función que crea variables, solo se recalcularán los targets que usan esas variables, no todo el pipeline.

3. **Cache inteligente**: Los resultados intermedios se guardan en una caché. Si nada cambió desde la última ejecución, `targets` simplemente carga los resultados guardados en lugar de recalcular.

4. **Trazabilidad**: Cada target guarda metadatos sobre cuándo se ejecutó, qué código usó, y qué dependencias tenía. Esto hace que el análisis sea completamente reproducible.

### Estructura del pipeline

El pipeline está definido en `_targets.R` y sigue este flujo lógico:

```
1. Preparación
   ├── Crear carpetas de salida (Figures, Tables, Models)
   └── Cargar datos desde Input/data/

2. Procesamiento de datos
   ├── Cargar datos crudos (nacimientos_raw)
   └── Crear variables de interés (nacimientos)
       └── Variables de gestación (preterm, very_preterm, etc.)

3. Análisis descriptivo
   ├── Tabla de tendencias (tendencias_tabla)
   ├── Figuras de tendencias (tendencias_figuras)
   └── Panel final de tendencias (fig_tendencias_png)

4. Tablas descriptivas
   ├── Crear tabla descriptiva (descriptivos_tabla)
   └── Guardar en Excel (descriptivos_xlsx)

5. Modelos de supervivencia
   ├── Definir fórmula del modelo Cox
   ├── Ajustar modelo (modelo_cox)
   ├── Extraer resultados (modelo_cox_resultados)
   ├── Guardar resultados (modelo_xlsx)
   └── Crear figura forest plot (modelo_fig_png)
```

### Cómo ejecutar el pipeline

#### Paso 1: Restaurar el entorno de R

Primero, necesitas restaurar los paquetes con las versiones exactas que usé. Este proyecto usa `renv` para gestionar las dependencias:

```r
# Si renv no está instalado
install.packages("renv")

# Restaurar todos los paquetes con las versiones exactas
library(renv)
renv::restore()
```

Esto instalará automáticamente todos los paquetes necesarios en las versiones exactas que usé para desarrollar este proyecto.

#### Paso 2: Ejecutar el pipeline

Una vez restaurado el entorno, ejecuto el pipeline completo:

```r
library(targets)
tar_make()
```

Esto ejecutará todos los targets necesarios. La primera vez puede tardar un poco, pero las siguientes ejecuciones serán mucho más rápidas porque `targets` solo recalculará lo que cambió.

#### Paso 3: Inspeccionar los resultados

Para ver qué targets se ejecutaron y cuáles están actualizados:

```r
library(targets)

# Vista rápida del estado del pipeline
tar_glimpse()

# Lista completa de todos los targets definidos
tar_manifest()

# Ver qué targets están desactualizados (necesitan recalcularse)
tar_outdated()
```

### Scripts auxiliares

También dejé algunos scripts listos para usar desde la terminal:

```bash
# Ejecutar el pipeline completo
Rscript Codes/run_targets.R

# Generar gráfico de dependencias (puede requerir paquetes adicionales)
Rscript Codes/dependencies.R

# Generar dependencias desde la sesión actual de R
Rscript Codes/dependencies_from_session.R
```

### Qué produce el pipeline

Al ejecutar `tar_make()`, el pipeline genera automáticamente:

- **`Output/Figures/Nacimiento_trends.png`**: Panel con gráficos de tendencias de nacimientos
- **`Output/Tables/Descriptivos_muestra.xlsx`**: Tabla descriptiva de la muestra
- **`Output/Models/Resultados_cox.xlsx`**: Resultados del modelo de regresión de Cox
- **`Output/Figures/Forest_HW_p90_2d_bin.png`**: Forest plot del predictor principal

### Ventajas de usar {targets}

1. **Eficiencia**: Solo recalcula lo necesario, ahorrando tiempo en ejecuciones repetidas
2. **Reproducibilidad**: Cada paso está documentado y versionado
3. **Escalabilidad**: Fácil agregar nuevos análisis sin romper lo existente
4. **Debugging**: Si algo falla, sabes exactamente qué target causó el problema
5. **Paralelización**: `targets` puede ejecutar targets independientes en paralelo automáticamente

## 📦 Paquetes y versiones

Este proyecto usa las siguientes versiones de paquetes (gestionadas con `renv`):

### Paquetes principales

- **R**: 4.5.2
- **targets**: 1.11.4
- **dplyr**: 1.1.4
- **tidyr**: 1.3.2
- **purrr**: 1.2.1
- **rio**: 1.2.4
- **ggplot2**: 4.0.1
- **vtable**: 1.4.8
- **survival**: 3.8-3
- **broom**: 1.0.11
- **ggpubr**: 0.6.2

### Cómo usar las mismas versiones

Este proyecto usa `renv` para garantizar que uses exactamente las mismas versiones de los paquetes. El archivo `renv.lock` contiene todas las versiones exactas de los paquetes y sus dependencias.

**Para restaurar el entorno completo:**

```r
# Instalar renv si no lo tienes
install.packages("renv")

# Restaurar todas las versiones exactas
library(renv)
renv::restore()
```

Esto instalará automáticamente todos los paquetes en las versiones exactas especificadas en `renv.lock`. Si algún paquete ya está instalado en una versión diferente, `renv` te preguntará si quieres actualizarlo.

**Para ver qué paquetes están instalados:**

```r
renv::status()
```

**Para actualizar renv.lock después de instalar nuevos paquetes:**

```r
renv::snapshot()
```

### Nota sobre visualizaciones de dependencias

En macOS, algunas visualizaciones interactivas (como `tar_visnetwork()`) pueden requerir paquetes que necesitan compilación (por ejemplo, FORTRAN/gfortran). Por eso dejé alternativas livianas como `tar_glimpse()` y `tar_manifest()` para inspeccionar el pipeline sin complicaciones.

## 📁 Estructura del Proyecto

```
wks_targets_atc26/
├── _targets.R              # Definición del pipeline
├── _targets/               # Cache de targets (no versionar)
├── Codes/                  # Scripts y funciones
│   ├── funs_data.R         # Funciones para cargar datos
│   ├── funs_descriptivos.R # Funciones para tablas descriptivas
│   ├── funs_figuras.R      # Funciones para crear gráficos
│   ├── funs_modelos.R      # Funciones para modelos estadísticos
│   └── run_targets.R       # Script para ejecutar el pipeline
├── Input/                  # Datos de entrada
│   └── data/               # Archivos de datos
├── Output/                 # Resultados generados
│   ├── Figures/            # Gráficos
│   ├── Tables/             # Tablas
│   └── Models/             # Resultados de modelos
├── Pres_TargetR/           # Presentación del laboratorio
│   ├── Pres_Targets_RepWFL.qmd
│   └── Images/
├── renv.lock               # Versiones exactas de paquetes
└── README.md               # Este archivo
```

## 🔗 Recursos adicionales

- [Documentación oficial de {targets}](https://books.ropensci.org/targets/)
- [Manual de referencia](https://docs.ropensci.org/targets/)
- [Ecosistema de targets (targetopia)](https://wlandau.github.io/targetopia/packages.html)

## 👤 Autor

**José Daniel Conejeros, Msc.**  
Investigador Joven  
Escuela de Gobierno & College UC  
jdconejeros@uc.cl

---

_Este proyecto fue desarrollado como parte del Laboratorio "Flujo de trabajo reproducible con R y {targets}" del Workshop Abre Tu Ciencia 2026._
