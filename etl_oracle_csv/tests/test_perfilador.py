# IMPORTAMOS PYTEST PARA REALIZAR LAS PRUEBAS UNITARIAS. 
import pytest
# IMPORTAMOS PANDAS PARA CREAR UN DATAFRAME DE PRUEBA Y LA CLASE PERFILADORDATOS PARA PROBAR SU FUNCIONALIDAD.
import pandas as pd
# DESDE EL MÓDULO DE TRANSFORMACIÓN, IMPORTAMOS LA CLASE PERFILADORDATOS PARA 
# PROBAR SU MÉTODO DE GENERAR REPORTE DE CALIDAD.
from transformacion.perfilador import PerfiladorDatos

# DEFINIMOS UNA PRUEBA PARA EL MÉTODO GENERAR_REPORTE_CALIDAD DE LA CLASE PERFILADORDATOS.
def test_generar_reporte_calidad():
    # DATOS DE PRUEBA: CREAMOS UN DATAFRAME CON DOS REGISTROS, DONDE UNO DE ELLOS 
    # TIENE UN VALOR NULO EN LA COLUMNA 'nombre'.
    data = {
        'id': [1, 2],
        'nombre': ['Ana', None]
    }
    # CREAMOS EL DATAFRAME DE PRUEBA.
    df = pd.DataFrame(data)
    
    # LLAMAMOS AL MÉTODO GENERAR_REPORTE_CALIDAD PARA OBTENER EL REPORTE DE CALIDAD DE LOS DATOS.
    reporte = PerfiladorDatos.generar_reporte_calidad(df, "TABLA_TEST")
    
    # REALIZAMOS LAS ASERCIONES PARA VERIFICAR QUE EL REPORTE DE CALIDAD ES CORRECTO.
    assert reporte['total_registros'] == 2
    assert reporte['analisis_nulos']['nombre'] == 1
    assert reporte['analisis_nulos']['id'] == 0