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
