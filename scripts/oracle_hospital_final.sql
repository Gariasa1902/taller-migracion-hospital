-- ============================================================
-- SISTEMA DE GESTION HOSPITALARIA - ORACLE 21c
-- VERSION FINAL CORREGIDA - Compatible con SQL*Plus
-- ============================================================
-- Sin hints APPEND (incompatibles con PL/SQL transaccional)
-- Sin comentarios inline en INSERT (rompen SQL*Plus)
-- FKs basadas en IDs reales de tablas padre
-- ============================================================

-- ============================================================
-- 1. SECUENCIAS
-- ============================================================
CREATE SEQUENCE seq_municipios     START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_especialidades START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_medicos        START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_pacientes      START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_internaciones  START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_citas          START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_examenes       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_resultados     START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_medicamentos   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_facturacion    START WITH 1 INCREMENT BY 1;

-- ============================================================
-- 2. TABLAS DE REFERENCIA
-- ============================================================
CREATE TABLE MUNICIPIOS (
  municipio_id   NUMBER(6)     PRIMARY KEY,
  nombre         VARCHAR2(100) NOT NULL,
  departamento   VARCHAR2(100) NOT NULL,
  codigo_dane    VARCHAR2(10),
  activo         CHAR(1)       DEFAULT 'S'
);

CREATE TABLE ESPECIALIDADES (
  especialidad_id   NUMBER(6)     PRIMARY KEY,
  nombre            VARCHAR2(120) NOT NULL,
  codigo_rips       VARCHAR2(10),
  descripcion       VARCHAR2(500),
  activo            CHAR(1) DEFAULT 'S'
);

-- ============================================================
-- 3. TABLAS PRINCIPALES
-- ============================================================
CREATE TABLE MEDICOS (
  medico_id         NUMBER(10)    PRIMARY KEY,
  documento         VARCHAR2(20)  NOT NULL,
  tipo_documento    VARCHAR2(5)   DEFAULT 'CC',
  nombres           VARCHAR2(100) NOT NULL,
  apellidos         VARCHAR2(100) NOT NULL,
  especialidad_id   NUMBER(6)     REFERENCES ESPECIALIDADES(especialidad_id),
  registro_medico   VARCHAR2(30),
  fecha_nacimiento  DATE,
  email             VARCHAR2(150),
  telefono          VARCHAR2(20),
  municipio_id      NUMBER(6)     REFERENCES MUNICIPIOS(municipio_id),
  fecha_ingreso     DATE          NOT NULL,
  activo            CHAR(1)       DEFAULT 'S',
  created_at        TIMESTAMP     DEFAULT SYSTIMESTAMP,
  updated_at        TIMESTAMP     DEFAULT SYSTIMESTAMP
);

CREATE TABLE PACIENTES (
  paciente_id       NUMBER(10)    PRIMARY KEY,
  documento         VARCHAR2(20)  NOT NULL,
  tipo_documento    VARCHAR2(5)   DEFAULT 'CC',
  nombres           VARCHAR2(100) NOT NULL,
  apellidos         VARCHAR2(100),
  fecha_nacimiento  DATE          NOT NULL,
  sexo              CHAR(1),
  grupo_sanguineo   VARCHAR2(5),
  email             VARCHAR2(150),
  telefono          VARCHAR2(20),
  direccion         VARCHAR2(200),
  municipio_id      NUMBER(6)     REFERENCES MUNICIPIOS(municipio_id),
  eps               VARCHAR2(100),
  regimen           VARCHAR2(20),
  activo            CHAR(1)       DEFAULT 'S',
  created_at        TIMESTAMP     DEFAULT SYSTIMESTAMP,
  updated_at        TIMESTAMP     DEFAULT SYSTIMESTAMP
);

CREATE TABLE INTERNACIONES (
  internacion_id      NUMBER(10)    PRIMARY KEY,
  paciente_id         NUMBER(10)    NOT NULL REFERENCES PACIENTES(paciente_id),
  medico_id           NUMBER(10)    REFERENCES MEDICOS(medico_id),
  fecha_ingreso       DATE          NOT NULL,
  fecha_egreso        DATE,
  motivo_ingreso      VARCHAR2(500) NOT NULL,
  diagnostico_ingreso VARCHAR2(200),
  diagnostico_egreso  VARCHAR2(200),
  habitacion          VARCHAR2(20),
  tipo_habitacion     VARCHAR2(30),
  estado              VARCHAR2(20)  DEFAULT 'ACTIVA',
  observaciones       CLOB,
  created_at          TIMESTAMP     DEFAULT SYSTIMESTAMP
);

CREATE TABLE CITAS_MEDICAS (
  cita_id           NUMBER(10)    PRIMARY KEY,
  paciente_id       NUMBER(10)    NOT NULL REFERENCES PACIENTES(paciente_id),
  medico_id         NUMBER(10)    NOT NULL REFERENCES MEDICOS(medico_id),
  especialidad_id   NUMBER(6)     REFERENCES ESPECIALIDADES(especialidad_id),
  fecha_cita        DATE          NOT NULL,
  hora_cita         VARCHAR2(8),
  duracion_min      NUMBER(5)     DEFAULT 20,
  estado            VARCHAR2(20)  DEFAULT 'PROGRAMADA',
  tipo_cita         VARCHAR2(30)  DEFAULT 'CONSULTA',
  motivo_consulta   VARCHAR2(500),
  observaciones     VARCHAR2(1000),
  internacion_id    NUMBER(10)    REFERENCES INTERNACIONES(internacion_id),
  created_at        TIMESTAMP     DEFAULT SYSTIMESTAMP
);

CREATE TABLE EXAMENES_MEDICOS (
  examen_id          NUMBER(10)    PRIMARY KEY,
  cita_id            NUMBER(10)    REFERENCES CITAS_MEDICAS(cita_id),
  paciente_id        NUMBER(10)    NOT NULL REFERENCES PACIENTES(paciente_id),
  medico_solicitante NUMBER(10)    REFERENCES MEDICOS(medico_id),
  tipo_examen        VARCHAR2(100) NOT NULL,
  descripcion        VARCHAR2(300),
  fecha_solicitud    DATE          NOT NULL,
  fecha_resultado    DATE,
  estado             VARCHAR2(20)  DEFAULT 'PENDIENTE',
  prioridad          VARCHAR2(15)  DEFAULT 'NORMAL',
  costo              NUMBER(12,2),
  created_at         TIMESTAMP     DEFAULT SYSTIMESTAMP
);

CREATE TABLE RESULTADOS_EXAMENES (
  resultado_id      NUMBER(10)    PRIMARY KEY,
  examen_id         NUMBER(10)    NOT NULL REFERENCES EXAMENES_MEDICOS(examen_id),
  descripcion       VARCHAR2(500) NOT NULL,
  valor_resultado   VARCHAR2(200),
  unidad_medida     VARCHAR2(50),
  valor_referencia  VARCHAR2(100),
  interpretacion    VARCHAR2(500),
  medico_revisor    NUMBER(10)    REFERENCES MEDICOS(medico_id),
  fecha_reporte     DATE,
  created_at        TIMESTAMP     DEFAULT SYSTIMESTAMP
);

CREATE TABLE MEDICAMENTOS_RECETADOS (
  receta_id          NUMBER(10)    PRIMARY KEY,
  cita_id            NUMBER(10)    REFERENCES CITAS_MEDICAS(cita_id),
  paciente_id        NUMBER(10)    NOT NULL REFERENCES PACIENTES(paciente_id),
  medico_id          NUMBER(10)    REFERENCES MEDICOS(medico_id),
  nombre_medicamento VARCHAR2(200) NOT NULL,
  principio_activo   VARCHAR2(200),
  concentracion      VARCHAR2(50),
  forma_farmaceutica VARCHAR2(80),
  dosis              VARCHAR2(100),
  frecuencia         VARCHAR2(100),
  duracion_dias      NUMBER(5),
  cantidad           NUMBER(8),
  fecha_prescripcion DATE          NOT NULL,
  observaciones      VARCHAR2(500),
  created_at         TIMESTAMP     DEFAULT SYSTIMESTAMP
);

CREATE TABLE FACTURACION (
  factura_id        NUMBER(10)    PRIMARY KEY,
  paciente_id       NUMBER(10)    NOT NULL REFERENCES PACIENTES(paciente_id),
  cita_id           NUMBER(10)    REFERENCES CITAS_MEDICAS(cita_id),
  internacion_id    NUMBER(10)    REFERENCES INTERNACIONES(internacion_id),
  numero_factura    VARCHAR2(30),
  fecha_factura     DATE          NOT NULL,
  subtotal          NUMBER(14,2)  NOT NULL,
  descuento         NUMBER(14,2)  DEFAULT 0,
  iva               NUMBER(14,2)  DEFAULT 0,
  total             NUMBER(14,2)  NOT NULL,
  estado            VARCHAR2(20)  DEFAULT 'PENDIENTE',
  metodo_pago       VARCHAR2(30),
  eps_facturado     VARCHAR2(100),
  observaciones     VARCHAR2(500),
  created_at        TIMESTAMP     DEFAULT SYSTIMESTAMP
);

-- ============================================================
-- 4. INDICES
-- ============================================================
CREATE INDEX idx_pacientes_doc      ON PACIENTES(documento);
CREATE INDEX idx_medicos_doc        ON MEDICOS(documento);
CREATE INDEX idx_citas_fecha        ON CITAS_MEDICAS(fecha_cita);
CREATE INDEX idx_citas_paciente     ON CITAS_MEDICAS(paciente_id);
CREATE INDEX idx_citas_medico       ON CITAS_MEDICAS(medico_id);
CREATE INDEX idx_internaciones_pac  ON INTERNACIONES(paciente_id);
CREATE INDEX idx_internaciones_ing  ON INTERNACIONES(fecha_ingreso);
CREATE INDEX idx_examenes_pac       ON EXAMENES_MEDICOS(paciente_id);
CREATE INDEX idx_facturacion_fecha  ON FACTURACION(fecha_factura);
CREATE INDEX idx_facturacion_pac    ON FACTURACION(paciente_id);

-- ============================================================
-- 5. DATOS DE REFERENCIA
-- ============================================================
INSERT INTO MUNICIPIOS VALUES (seq_municipios.NEXTVAL, 'Bogota',        'Cundinamarca',        '11001', 'S');
INSERT INTO MUNICIPIOS VALUES (seq_municipios.NEXTVAL, 'Medellin',      'Antioquia',           '05001', 'S');
INSERT INTO MUNICIPIOS VALUES (seq_municipios.NEXTVAL, 'Cali',          'Valle',               '76001', 'S');
INSERT INTO MUNICIPIOS VALUES (seq_municipios.NEXTVAL, 'Barranquilla',  'Atlantico',           '08001', 'S');
INSERT INTO MUNICIPIOS VALUES (seq_municipios.NEXTVAL, 'Cartagena',     'Bolivar',             '13001', 'S');
INSERT INTO MUNICIPIOS VALUES (seq_municipios.NEXTVAL, 'Bucaramanga',   'Santander',           '68001', 'S');
INSERT INTO MUNICIPIOS VALUES (seq_municipios.NEXTVAL, 'Pereira',       'Risaralda',           '66001', 'S');
INSERT INTO MUNICIPIOS VALUES (seq_municipios.NEXTVAL, 'Manizales',     'Caldas',              '17001', 'S');
INSERT INTO MUNICIPIOS VALUES (seq_municipios.NEXTVAL, 'Ibague',        'Tolima',              '73001', 'S');
INSERT INTO MUNICIPIOS VALUES (seq_municipios.NEXTVAL, 'Cucuta',        'Norte de Santander',  NULL,    'S');
INSERT INTO MUNICIPIOS VALUES (seq_municipios.NEXTVAL, 'Santa Marta',   'Magdalena',           NULL,    'S');
INSERT INTO MUNICIPIOS VALUES (seq_municipios.NEXTVAL, 'Villavicencio', 'Meta',                '50001', 'S');
INSERT INTO MUNICIPIOS VALUES (seq_municipios.NEXTVAL, 'Pasto',         'Narino',              '52001', 'S');
INSERT INTO MUNICIPIOS VALUES (seq_municipios.NEXTVAL, 'Monteria',      'Cordoba',             '23001', 'S');
INSERT INTO MUNICIPIOS VALUES (seq_municipios.NEXTVAL, 'Armenia',       'Quindio',             '63001', 'S');

INSERT INTO ESPECIALIDADES VALUES (seq_especialidades.NEXTVAL, 'Medicina General',   'MG001', 'Atencion primaria en salud',           'S');
INSERT INTO ESPECIALIDADES VALUES (seq_especialidades.NEXTVAL, 'Cardiologia',        'CA002', 'Enfermedades del corazon',             'S');
INSERT INTO ESPECIALIDADES VALUES (seq_especialidades.NEXTVAL, 'Pediatria',          'PD003', 'Medicina para ninos y adolescentes',   'S');
INSERT INTO ESPECIALIDADES VALUES (seq_especialidades.NEXTVAL, 'Ginecologia',        'GN004', 'Salud de la mujer',                    'S');
INSERT INTO ESPECIALIDADES VALUES (seq_especialidades.NEXTVAL, 'Ortopedia',          'OT005', 'Sistema musculoesqueletico',           'S');
INSERT INTO ESPECIALIDADES VALUES (seq_especialidades.NEXTVAL, 'Neurologia',         'NR006', 'Sistema nervioso',                     'S');
INSERT INTO ESPECIALIDADES VALUES (seq_especialidades.NEXTVAL, 'Psiquiatria',        'PS007', 'Salud mental',                         'S');
INSERT INTO ESPECIALIDADES VALUES (seq_especialidades.NEXTVAL, 'Dermatologia',       'DM008', 'Piel y tejidos',                       'S');
INSERT INTO ESPECIALIDADES VALUES (seq_especialidades.NEXTVAL, 'Oftalmologia',       'OF009', 'Salud ocular',                         'S');
INSERT INTO ESPECIALIDADES VALUES (seq_especialidades.NEXTVAL, 'Urgencias',          'MG001', 'Atencion de emergencias',              'S');
INSERT INTO ESPECIALIDADES VALUES (seq_especialidades.NEXTVAL, 'Oncologia',          'ON011', 'Tratamiento del cancer',               'S');
INSERT INTO ESPECIALIDADES VALUES (seq_especialidades.NEXTVAL, 'Endocrinologia',     'EN012', 'Sistema endocrino',                    'S');
INSERT INTO ESPECIALIDADES VALUES (seq_especialidades.NEXTVAL, 'Gastroenterologia',  'GA013', 'Sistema digestivo',                    'S');
INSERT INTO ESPECIALIDADES VALUES (seq_especialidades.NEXTVAL, 'Nefrologia',         'NF014', 'Enfermedades renales',                 'S');
INSERT INTO ESPECIALIDADES VALUES (seq_especialidades.NEXTVAL, 'Infectologia',       'IF015', 'Enfermedades infecciosas',             'S');

COMMIT;

-- ============================================================
-- 6. PROCEDIMIENTO DE GENERACION MASIVA
-- ============================================================

CREATE OR REPLACE PROCEDURE generar_datos_hospital_bulk(
  p_num_medicos    IN NUMBER DEFAULT 200,
  p_num_pacientes  IN NUMBER DEFAULT 100000,
  p_anios_historia IN NUMBER DEFAULT 5
) AS
  v_fecha_base      DATE;
  v_total_dias      NUMBER;
  v_count           NUMBER;
  v_min_medico      NUMBER;
  v_max_medico      NUMBER;
  v_min_paciente    NUMBER;
  v_max_paciente    NUMBER;
  v_min_municipio   NUMBER;
  v_min_especialidad NUMBER;
BEGIN

  v_fecha_base := ADD_MONTHS(SYSDATE, -(p_anios_historia * 12));
  v_total_dias := p_anios_historia * 365;

  DBMS_OUTPUT.PUT_LINE('=== INICIO GENERACION BULK ===');
  DBMS_OUTPUT.PUT_LINE('Medicos:       ' || p_num_medicos);
  DBMS_OUTPUT.PUT_LINE('Pacientes:     ' || p_num_pacientes);
  DBMS_OUTPUT.PUT_LINE('Fecha base:    ' || TO_CHAR(v_fecha_base, 'YYYY-MM-DD'));

  -- Obtener rangos reales de IDs de tablas de referencia
  SELECT MIN(municipio_id) INTO v_min_municipio FROM MUNICIPIOS;
  SELECT MIN(especialidad_id) INTO v_min_especialidad FROM ESPECIALIDADES;

  -- -------------------------------------------------------
  -- 1. MEDICOS
  -- -------------------------------------------------------
  DBMS_OUTPUT.PUT_LINE('Generando medicos...');
  INSERT INTO MEDICOS (
    medico_id, documento, tipo_documento, nombres, apellidos,
    especialidad_id, registro_medico, fecha_nacimiento, email,
    telefono, municipio_id, fecha_ingreso, activo
  )
  SELECT
    seq_medicos.NEXTVAL,
    TO_CHAR(30000000 + rn * 317),
    CASE WHEN MOD(rn, 20) = 0 THEN 'CE' ELSE 'CC' END,
    CASE MOD(rn, 35)
      WHEN 0 THEN 'Andres'     WHEN 1 THEN 'Carlos'     WHEN 2 THEN 'Diana'
      WHEN 3 THEN 'Elena'      WHEN 4 THEN 'Fernando'   WHEN 5 THEN 'Gloria'
      WHEN 6 THEN 'Hernan'     WHEN 7 THEN 'Isabel'     WHEN 8 THEN 'Jorge'
      WHEN 9 THEN 'Karen'      WHEN 10 THEN 'Luis'      WHEN 11 THEN 'Maria'
      WHEN 12 THEN 'Nicolas'   WHEN 13 THEN 'Olga'      WHEN 14 THEN 'Pablo'
      WHEN 15 THEN 'Rosa'      WHEN 16 THEN 'Santiago'   WHEN 17 THEN 'Teresa'
      WHEN 18 THEN 'Uriel'     WHEN 19 THEN 'Valentina'  WHEN 20 THEN 'William'
      WHEN 21 THEN 'Ximena'    WHEN 22 THEN 'Yuliana'   WHEN 23 THEN 'Zaida'
      WHEN 24 THEN 'Alejandro' WHEN 25 THEN 'Beatriz'   WHEN 26 THEN 'Camilo'
      WHEN 27 THEN 'Daniela'   WHEN 28 THEN 'Eduardo'   WHEN 29 THEN 'Fernanda'
      WHEN 30 THEN 'Gabriel'   WHEN 31 THEN 'Helena'    WHEN 32 THEN 'Ivan'
      WHEN 33 THEN 'Juliana'   ELSE 'Quintero'
    END,
    CASE MOD(rn * 3, 30)
      WHEN 0 THEN 'Garcia'    WHEN 1 THEN 'Rodriguez'  WHEN 2 THEN 'Martinez'
      WHEN 3 THEN 'Lopez'     WHEN 4 THEN 'Gonzalez'   WHEN 5 THEN 'Perez'
      WHEN 6 THEN 'Sanchez'   WHEN 7 THEN 'Ramirez'    WHEN 8 THEN 'Torres'
      WHEN 9 THEN 'Flores'    WHEN 10 THEN 'Rivera'    WHEN 11 THEN 'Gomez'
      WHEN 12 THEN 'Diaz'     WHEN 13 THEN 'Cruz'      WHEN 14 THEN 'Morales'
      WHEN 15 THEN 'Reyes'    WHEN 16 THEN 'Ortiz'     WHEN 17 THEN 'Vargas'
      WHEN 18 THEN 'Ramos'    WHEN 19 THEN 'Herrera'   WHEN 20 THEN 'Medina'
      WHEN 21 THEN 'Castillo' WHEN 22 THEN 'Jimenez'   WHEN 23 THEN 'Moreno'
      WHEN 24 THEN 'Romero'   WHEN 25 THEN 'Guerrero'  WHEN 26 THEN 'Mendoza'
      WHEN 27 THEN 'Alvarez'  WHEN 28 THEN 'Ruiz'      ELSE 'Aguilar'
    END || ' ' ||
    CASE MOD(rn * 7, 30)
      WHEN 0 THEN 'Garcia'    WHEN 1 THEN 'Rodriguez'  WHEN 2 THEN 'Martinez'
      WHEN 3 THEN 'Lopez'     WHEN 4 THEN 'Gonzalez'   WHEN 5 THEN 'Perez'
      WHEN 6 THEN 'Sanchez'   WHEN 7 THEN 'Ramirez'    WHEN 8 THEN 'Torres'
      WHEN 9 THEN 'Flores'    WHEN 10 THEN 'Rivera'    WHEN 11 THEN 'Gomez'
      WHEN 12 THEN 'Diaz'     WHEN 13 THEN 'Cruz'      WHEN 14 THEN 'Morales'
      WHEN 15 THEN 'Reyes'    WHEN 16 THEN 'Ortiz'     WHEN 17 THEN 'Vargas'
      WHEN 18 THEN 'Ramos'    WHEN 19 THEN 'Herrera'   WHEN 20 THEN 'Medina'
      WHEN 21 THEN 'Castillo' WHEN 22 THEN 'Jimenez'   WHEN 23 THEN 'Moreno'
      WHEN 24 THEN 'Romero'   WHEN 25 THEN 'Guerrero'  WHEN 26 THEN 'Mendoza'
      WHEN 27 THEN 'Alvarez'  WHEN 28 THEN 'Ruiz'      ELSE 'Aguilar'
    END,
    v_min_especialidad + MOD(rn, 15),
    'RM-' || LPAD(TO_CHAR(rn), 8, '0'),
    TO_DATE('1960-01-01', 'YYYY-MM-DD') + DBMS_RANDOM.VALUE(0, 12000),
    CASE
      WHEN MOD(rn, 13) = 0 THEN 'medico_sin_arroba_' || rn
      WHEN MOD(rn, 17) = 0 THEN NULL
      ELSE LOWER('medico' || rn || '@hospital.com')
    END,
    '31' || LPAD(TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(0, 9999999))), 7, '0'),
    v_min_municipio + MOD(rn, 15),
    TO_DATE('2010-01-01', 'YYYY-MM-DD') + DBMS_RANDOM.VALUE(0, 4000),
    CASE WHEN MOD(rn, 50) = 0 THEN 'N' ELSE 'S' END
  FROM (
    SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= p_num_medicos
  );
  v_count := SQL%ROWCOUNT;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('  Medicos insertados: ' || v_count);

  -- Capturar rango real de medico_id
  SELECT MIN(medico_id), MAX(medico_id) INTO v_min_medico, v_max_medico FROM MEDICOS;
  DBMS_OUTPUT.PUT_LINE('  Rango medico_id: ' || v_min_medico || ' - ' || v_max_medico);

  -- -------------------------------------------------------
  -- 2. PACIENTES (100K via CROSS JOIN)
  -- -------------------------------------------------------
  DBMS_OUTPUT.PUT_LINE('Generando pacientes...');
  INSERT INTO PACIENTES (
    paciente_id, documento, tipo_documento, nombres, apellidos,
    fecha_nacimiento, sexo, grupo_sanguineo, email, telefono,
    direccion, municipio_id, eps, regimen, activo
  )
  SELECT
    seq_pacientes.NEXTVAL,
    TO_CHAR(10000000 + rn * 499),
    CASE WHEN MOD(rn, 30) = 0 THEN 'TI'
         WHEN MOD(rn, 15) = 0 THEN 'CE'
         ELSE 'CC' END,
    CASE MOD(rn, 35)
      WHEN 0 THEN 'Andres'     WHEN 1 THEN 'Carlos'     WHEN 2 THEN 'Diana'
      WHEN 3 THEN 'Elena'      WHEN 4 THEN 'Fernando'   WHEN 5 THEN 'Gloria'
      WHEN 6 THEN 'Hernan'     WHEN 7 THEN 'Isabel'     WHEN 8 THEN 'Jorge'
      WHEN 9 THEN 'Karen'      WHEN 10 THEN 'Luis'      WHEN 11 THEN 'Maria'
      WHEN 12 THEN 'Nicolas'   WHEN 13 THEN 'Olga'      WHEN 14 THEN 'Pablo'
      WHEN 15 THEN 'Rosa'      WHEN 16 THEN 'Santiago'   WHEN 17 THEN 'Teresa'
      WHEN 18 THEN 'Uriel'     WHEN 19 THEN 'Valentina'  WHEN 20 THEN 'William'
      WHEN 21 THEN 'Ximena'    WHEN 22 THEN 'Yuliana'   WHEN 23 THEN 'Zaida'
      WHEN 24 THEN 'Alejandro' WHEN 25 THEN 'Beatriz'   WHEN 26 THEN 'Camilo'
      WHEN 27 THEN 'Daniela'   WHEN 28 THEN 'Eduardo'   WHEN 29 THEN 'Fernanda'
      WHEN 30 THEN 'Gabriel'   WHEN 31 THEN 'Helena'    WHEN 32 THEN 'Ivan'
      WHEN 33 THEN 'Juliana'   ELSE 'Quintero'
    END,
    CASE WHEN MOD(rn, 33) = 0 THEN NULL
    ELSE
      CASE MOD(rn * 5, 30)
        WHEN 0 THEN 'Garcia'    WHEN 1 THEN 'Rodriguez'  WHEN 2 THEN 'Martinez'
        WHEN 3 THEN 'Lopez'     WHEN 4 THEN 'Gonzalez'   WHEN 5 THEN 'Perez'
        WHEN 6 THEN 'Sanchez'   WHEN 7 THEN 'Ramirez'    WHEN 8 THEN 'Torres'
        WHEN 9 THEN 'Flores'    WHEN 10 THEN 'Rivera'    WHEN 11 THEN 'Gomez'
        WHEN 12 THEN 'Diaz'     WHEN 13 THEN 'Cruz'      WHEN 14 THEN 'Morales'
        WHEN 15 THEN 'Reyes'    WHEN 16 THEN 'Ortiz'     WHEN 17 THEN 'Vargas'
        WHEN 18 THEN 'Ramos'    WHEN 19 THEN 'Herrera'   WHEN 20 THEN 'Medina'
        WHEN 21 THEN 'Castillo' WHEN 22 THEN 'Jimenez'   WHEN 23 THEN 'Moreno'
        WHEN 24 THEN 'Romero'   WHEN 25 THEN 'Guerrero'  WHEN 26 THEN 'Mendoza'
        WHEN 27 THEN 'Alvarez'  WHEN 28 THEN 'Ruiz'      ELSE 'Aguilar'
      END || ' ' ||
      CASE MOD(rn * 11, 30)
        WHEN 0 THEN 'Garcia'    WHEN 1 THEN 'Rodriguez'  WHEN 2 THEN 'Martinez'
        WHEN 3 THEN 'Lopez'     WHEN 4 THEN 'Gonzalez'   WHEN 5 THEN 'Perez'
        WHEN 6 THEN 'Sanchez'   WHEN 7 THEN 'Ramirez'    WHEN 8 THEN 'Torres'
        WHEN 9 THEN 'Flores'    WHEN 10 THEN 'Rivera'    WHEN 11 THEN 'Gomez'
        WHEN 12 THEN 'Diaz'     WHEN 13 THEN 'Cruz'      WHEN 14 THEN 'Morales'
        WHEN 15 THEN 'Reyes'    WHEN 16 THEN 'Ortiz'     WHEN 17 THEN 'Vargas'
        WHEN 18 THEN 'Ramos'    WHEN 19 THEN 'Herrera'   WHEN 20 THEN 'Medina'
        WHEN 21 THEN 'Castillo' WHEN 22 THEN 'Jimenez'   WHEN 23 THEN 'Moreno'
        WHEN 24 THEN 'Romero'   WHEN 25 THEN 'Guerrero'  WHEN 26 THEN 'Mendoza'
        WHEN 27 THEN 'Alvarez'  WHEN 28 THEN 'Ruiz'      ELSE 'Aguilar'
      END
    END,
    TO_DATE('1940-01-01','YYYY-MM-DD') + DBMS_RANDOM.VALUE(0, 30000),
    CASE
      WHEN MOD(rn, 2) = 0    THEN 'F'
      WHEN MOD(rn, 41) = 0   THEN 'f'
      WHEN MOD(rn, 53) = 0   THEN NULL
      WHEN MOD(rn, 67) = 0   THEN 'X'
      ELSE 'M'
    END,
    CASE MOD(rn, 8)
      WHEN 0 THEN 'A+'  WHEN 1 THEN 'A-'
      WHEN 2 THEN 'B+'  WHEN 3 THEN 'B-'
      WHEN 4 THEN 'O+'  WHEN 5 THEN 'O-'
      WHEN 6 THEN 'AB+' ELSE 'AB-'
    END,
    CASE WHEN MOD(rn, 10) = 0 THEN NULL
         ELSE LOWER('paciente' || rn || '@gmail.com')
    END,
    '3' || LPAD(TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(0, 999999999))), 9, '0'),
    'Calle ' || TO_CHAR(MOD(rn, 200) + 1) || ' # ' ||
      TO_CHAR(MOD(rn * 3, 99) + 1) || '-' || TO_CHAR(MOD(rn * 7, 99) + 1),
    v_min_municipio + MOD(rn, 15),
    CASE MOD(rn, 10)
      WHEN 0 THEN 'SURA'        WHEN 1 THEN 'COMPENSAR'
      WHEN 2 THEN 'SANITAS'     WHEN 3 THEN 'COOMEVA'
      WHEN 4 THEN 'NUEVA EPS'   WHEN 5 THEN 'FAMISANAR'
      WHEN 6 THEN 'SALUD TOTAL' WHEN 7 THEN 'MEDIMAS'
      WHEN 8 THEN 'CAFESALUD'   ELSE 'COOSALUD'
    END,
    CASE MOD(rn, 3)
      WHEN 0 THEN 'CONTRIBUTIVO'
      WHEN 1 THEN 'SUBSIDIADO'
      ELSE 'ESPECIAL'
    END,
    'S'
  FROM (
    SELECT (a.n - 1) * 250 + b.n AS rn
    FROM (SELECT LEVEL AS n FROM DUAL CONNECT BY LEVEL <= 400) a
    CROSS JOIN (SELECT LEVEL AS n FROM DUAL CONNECT BY LEVEL <= 250) b
    WHERE (a.n - 1) * 250 + b.n <= p_num_pacientes
  );
  v_count := SQL%ROWCOUNT;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('  Pacientes insertados: ' || v_count);

  -- Capturar rango real de paciente_id
  SELECT MIN(paciente_id), MAX(paciente_id) INTO v_min_paciente, v_max_paciente FROM PACIENTES;
  DBMS_OUTPUT.PUT_LINE('  Rango paciente_id: ' || v_min_paciente || ' - ' || v_max_paciente);

  -- -------------------------------------------------------
  -- 3. CITAS MEDICAS - Ronda 1 (1 por paciente = 100K)
  -- Usa IDs reales de medicos via subquery
  -- -------------------------------------------------------
  DBMS_OUTPUT.PUT_LINE('Generando citas ronda 1...');
  INSERT INTO CITAS_MEDICAS (
    cita_id, paciente_id, medico_id, especialidad_id,
    fecha_cita, hora_cita, duracion_min, estado,
    tipo_cita, motivo_consulta
  )
  SELECT
    seq_citas.NEXTVAL,
    p.paciente_id,
    v_min_medico + MOD(p.paciente_id, (v_max_medico - v_min_medico + 1)),
    v_min_especialidad + MOD(p.paciente_id, 15),
    v_fecha_base + MOD(p.paciente_id * 7, v_total_dias),
    CASE
      WHEN MOD(p.paciente_id, 20) = 0 THEN TO_CHAR(MOD(p.paciente_id, 11) + 7) || 'h30'
      WHEN MOD(p.paciente_id, 15) = 0 THEN NULL
      ELSE LPAD(TO_CHAR(MOD(p.paciente_id, 11) + 7), 2, '0') || ':' ||
           CASE MOD(p.paciente_id, 3) WHEN 0 THEN '00' WHEN 1 THEN '30' ELSE '15' END
    END,
    CASE MOD(p.paciente_id, 3) WHEN 0 THEN 15 WHEN 1 THEN 20 ELSE 30 END,
    CASE
      WHEN v_fecha_base + MOD(p.paciente_id * 7, v_total_dias) > SYSDATE - 30 THEN 'PROGRAMADA'
      WHEN MOD(p.paciente_id, 4) IN (0,1) THEN 'ATENDIDA'
      WHEN MOD(p.paciente_id, 4) = 2 THEN 'CANCELADA'
      ELSE 'NO_ASISTIO'
    END,
    CASE MOD(p.paciente_id, 4)
      WHEN 0 THEN 'CONSULTA'  WHEN 1 THEN 'CONTROL'
      WHEN 2 THEN 'URGENCIA'  ELSE 'PRIMERA_VEZ'
    END,
    CASE MOD(p.paciente_id, 5)
      WHEN 0 THEN 'Dolor abdominal persistente'
      WHEN 1 THEN 'Control de hipertension arterial'
      WHEN 2 THEN 'Revision de resultados de laboratorio'
      WHEN 3 THEN 'Cefalea intensa y mareos'
      ELSE 'Chequeo medico general'
    END
  FROM PACIENTES p;
  v_count := SQL%ROWCOUNT;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('  Citas ronda 1: ' || v_count);

  -- -------------------------------------------------------
  -- 4. CITAS MEDICAS - Ronda 2 (50% de pacientes = ~50K)
  -- -------------------------------------------------------
  DBMS_OUTPUT.PUT_LINE('Generando citas ronda 2...');
  INSERT INTO CITAS_MEDICAS (
    cita_id, paciente_id, medico_id, especialidad_id,
    fecha_cita, hora_cita, duracion_min, estado,
    tipo_cita, motivo_consulta
  )
  SELECT
    seq_citas.NEXTVAL,
    p.paciente_id,
    v_min_medico + MOD(p.paciente_id * 3, (v_max_medico - v_min_medico + 1)),
    v_min_especialidad + MOD(p.paciente_id * 3, 15),
    v_fecha_base + MOD(p.paciente_id * 13, v_total_dias),
    LPAD(TO_CHAR(MOD(p.paciente_id * 3, 11) + 7), 2, '0') || ':' ||
      CASE MOD(p.paciente_id, 2) WHEN 0 THEN '00' ELSE '30' END,
    20,
    CASE
      WHEN v_fecha_base + MOD(p.paciente_id * 13, v_total_dias) > SYSDATE - 30 THEN 'PROGRAMADA'
      WHEN MOD(p.paciente_id, 3) IN (0,1) THEN 'ATENDIDA'
      ELSE 'NO_ASISTIO'
    END,
    'CONTROL',
    'Control de seguimiento'
  FROM PACIENTES p
  WHERE MOD(p.paciente_id, 2) = 0;
  v_count := SQL%ROWCOUNT;
  COMMIT;
  SELECT COUNT(*) INTO v_count FROM CITAS_MEDICAS;
  DBMS_OUTPUT.PUT_LINE('  Citas totales: ' || v_count);

  -- -------------------------------------------------------
  -- 5. INTERNACIONES (20% de pacientes)
  -- -------------------------------------------------------
  DBMS_OUTPUT.PUT_LINE('Generando internaciones...');
  INSERT INTO INTERNACIONES (
    internacion_id, paciente_id, medico_id,
    fecha_ingreso, fecha_egreso,
    motivo_ingreso, diagnostico_ingreso, diagnostico_egreso,
    habitacion, tipo_habitacion, estado
  )
  SELECT
    seq_internaciones.NEXTVAL,
    p.paciente_id,
    v_min_medico + MOD(p.paciente_id, (v_max_medico - v_min_medico + 1)),
    v_fecha_base + MOD(p.paciente_id * 11, v_total_dias),
    CASE WHEN v_fecha_base + MOD(p.paciente_id * 11, v_total_dias) < SYSDATE - 5
         THEN v_fecha_base + MOD(p.paciente_id * 11, v_total_dias) + MOD(p.paciente_id, 20) + 1
         ELSE NULL
    END,
    'Hospitalizacion por complicacion de patologia cronica',
    CASE MOD(p.paciente_id, 6)
      WHEN 0 THEN 'Neumonia bacteriana'
      WHEN 1 THEN 'Insuficiencia cardiaca descompensada'
      WHEN 2 THEN 'Crisis hipertensiva'
      WHEN 3 THEN 'Cetoacidosis diabetica'
      WHEN 4 THEN 'Fractura de cadera'
      ELSE 'Evento cerebrovascular isquemico'
    END,
    CASE WHEN v_fecha_base + MOD(p.paciente_id * 11, v_total_dias) < SYSDATE - 5
         THEN 'Resolucion del cuadro agudo' ELSE NULL
    END,
    TO_CHAR(MOD(p.paciente_id, 400) + 100),
    CASE MOD(p.paciente_id, 4)
      WHEN 0 THEN 'UCI'     WHEN 1 THEN 'PISO'
      WHEN 2 THEN 'GENERAL' ELSE 'URGENCIAS'
    END,
    CASE
      WHEN v_fecha_base + MOD(p.paciente_id * 11, v_total_dias) > SYSDATE - 5 THEN 'ACTIVA'
      WHEN MOD(p.paciente_id, 200) = 0 THEN 'FALLECIDO'
      ELSE 'ALTA'
    END
  FROM PACIENTES p
  WHERE MOD(p.paciente_id, 5) = 0;
  v_count := SQL%ROWCOUNT;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('  Internaciones: ' || v_count);

  -- -------------------------------------------------------
  -- 6. EXAMENES (60% de citas atendidas)
  -- -------------------------------------------------------
  DBMS_OUTPUT.PUT_LINE('Generando examenes...');
  INSERT INTO EXAMENES_MEDICOS (
    examen_id, cita_id, paciente_id, medico_solicitante,
    tipo_examen, fecha_solicitud, fecha_resultado,
    estado, prioridad, costo
  )
  SELECT
    seq_examenes.NEXTVAL,
    c.cita_id, c.paciente_id, c.medico_id,
    CASE MOD(c.cita_id, 20)
      WHEN 0  THEN 'Hemograma Completo'     WHEN 1  THEN 'Glicemia en Ayunas'
      WHEN 2  THEN 'Perfil Lipidico'        WHEN 3  THEN 'Funcion Renal'
      WHEN 4  THEN 'Funcion Hepatica'       WHEN 5  THEN 'TSH'
      WHEN 6  THEN 'Radiografia de Torax'   WHEN 7  THEN 'Electrocardiograma'
      WHEN 8  THEN 'Ecografia Abdominal'    WHEN 9  THEN 'Parcial de Orina'
      WHEN 10 THEN 'Cultivo de Orina'       WHEN 11 THEN 'PCR'
      WHEN 12 THEN 'Creatinina'             WHEN 13 THEN 'Urea'
      WHEN 14 THEN 'Electrolitos'           WHEN 15 THEN 'Prueba de Embarazo'
      WHEN 16 THEN 'INR'                    WHEN 17 THEN 'HbA1c'
      WHEN 18 THEN 'Proteinuria 24h'        ELSE 'Resonancia Magnetica Cerebral'
    END,
    c.fecha_cita,
    CASE WHEN c.fecha_cita < SYSDATE - 2
         THEN c.fecha_cita + MOD(c.cita_id, 6) + 1
         ELSE NULL
    END,
    CASE WHEN c.fecha_cita < SYSDATE - 2 THEN 'ENTREGADO' ELSE 'PENDIENTE' END,
    CASE WHEN MOD(c.cita_id, 10) = 0 THEN 'URGENTE' ELSE 'NORMAL' END,
    ROUND(DBMS_RANDOM.VALUE(15000, 250000), -2)
  FROM CITAS_MEDICAS c
  WHERE c.estado = 'ATENDIDA'
    AND MOD(c.cita_id, 10) < 6;
  v_count := SQL%ROWCOUNT;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('  Examenes: ' || v_count);

  -- -------------------------------------------------------
  -- 7. RESULTADOS (examenes entregados)
  -- -------------------------------------------------------
  DBMS_OUTPUT.PUT_LINE('Generando resultados...');
  INSERT INTO RESULTADOS_EXAMENES (
    resultado_id, examen_id, descripcion, valor_resultado,
    unidad_medida, valor_referencia, fecha_reporte
  )
  SELECT
    seq_resultados.NEXTVAL,
    e.examen_id,
    'Resultado de ' || e.tipo_examen,
    TO_CHAR(ROUND(DBMS_RANDOM.VALUE(50, 300), 1)),
    CASE MOD(e.examen_id, 5)
      WHEN 0 THEN 'mg/dL' WHEN 1 THEN 'mEq/L'
      WHEN 2 THEN 'UI/L'  WHEN 3 THEN 'g/dL' ELSE '%'
    END,
    'Ver tabla de referencia',
    e.fecha_solicitud + MOD(e.examen_id, 6) + 1
  FROM EXAMENES_MEDICOS e
  WHERE e.estado = 'ENTREGADO';
  v_count := SQL%ROWCOUNT;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('  Resultados: ' || v_count);

  -- -------------------------------------------------------
  -- 8. MEDICAMENTOS (70% de citas atendidas)
  -- -------------------------------------------------------
  DBMS_OUTPUT.PUT_LINE('Generando medicamentos...');
  INSERT INTO MEDICAMENTOS_RECETADOS (
    receta_id, cita_id, paciente_id, medico_id,
    nombre_medicamento, principio_activo, concentracion,
    forma_farmaceutica, dosis, frecuencia, duracion_dias,
    cantidad, fecha_prescripcion
  )
  SELECT
    seq_medicamentos.NEXTVAL,
    c.cita_id, c.paciente_id, c.medico_id,
    CASE MOD(c.cita_id, 20)
      WHEN 0  THEN 'Metformina 500mg'      WHEN 1  THEN 'Losartan 50mg'
      WHEN 2  THEN 'Atorvastatina 20mg'    WHEN 3  THEN 'Omeprazol 20mg'
      WHEN 4  THEN 'Amoxicilina 500mg'     WHEN 5  THEN 'Ibuprofeno 400mg'
      WHEN 6  THEN 'Acetaminofen 500mg'    WHEN 7  THEN 'Enalapril 10mg'
      WHEN 8  THEN 'Amlodipino 5mg'        WHEN 9  THEN 'Metoprolol 50mg'
      WHEN 10 THEN 'Warfarina 5mg'         WHEN 11 THEN 'Furosemida 40mg'
      WHEN 12 THEN 'Levotiroxina 50mcg'    WHEN 13 THEN 'Alprazolam 0.5mg'
      WHEN 14 THEN 'Sertralina 50mg'       WHEN 15 THEN 'Fluoxetina 20mg'
      WHEN 16 THEN 'Ciprofloxacino 500mg'  WHEN 17 THEN 'Azitromicina 500mg'
      WHEN 18 THEN 'Dexametasona 4mg'      ELSE 'Prednisona 5mg'
    END,
    NULL,
    CASE MOD(c.cita_id, 4) WHEN 0 THEN '500mg' WHEN 1 THEN '250mg' WHEN 2 THEN '10mg' ELSE '50mg' END,
    CASE MOD(c.cita_id, 3) WHEN 0 THEN 'Tableta' WHEN 1 THEN 'Capsula' ELSE 'Jarabe' END,
    CASE MOD(c.cita_id, 4) WHEN 0 THEN '1 tableta' WHEN 1 THEN '2 tabletas' ELSE '1/2 tableta' END,
    CASE MOD(c.cita_id, 3) WHEN 0 THEN 'Cada 8 horas' WHEN 1 THEN 'Cada 12 horas' ELSE 'Cada 24 horas' END,
    MOD(c.cita_id, 25) + 5,
    MOD(c.cita_id, 50) + 10,
    c.fecha_cita
  FROM CITAS_MEDICAS c
  WHERE c.estado = 'ATENDIDA'
    AND MOD(c.cita_id, 10) < 7;
  v_count := SQL%ROWCOUNT;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('  Medicamentos: ' || v_count);

  -- -------------------------------------------------------
  -- 9. FACTURACION
  -- -------------------------------------------------------
  DBMS_OUTPUT.PUT_LINE('Generando facturacion...');
  INSERT INTO FACTURACION (
    factura_id, paciente_id, cita_id, numero_factura,
    fecha_factura, subtotal, descuento, iva, total,
    estado, metodo_pago, eps_facturado
  )
  SELECT
    seq_facturacion.NEXTVAL,
    c.paciente_id, c.cita_id,
    CASE WHEN MOD(c.cita_id, 33) = 0
      THEN 'FAC-2024-000001'
      ELSE 'FAC-' || TO_CHAR(c.fecha_cita, 'YYYY') || '-' ||
           LPAD(TO_CHAR(c.cita_id), 8, '0')
    END,
    c.fecha_cita,
    v_sub,
    CASE WHEN MOD(c.cita_id, 10) = 0 THEN ROUND(v_sub * 0.1, -2) ELSE 0 END,
    0,
    v_sub - CASE WHEN MOD(c.cita_id, 10) = 0 THEN ROUND(v_sub * 0.1, -2) ELSE 0 END,
    CASE
      WHEN c.fecha_cita > SYSDATE - 30  THEN 'PENDIENTE'
      WHEN MOD(c.cita_id, 15) = 0       THEN 'ANULADA'
      WHEN MOD(c.cita_id, 7)  = 0       THEN 'PARCIAL'
      ELSE 'PAGADA'
    END,
    CASE MOD(c.cita_id, 4)
      WHEN 0 THEN 'EFECTIVO'      WHEN 1 THEN 'TARJETA'
      WHEN 2 THEN 'TRANSFERENCIA' ELSE 'EPS'
    END,
    NULL
  FROM (
    SELECT cita_id, paciente_id, fecha_cita, estado,
           ROUND(DBMS_RANDOM.VALUE(30000, 500000), -3) AS v_sub
    FROM CITAS_MEDICAS
    WHERE estado IN ('ATENDIDA','NO_ASISTIO')
  ) c;
  v_count := SQL%ROWCOUNT;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('  Facturas: ' || v_count);

  -- -------------------------------------------------------
  -- RESUMEN FINAL
  -- -------------------------------------------------------
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('=== GENERACION BULK COMPLETADA ===');
  FOR rec IN (
    SELECT 'MUNICIPIOS'              AS tabla, COUNT(*) AS total FROM MUNICIPIOS              UNION ALL
    SELECT 'ESPECIALIDADES',                   COUNT(*)          FROM ESPECIALIDADES           UNION ALL
    SELECT 'MEDICOS',                          COUNT(*)          FROM MEDICOS                  UNION ALL
    SELECT 'PACIENTES',                        COUNT(*)          FROM PACIENTES                UNION ALL
    SELECT 'INTERNACIONES',                    COUNT(*)          FROM INTERNACIONES            UNION ALL
    SELECT 'CITAS_MEDICAS',                    COUNT(*)          FROM CITAS_MEDICAS            UNION ALL
    SELECT 'EXAMENES_MEDICOS',                 COUNT(*)          FROM EXAMENES_MEDICOS         UNION ALL
    SELECT 'RESULTADOS_EXAMENES',              COUNT(*)          FROM RESULTADOS_EXAMENES      UNION ALL
    SELECT 'MEDICAMENTOS_RECETADOS',           COUNT(*)          FROM MEDICAMENTOS_RECETADOS   UNION ALL
    SELECT 'FACTURACION',                      COUNT(*)          FROM FACTURACION
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('  ' || RPAD(rec.tabla, 25) || ': ' || TO_CHAR(rec.total, '999,999,999'));
  END LOOP;

END generar_datos_hospital_bulk;
/

-- ============================================================
-- 7. VISTAS DE VERIFICACION
-- ============================================================

CREATE OR REPLACE VIEW v_resumen_tablas AS
SELECT 'MUNICIPIOS'              AS tabla, COUNT(*) AS total_filas FROM MUNICIPIOS              UNION ALL
SELECT 'ESPECIALIDADES',                   COUNT(*)               FROM ESPECIALIDADES           UNION ALL
SELECT 'MEDICOS',                          COUNT(*)               FROM MEDICOS                  UNION ALL
SELECT 'PACIENTES',                        COUNT(*)               FROM PACIENTES                UNION ALL
SELECT 'INTERNACIONES',                    COUNT(*)               FROM INTERNACIONES            UNION ALL
SELECT 'CITAS_MEDICAS',                    COUNT(*)               FROM CITAS_MEDICAS            UNION ALL
SELECT 'EXAMENES_MEDICOS',                 COUNT(*)               FROM EXAMENES_MEDICOS         UNION ALL
SELECT 'RESULTADOS_EXAMENES',              COUNT(*)               FROM RESULTADOS_EXAMENES      UNION ALL
SELECT 'MEDICAMENTOS_RECETADOS',           COUNT(*)               FROM MEDICAMENTOS_RECETADOS   UNION ALL
SELECT 'FACTURACION',                      COUNT(*)               FROM FACTURACION;

CREATE OR REPLACE VIEW v_problemas_calidad AS
SELECT 'PACIENTES' tabla, 'apellidos IS NULL' problema, COUNT(*) afectados
FROM PACIENTES WHERE apellidos IS NULL
UNION ALL
SELECT 'PACIENTES', 'sexo fuera de dominio',
  COUNT(*) FROM PACIENTES WHERE sexo NOT IN ('M','F','X') OR sexo IS NULL
UNION ALL
SELECT 'MEDICOS', 'email sin @',
  COUNT(*) FROM MEDICOS WHERE email IS NOT NULL AND email NOT LIKE '%@%'
UNION ALL
SELECT 'CITAS_MEDICAS', 'hora_cita formato invalido',
  COUNT(*) FROM CITAS_MEDICAS
  WHERE hora_cita IS NOT NULL AND NOT REGEXP_LIKE(hora_cita, '^\d{2}:\d{2}$')
UNION ALL
SELECT 'FACTURACION', 'numero_factura duplicado',
  COUNT(*) FROM (
    SELECT numero_factura FROM FACTURACION
    WHERE numero_factura IS NOT NULL
    GROUP BY numero_factura HAVING COUNT(*) > 1
  )
UNION ALL
SELECT 'ESPECIALIDADES', 'codigo_rips duplicado',
  COUNT(*) FROM (
    SELECT codigo_rips FROM ESPECIALIDADES
    WHERE codigo_rips IS NOT NULL
    GROUP BY codigo_rips HAVING COUNT(*) > 1
  )
UNION ALL
SELECT 'MUNICIPIOS', 'codigo_dane IS NULL',
  COUNT(*) FROM MUNICIPIOS WHERE codigo_dane IS NULL
UNION ALL
SELECT 'MEDICAMENTOS_RECETADOS', 'principio_activo IS NULL',
  COUNT(*) FROM MEDICAMENTOS_RECETADOS WHERE principio_activo IS NULL
UNION ALL
SELECT 'FACTURACION', 'eps_facturado IS NULL',
  COUNT(*) FROM FACTURACION WHERE eps_facturado IS NULL;

-- ============================================================
-- 8. EJECUTAR GENERACION
-- ============================================================
SET SERVEROUTPUT ON SIZE 1000000;

BEGIN
  generar_datos_hospital_bulk(
    p_num_medicos    => 200,
    p_num_pacientes  => 100000,
    p_anios_historia => 5
  );
END;
/

EXIT;