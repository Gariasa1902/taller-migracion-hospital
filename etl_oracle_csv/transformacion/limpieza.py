import pandas as pd
import logging

# Configuración de logging para rastrear qué estamos limpiando
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')

class LimpiadorDatos:
    """
    Contiene las reglas de negocio para transformar y limpiar 
    los datos extraídos de Oracle antes de convertirlos a CSV.
    """

    @staticmethod
    def limpiar_pacientes(df: pd.DataFrame) -> pd.DataFrame:
        """Aplica reglas de calidad a la tabla PACIENTES."""
        if df.empty:
            return df
            
        logging.info("Transformando lote de PACIENTES...")
        
        # 1. Estandarizar nombres y apellidos a MAYÚSCULAS
        for col in ['nombre', 'apellido']:
            if col in df.columns:
                df[col] = df[col].astype(str).str.upper().str.strip()

        # 2. Limpieza de Teléfono: Dejar solo números (quitar espacios, guiones, etc.)
        if 'telefono' in df.columns:
            df['telefono'] = df['telefono'].fillna('').astype(str)
            # Usamos una expresión regular para mantener solo dígitos \D = todo lo que NO sea dígito
            df['telefono'] = df['telefono'].str.replace(r'\D', '', regex=True)

        # 3. Estandarizar Sexo: Solo permitimos M, F o X (para nulos o errores)
        if 'sexo' in df.columns:
            df['sexo'] = df['sexo'].fillna('X').astype(str).str.upper()
            # Si el valor no está en nuestra lista permitida, lo volvemos X
            df.loc[~df['sexo'].isin(['M', 'F', 'X']), 'sexo'] = 'X'

        return df

    @staticmethod
    def limpiar_medicos(df: pd.DataFrame) -> pd.DataFrame:
        """Aplica reglas de calidad a la tabla MEDICOS."""
        if df.empty:
            return df

        logging.info("Transformando lote de MEDICOS...")

        # 1. Nombres de médicos en MAYÚSCULAS
        for col in ['nombre', 'apellido']:
            if col in df.columns:
                df[col] = df[col].astype(str).str.upper().str.strip()

        # 2. Validación básica de Email: Si no tiene '@', lo dejamos vacío (None)
        if 'email' in df.columns:
            mask_invalido = ~df['email'].astype(str).str.contains('@', na=False)
            df.loc[mask_invalido, 'email'] = None

        return df