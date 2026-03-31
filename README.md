# Taller de Migración de Datos - Hospital (Oracle a CSV)

# Pipeline ETL de Migración Hospitalaria (Oracle 21c → CSV)

Este proyecto implementa un sistema de migración de datos robusto y profesional utilizando Python. Está diseñado para extraer información de un sistema hospitalario en Oracle (~548,000 registros), aplicar reglas de limpieza de negocio y generar archivos CSV segmentados con sus respectivos manifiestos de control.

## Características Principales
- **Arquitectura Modular:** Separación clara entre Extracción, Transformación y Carga (ETL).
- **Resiliencia (Checkpointing):** Registro en SQLite para reanudar la migración ante fallos.
- **Procesamiento por Lotes (Chunking):** Uso eficiente de memoria para manejar grandes volúmenes de datos.
- **Calidad de Datos:** Perfilado de nulos y limpieza automatizada con Pandas.
- **Pruebas Unitarias:** Cobertura de lógica de negocio mediante Pytest.

## Estructura del Proyecto
```text
etl_oracle_csv/
├── config/         # Configuraciones YAML y parámetros globales
├── extraccion/     # Conexión Oracle y control de checkpoints (SQLite)
├── transformacion/ # Limpieza de datos y perfilador de calidad
├── carga/          # Escritura de CSV y generación de manifiestos JSON
├── tests/          # Pruebas unitarias
└── pipeline.py     # Orquestador principal del proceso

## Requisitos Previos
- Python 3.14 (Entorno virtual recomendado).
- Docker Desktop (Para la base de datos Oracle).
- Dependencias: Listadas en requirements.txt. 

## Configuración y Ejecución
- Levantar la Infraestructura:
Asegúrate de que el script oracle_hospital_final.sql esté en la carpeta scripts/.
Terminal:
docker compose up -d

## Preparar el Entorno:
Terminal:
python3.14 -m venv venv
source venv/bin/activate
pip install -r etl_oracle_csv/requirements.txt

## Ejecutar el Pipeline Completo:
Terminal:
python etl_oracle_csv/pipeline.py

## Ejecutar Pruebas Unitarias:
Terminal:
export PYTHONPATH=$PYTHONPATH:$(pwd)/etl_oracle_csv
pytest etl_oracle_csv/tests/

## Salida de Datos
Gemini dijo

¡Excelente trabajo, Gariasa! Ver ese 3 passed en la terminal es la prueba de que tu código no solo funciona, sino que es confiable y fácil de mantener. Has completado con éxito todos los requerimientos técnicos del nivel Intermedio-Avanzado.

Para cerrar con broche de oro y que tu líder (o cualquier reclutador en GitHub) pueda entender y ejecutar tu proyecto fácilmente, vamos a crear el README.md final. Este documento es la "cara" de tu repositorio.
El README.md Final para tu Portafolio

Asegúrate de estar en la raíz de tu proyecto taller-migracion-hospital. Abre el archivo README.md y pega el siguiente contenido estructurado:
Markdown

# Pipeline ETL de Migración Hospitalaria (Oracle 21c → CSV)

Este proyecto implementa un sistema de migración de datos robusto y profesional utilizando Python. Está diseñado para extraer información de un sistema hospitalario en Oracle (~548,000 registros), aplicar reglas de limpieza de negocio y generar archivos CSV segmentados con sus respectivos manifiestos de control.

## 🚀 Características Principales
- **Arquitectura Modular:** Separación clara entre Extracción, Transformación y Carga (ETL).
- **Resiliencia (Checkpointing):** Registro en SQLite para reanudar la migración ante fallos.
- **Procesamiento por Lotes (Chunking):** Uso eficiente de memoria para manejar grandes volúmenes de datos.
- **Calidad de Datos:** Perfilado de nulos y limpieza automatizada con Pandas.
- **Pruebas Unitarias:** Cobertura de lógica de negocio mediante Pytest.

## 🛠️ Estructura del Proyecto
```text
etl_oracle_csv/
├── config/         # Configuraciones YAML y parámetros globales
├── extraccion/     # Conexión Oracle y control de checkpoints (SQLite)
├── transformacion/ # Limpieza de datos y perfilador de calidad
├── carga/          # Escritura de CSV y generación de manifiestos JSON
├── tests/          # Pruebas unitarias
└── pipeline.py     # Orquestador principal del proceso

📋 Requisitos Previos

    Python 3.14 (Entorno virtual recomendado).

    Docker Desktop (Para la base de datos Oracle).

    Dependencias: Listadas en requirements.txt.

⚙️ Configuración y Ejecución

    Levantar la Infraestructura:
    Asegúrate de que el script oracle_hospital_final.sql esté en la carpeta scripts/.
    Bash

    docker compose up -d

    Preparar el Entorno:
    Bash

    python3.14 -m venv venv
    source venv/bin/activate
    pip install -r etl_oracle_csv/requirements.txt

    Ejecutar el Pipeline Completo:
    Bash

    python etl_oracle_csv/pipeline.py

    Ejecutar Pruebas Unitarias:
    Bash

    export PYTHONPATH=$PYTHONPATH:$(pwd)/etl_oracle_csv
    pytest etl_oracle_csv/tests/

📊 Salida de Datos:
Los resultados se almacenan en la carpeta output_csv/, organizados por subcarpetas de tabla. Cada tabla incluye:
    Archivos CSV por lotes.
    Un archivo manifiesto_tabla.json con el resumen de la migración y conteos finales.