# 🏪 Data Warehouse Retail Analytics (JSON)

**Autor:** Bruno San Martín  
**Repositorio:** [GitHub](#)

---

## Descripción

Este proyecto implementa un Data Warehouse para una tienda retail utilizando archivos JSON como fuente de datos. Se aplica un modelo dimensional (Kimball), se desarrollan procesos ETL en Python y se realizan análisis avanzados mediante consultas SQL sobre SQLite.

---

## 📁 Estructura del Proyecto

```
dw-json-retail-analytics/
├── data/         # Datos crudos y transformados (JSON)
├── etl/          # Scripts ETL (extracción, transformación y carga)
├── models/       # Modelo dimensional (diagramas, SQL DDL)
├── queries/      # Consultas SQL analíticas
├── utils/        # Funciones auxiliares y utilidades
├── docs/         # Documentación adicional y diagramas
├── notebooks/    # Exploraciones y pruebas
├── requirements.txt  # Dependencias del proyecto
└── .gitignore        # Exclusiones de control de versiones
```
- **data/**: Almacena los archivos JSON originales y los datos ya transformados.
- **etl/**: Scripts para extraer, transformar y cargar los datos al Data Warehouse.
- **models/**: Definición del modelo dimensional, diagramas y scripts SQL para la estructura.
- **queries/**: Consultas SQL para análisis y reportes.
- **utils/**: Funciones y utilidades de apoyo para el proyecto.
- **docs/**: Documentación técnica y funcional adicional.
- **notebooks/**: Jupyter Notebooks para exploración, pruebas y prototipos.
- **requirements.txt**: Lista de dependencias necesarias para el entorno Python.
- **.gitignore**: Archivos y carpetas excluidos del control de versiones.

---

## 🚀 Instalación Rápida

1. **Clona el repositorio**
    ```bash
    git clone <URL_DEL_REPO>
    cd dw-json-retail-analytics
    ```

2. **Crea y activa el entorno virtual**
    ```bash
    python3 -m venv .venv
    source .venv/bin/activate
    ```

3. **Instala las dependencias**
    ```bash
    pip install -r requirements.txt
    ```

---

## 🛠️ Uso

- Ejecuta los scripts ETL desde la carpeta `etl/` para procesar los datos.
- Consulta el modelo dimensional en `models/`.
- Realiza análisis ejecutando las consultas SQL en `queries/`.
- Explora y prueba ideas en la documentacion de `notebooks/`.

---

## ✅ Checklist Sprint 0

- [x] Repositorio clonado y entorno virtual creado
- [x] Dependencias instaladas
- [x] Estructura de carpetas generada
- [x] `.gitignore` y `README.md` configurados

---

## 🧠 Buenas Prácticas Basadas en el libro CleanCode

- Separación clara de responsabilidades por carpeta
- Uso de entorno virtual para aislar dependencias
- Código reproducible y versionado
- Documentación clara y mantenible

---

## 📅  Pasos realizando scrum

1. **Sprint 1:** Diseño del modelo dimensional (Kimball)
2. **Sprint 2:** Desarrollo de procesos ETL
3. **Sprint 3:** Análisis y visualización de datos

---
