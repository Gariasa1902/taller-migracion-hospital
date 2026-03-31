# IMPORTAMOS PYTEST PARA REALIZAR LAS PRUEBAS UNITARIAS. 
import pytest
# IMPORTAMOS PANDAS PARA CREAR DATAFRAMES DE PRUEBA.
import pandas as pd
# DESDE TRANSFORMACION.LIMPIEZA IMPORTAMOS LIMPIADORDATOS PARA PROBAR SUS FUNCIONES DE LIMPIEZA DE DATOS.
from transformacion.limpieza import LimpiadorDatos

# DEFINIMOS UNA FUNCIÓN DE PRUEBA PARA VERIFICAR QUE LOS NOMBRES Y APELLIDOS DE LOS 
# PACIENTES SE CONVIERTAN A MAYÚSCULAS, QUE EL SEXO SE NORMALICE A 'M', 'F' O 'X', Y QUE LOS NÚMEROS 
# DE TELÉFONO SE LIMPIEN DE CARACTERES NO NUMÉRICOS.
def test_limpiar_pacientes_nombres_mayusculas():
    # 1. PREPARACIÓN: CREAMOS UN DATAFRAME DE PRUEBA CON NOMBRES, APELLIDOS, SEXO Y TELÉFONOS EN FORMATO DESORDENADO.
    data = {
        'paciente_id': [1],
        'nombre': ['giovanny'],
        'apellido': ['sena'],
        'sexo': ['m'],
        'telefono': ['300-1234-567']
    }
    # CREAMOS UN DATAFRAME A PARTIR DEL DICCIONARIO DE DATOS.
    df = pd.DataFrame(data)

    # 2. EJECUCIÓN: LLAMAMOS A LA FUNCIÓN DE LIMPIEZA DE DATOS PARA PROCESAR EL DATAFRAME DE PRUEBA.
    df_resultado = LimpiadorDatos.limpiar_pacientes(df)

    # 3. VERIFICACIÓN: USAMOS ASSERTS PARA VERIFICAR QUE LOS NOMBRES Y APELLIDOS SE CONVIERTAN A MAYÚSCULAS,
    # QUE EL SEXO SE NORMALICE A 'M', Y QUE LOS NÚMEROS DE TELÉFONO SE LIMPIEN DE CARACTERES NO NUMÉRICOS.
    assert df_resultado['nombre'].iloc[0] == 'GIOVANNY'
    assert df_resultado['apellido'].iloc[0] == 'SENA'
    assert df_resultado['sexo'].iloc[0] == 'M'
    assert df_resultado['telefono'].iloc[0] == '3001234567'

# DEFINIMOS OTRA FUNCIÓN DE PRUEBA PARA VERIFICAR QUE LOS VALORES DE SEXO INVÁLIDOS SE NORMALICEN A 'X'.
def test_limpiar_pacientes_sexo_invalido():
    # PREPARACIÓN: CREAMOS UN DATAFRAME DE PRUEBA CON VALORES DE SEXO INVÁLIDOS, INCLUYENDO 'Z' Y None.
    data = {'sexo': ['Z', None, 'F']}
    # CREAMOS UN DATAFRAME A PARTIR DEL DICCIONARIO DE DATOS.
    df = pd.DataFrame(data)
    
    # EJECUCIÓN: LLAMAMOS A LA FUNCIÓN DE LIMPIEZA DE DATOS PARA PROCESAR EL DATAFRAME DE PRUEBA.
    df_resultado = LimpiadorDatos.limpiar_pacientes(df)
    
    # ASERTS: VERIFICAMOS QUE LOS VALORES DE SEXO INVÁLIDOS SE NORMALICEN A 'X', MIENTRAS QUE LOS VALORES VÁLIDOS SE MANTENGAN.
    assert df_resultado['sexo'].tolist() == ['X', 'X', 'F']