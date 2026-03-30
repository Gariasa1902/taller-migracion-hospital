# IMPORTAMOS PANDAS PARA EL MANEJO DE DATAFRAMES.
import pandas as pd
# IMPORTAMOS LOGGING PARA REGISTRAR INFORMACIÓN DURANTE LA EJECUCIÓN.
import logging
# IMPORTAMOS JSON Y PATHLIB PARA GUARDAR LOS REPORTES DE CALIDAD EN ARCHIVOS JSON.
import json
# DESDE PATHLIB IMPORTAMOS Path PARA MANEJAR RUTAS DE ARCHIVOS DE MANERA MÁS SENCILLA Y PORTABLE.
from pathlib import Path

# CLASS PERFILADORDATOS: ESTA CLASE SE ENCARGA DE GENERAR REPORTES ESTADÍSTICOS Y DE CALIDAD SOBRE LOS DATAFRAMES.
class PerfiladorDatos:
    # Genera reportes estadísticos y de calidad sobre los DataFrames.

    # MÉTODO ESTÁTICO PARA GENERAR UN REPORTE DE CALIDAD DE LOS DATOS, ANALIZANDO NULOS Y TIPOS DE DATOS.
    @staticmethod
    # ESTE MÉTODO RECIBE UN DATAFRAME Y EL NOMBRE DE LA TABLA, Y DEVUELVE UN DICCIONARIO CON EL REPORTE DE CALIDAD.
    def generar_reporte_calidad(df: pd.DataFrame, nombre_tabla: str) -> dict:
        # Analiza nulos y tipos de datos de un lote.

        # CREA UN DICCIONARIO CON EL NOMBRE DE LA TABLA, EL TOTAL DE REGISTROS, EL ANÁLISIS DE NULOS Y LOS TIPOS DE DATOS.
        reporte = {
            "tabla": nombre_tabla,
            "total_registros": len(df),
            "analisis_nulos": df.isnull().sum().to_dict(),
            "tipos_datos": df.dtypes.astype(str).to_dict()
        }
        # REGISTRA UN MENSAJE DE INFORMACIÓN INDICANDO QUE SE HA GENERADO EL REPORTE DE CALIDAD PARA EL LOTE DE LA TABLA ESPECIFICADA.
        logging.info(f"Reporte de calidad generado para el lote de {nombre_tabla}")
        # DEVUELVE EL DICCIONARIO CON EL REPORTE DE CALIDAD.
        return reporte

    # MÉTODO ESTÁTICO PARA GUARDAR EL REPORTE DE CALIDAD EN UN ARCHIVO JSON EN LA RUTA ESPECIFICADA.
    @staticmethod
    # ESTE MÉTODO RECIBE UN DICCIONARIO CON EL REPORTE DE CALIDAD Y UNA RUTA DE SALIDA, Y GUARDA EL REPORTE EN UN ARCHIVO JSON.
    def guardar_reporte(reporte: dict, output_path: Path):
        # Guarda el reporte de calidad en un archivo JSON.
        output_path.mkdir(parents=True, exist_ok=True)
        # CREA UNA RUTA PARA EL ARCHIVO DE REPORTE, UTILIZANDO EL NOMBRE DE LA TABLA EN MINÚSCULAS Y EL FORMATO JSON.
        archivo_reporte = output_path / f"reporte_calidad_{reporte['tabla'].lower()}.json"
        
        # ABRE EL ARCHIVO DE REPORTE EN MODO ESCRITURA Y CODIFICACIÓN UTF-8, Y ESCRIBE EL 
        # DICCIONARIO DEL REPORTE EN FORMATO JSON CON UNA IDENTACIÓN DE 4 ESPACIOS.
        with open(archivo_reporte, 'w', encoding='utf-8') as f:
            # UTILIZA LA FUNCIÓN JSON.DUMP PARA ESCRIBIR EL DICCIONARIO DEL REPORTE EN EL ARCHIVO JSON, 
            # CON UNA IDENTACIÓN DE 4 ESPACIOS PARA MEJORAR LA LEGIBILIDAD.
            json.dump(reporte, f, indent=4)