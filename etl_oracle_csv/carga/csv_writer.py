# IMPORTAMOS PANDAS PARA MANEJAR LOS DATAFRAMES.
import pandas as pd
# IMPORTAMOS JSON PARA MANEJAR LOS MANIFIESTOS EN FORMATO JSON.
import json
# IMPORTAMOS LOGGING PARA REGISTRAR LOS PROCESOS DE CARGA Y GENERACIÓN DE MANIFIESTOS.
import logging
# DESDE PATHLIB IMPORTAMOS Path PARA MANEJAR LAS RUTAS DE LOS ARCHIVOS DE MANERA MÁS SENCILLA Y PORTABLE.
from pathlib import Path
# DESDE DATETIME IMPORTAMOS DATETIME PARA MANEJAR LAS FECHAS Y HORAS.
from datetime import datetime

# CONFIGURAMOS EL LOGGING PARA MOSTRAR INFORMACIÓN EN LA CONSOLA CON UN FORMATO ESPECÍFICO.
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')

# DEFINIMOS LA CLASE CSVWriter QUE SE ENCARGARÁ DE GUARDAR LOS LOTES EN ARCHIVOS
class CSVWriter:
    # Maneja la escritura de archivos CSV y la generación de manifiestos.

    # EL MÉTODO __INIT__ RECIBE LA RUTA DE SALIDA DONDE SE GUARDARÁN LOS ARCHIVOS CSV Y LOS MANIFIESTOS.
    def __init__(self, output_path: Path):
        # ASIGNAMOS LA RUTA DE SALIDA A UN ATRIBUTO DE LA CLASE PARA USARLO EN LOS MÉTODOS POSTERIORES.
        self.output_path = output_path

    # EL MÉTODO GUARDAR_LOTE RECIBE UN DATAFRAME, EL NOMBRE DE LA TABLA Y EL NÚMERO DE LOTE PARA GUARDARLO EN UN ARCHIVO CSV.
    def guardar_lote(self, df: pd.DataFrame, nombre_tabla: str, numero_lote: int) -> str:
        # Guarda un lote en CSV y retorna la ruta del archivo.
        
        # TABLA_DIR ES LA RUTA DONDE SE GUARDARÁN LOS ARCHIVOS CSV DE LA TABLA ESPECÍFICA. SE CREA SI NO EXISTE.
        tabla_dir = self.output_path / nombre_tabla.lower()
        # TABLA_DIR.MKDIR CREA EL DIRECTORIO Y SUS PADRES SI NO EXISTEN, EVITANDO ERRORES SI LA RUTA YA EXISTE.
        tabla_dir.mkdir(parents=True, exist_ok=True)
        
        # GENERAMOS UN NOMBRE DE ARCHIVO ÚNICO UTILIZANDO EL NOMBRE DE LA TABLA, EL NÚMERO DE LOTE 
        # Y UN TIMESTAMP PARA EVITAR SOBRESCRIBIR ARCHIVOS.
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        # EL NOMBRE DEL ARCHIVO SE CONSTRUYE EN MINÚSCULAS PARA MANTENER CONSISTENCIA Y 
        # EVITAR PROBLEMAS DE CASE SENSITIVITY EN DIFERENTES SISTEMAS OPERATIVOS.
        file_name = f"{nombre_tabla.lower()}_lote_{numero_lote}_{timestamp}.csv"
        # FULL_PATH ES LA RUTA COMPLETA DONDE SE GUARDARÁ EL ARCHIVO CSV, COMBINANDO EL 
        # DIRECTORIO DE LA TABLA Y EL NOMBRE DEL ARCHIVO.
        full_path = tabla_dir / file_name
        
        # GUARDAMOS EL DATAFRAME EN UN ARCHIVO CSV UTILIZANDO EL MÉTODO TO_CSV DE PANDAS, SIN INCLUIR EL ÍNDICE Y CON CODIFICACIÓN UTF-8. 
        df.to_csv(full_path, index=False, encoding='utf-8')
        # REGISTRAMOS EN EL LOG QUE EL LOTE HA SIDO GUARDADO CORRECTAMENTE, INCLUYENDO EL NOMBRE DE LA TABLA Y EL NÚMERO DE LOTE.
        logging.info(f"Lote {numero_lote} de {nombre_tabla} guardado en: {full_path.name}")
        
        # RETORNAMOS LA RUTA COMPLETA DEL ARCHIVO GUARDADO COMO UNA CADENA DE TEXTO PARA USARLA EN EL MANIFIESTO O EN PROCESOS POSTERIORES.
        return str(full_path)

    # EL MÉTODO GENERAR_MANIFIESTO RECIBE EL NOMBRE DE LA TABLA, EL TOTAL DE FILAS MIGRADAS Y LA 
    # LISTA DE ARCHIVOS GENERADOS PARA CREAR UN MANIFIESTO EN FORMATO JSON.
    def generar_manifiesto(self, nombre_tabla: str, total_filas: int, archivos: list):
        # Genera un archivo JSON con el resumen de la carga de la tabla.

        # CREAMOS UN DICCIONARIO LLAMADO MANIFIESTO QUE CONTIENE LA INFORMACIÓN RELEVANTE SOBRE LA CARGA DE LA TABLA,
        # INCLUYENDO EL NOMBRE DE LA TABLA, LA FECHA DE MIGRACIÓN, EL TOTAL DE REGISTROS MIGRADOS, 
        # LA CANTIDAD DE ARCHIVOS GENERADOS, LAS RUTAS DE LOS ARCHIVOS Y EL ESTADO DE LA MIGRACIÓN. 
        # ESTA ESTRUCTURA PERMITE TENER UN REGISTRO DETALLADO DE CADA PROCESO DE CARGA PARA FUTURAS REFERENCIAS O AUDITORÍAS. 
        manifiesto = {            
            "tabla": nombre_tabla,
            "fecha_migracion": datetime.now().isoformat(),
            "total_registros_migrados": total_filas,
            "cantidad_archivos_generados": len(archivos),
            "rutas_archivos": archivos,
            "estado": "EXITOSO"
        }
        
        # GENERAMOS LA RUTA DONDE SE GUARDARÁ EL MANIFIESTO, UTILIZANDO EL NOMBRE DE LA TABLA EN MINÚSCULAS PARA MANTENER CONSISTENCIA.
        manifiesto_path = self.output_path / nombre_tabla.lower() / f"manifiesto_{nombre_tabla.lower()}.json"

        # GUARDAMOS EL DICCIONARIO MANIFIESTO EN UN ARCHIVO JSON UTILIZANDO EL MÉTODO DUMP DE LA LIBRERÍA JSON, 
        # CON UNA SANGRÍA DE 4 ESPACIOS PARA MEJORAR LA LEGIBILIDAD Y ASEGURANDO QUE LOS CARACTERES UNICODE SE MUESTREN CORRECTAMENTE.
        with open(manifiesto_path, 'w', encoding='utf-8') as f:
            # EL MANIFIESTO SE GUARDA EN FORMATO JSON, LO QUE PERMITE UNA FÁCIL LECTURA Y PROCESAMIENTO POSTERIOR, 
            # YA SEA PARA AUDITORÍAS, REPORTES O INTEGRACIONES CON OTROS SISTEMAS.
            json.dump(manifiesto, f, indent=4)
            
        # REGISTRAMOS EN EL LOG QUE EL MANIFIESTO HA SIDO GENERADO CORRECTAMENTE, INCLUYENDO EL NOMBRE DE LA TABLA Y LA RUTA DEL MANIFIESTO.    
        logging.info(f"Manifiesto generado para {nombre_tabla} en: {manifiesto_path.name}")