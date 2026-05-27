-- =============================================
-- MODELO FISICO - AREA COMERCIAL INMOBILIARIA
-- Trabajo 03 - PEDAN 7: Modelamiento de Datos con SQL
-- Motor: SQL Server
-- Autor: Fernando
-- Fecha: Mayo 2026
-- =============================================

-- =============================================
-- CREACION DE TABLAS
-- =============================================

-- 1. CLIENTE
CREATE TABLE Cliente (
    DNI_RUC         VARCHAR(15)     NOT NULL,
    Nombre_completo NVARCHAR(150)   NOT NULL,
    Telefono        VARCHAR(15)     NULL,
    CONSTRAINT PK_Cliente PRIMARY KEY (DNI_RUC)
);

-- 2. PROYECTO
CREATE TABLE Proyecto (
    Cod_proyecto    VARCHAR(10)     NOT NULL,
    Nombre          NVARCHAR(100)   NOT NULL,
    Distrito        NVARCHAR(80)    NULL,
    CONSTRAINT PK_Proyecto PRIMARY KEY (Cod_proyecto)
);

-- 3. CLIENTE_PROYECTO (resuelve relacion N:M entre Cliente y Proyecto)
CREATE TABLE Cliente_Proyecto (
    DNI_RUC         VARCHAR(15)     NOT NULL,
    Cod_proyecto    VARCHAR(10)     NOT NULL,
    Fecha_contacto  DATE            NULL,
    CONSTRAINT PK_Cliente_Proyecto  PRIMARY KEY (DNI_RUC, Cod_proyecto),
    CONSTRAINT FK_CP_Cliente        FOREIGN KEY (DNI_RUC)
        REFERENCES Cliente(DNI_RUC),
    CONSTRAINT FK_CP_Proyecto       FOREIGN KEY (Cod_proyecto)
        REFERENCES Proyecto(Cod_proyecto)
);

-- 4. ASESOR
CREATE TABLE Asesor (
    ID_asesor       INT             NOT NULL IDENTITY(1,1),
    Nombre          NVARCHAR(150)   NOT NULL,
    CONSTRAINT PK_Asesor PRIMARY KEY (ID_asesor)
);

-- 5. UNIDAD INMOBILIARIA
CREATE TABLE Unidad_Inmobiliaria (
    Cod_unidad      VARCHAR(10)     NOT NULL,
    Estado          NVARCHAR(20)    NOT NULL DEFAULT 'Disponible',
    Area_m2         DECIMAL(8,2)    NOT NULL,
    Precio_lista    DECIMAL(12,2)   NOT NULL,
    Cod_proyecto    VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_Unidad            PRIMARY KEY (Cod_unidad),
    CONSTRAINT FK_Unidad_Proyecto   FOREIGN KEY (Cod_proyecto)
        REFERENCES Proyecto(Cod_proyecto),
    CONSTRAINT CHK_Estado_Unidad    CHECK (Estado IN ('Disponible', 'Reservado', 'Vendido'))
);

-- 6. LEAD
CREATE TABLE Lead (
    ID_lead         INT             NOT NULL IDENTITY(1,1),
    Fuente_origen   NVARCHAR(50)    NULL,
    Etapa_funnel    NVARCHAR(50)    NULL,
    ID_asesor       INT             NOT NULL,
    DNI_RUC         VARCHAR(15)     NOT NULL,
    CONSTRAINT PK_Lead              PRIMARY KEY (ID_lead),
    CONSTRAINT FK_Lead_Asesor       FOREIGN KEY (ID_asesor)
        REFERENCES Asesor(ID_asesor),
    CONSTRAINT FK_Lead_Cliente      FOREIGN KEY (DNI_RUC)
        REFERENCES Cliente(DNI_RUC)
);

-- 7. RESERVA
CREATE TABLE Reserva (
    Num_reserva     VARCHAR(10)     NOT NULL,
    Fecha_reserva   DATE            NOT NULL,
    Monto_reserva   DECIMAL(12,2)   NOT NULL,
    ID_lead         INT             NOT NULL,
    Cod_unidad      VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_Reserva           PRIMARY KEY (Num_reserva),
    CONSTRAINT FK_Reserva_Lead      FOREIGN KEY (ID_lead)
        REFERENCES Lead(ID_lead),
    CONSTRAINT FK_Reserva_Unidad    FOREIGN KEY (Cod_unidad)
        REFERENCES Unidad_Inmobiliaria(Cod_unidad)
);

-- 8. CONTRATO
CREATE TABLE Contrato (
    Num_contrato        VARCHAR(10)     NOT NULL,
    Fecha_firma         DATE            NOT NULL,
    Tipo_financiamiento NVARCHAR(30)    NOT NULL,
    Precio_venta        DECIMAL(12,2)   NOT NULL,
    Num_reserva         VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_Contrato              PRIMARY KEY (Num_contrato),
    CONSTRAINT FK_Contrato_Reserva      FOREIGN KEY (Num_reserva)
        REFERENCES Reserva(Num_reserva),
    CONSTRAINT UQ_Contrato_Reserva      UNIQUE (Num_reserva),  -- garantiza relacion 1:1
    CONSTRAINT CHK_Tipo_Financiamiento  CHECK (Tipo_financiamiento IN (
        'Contado', 'Credito hipotecario', 'Cuotas propias'))
);

-- 9. CUOTA
CREATE TABLE Cuota (
    Num_cuota           INT             NOT NULL,
    Num_contrato        VARCHAR(10)     NOT NULL,
    Monto_cuota         DECIMAL(12,2)   NOT NULL,
    Fecha_vencimiento   DATE            NOT NULL,
    Estado              NVARCHAR(20)    NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT PK_Cuota             PRIMARY KEY (Num_cuota, Num_contrato),
    CONSTRAINT FK_Cuota_Contrato    FOREIGN KEY (Num_contrato)
        REFERENCES Contrato(Num_contrato),
    CONSTRAINT CHK_Estado_Cuota     CHECK (Estado IN ('Pendiente', 'Pagado', 'Vencido'))
);

-- =============================================
-- DATOS DE PRUEBA
-- =============================================

-- Clientes
INSERT INTO Cliente VALUES ('12345678', 'Juan Perez Lopez', '987654321');
INSERT INTO Cliente VALUES ('87654321', 'Maria Garcia Torres', '976543210');
INSERT INTO Cliente VALUES ('20512345678', 'Empresa SAC', '014567890');

-- Proyectos
INSERT INTO Proyecto VALUES ('PROY001', 'Residencial Los Olivos', 'Los Olivos');
INSERT INTO Proyecto VALUES ('PROY002', 'Torre Miraflores', 'Miraflores');

-- Cliente_Proyecto
INSERT INTO Cliente_Proyecto VALUES ('12345678', 'PROY001', '2026-01-10');
INSERT INTO Cliente_Proyecto VALUES ('87654321', 'PROY001', '2026-01-15');
INSERT INTO Cliente_Proyecto VALUES ('87654321', 'PROY002', '2026-02-01');

-- Asesores
INSERT INTO Asesor (Nombre) VALUES ('Carlos Mendoza');
INSERT INTO Asesor (Nombre) VALUES ('Ana Flores');

-- Unidades Inmobiliarias
INSERT INTO Unidad_Inmobiliaria VALUES ('U001', 'Reservado', 75.50, 185000.00, 'PROY001');
INSERT INTO Unidad_Inmobiliaria VALUES ('U002', 'Disponible', 62.00, 155000.00, 'PROY001');
INSERT INTO Unidad_Inmobiliaria VALUES ('U003', 'Vendido', 90.00, 320000.00, 'PROY002');

-- Leads
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC)
VALUES ('Web', 'Negociacion', 1, '12345678');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC)
VALUES ('Feria', 'Contacto inicial', 2, '87654321');

-- Reservas
INSERT INTO Reserva VALUES ('RES001', '2026-02-10', 5000.00, 1, 'U001');

-- Contratos
INSERT INTO Contrato VALUES ('CON001', '2026-03-01', 'Credito hipotecario', 185000.00, 'RES001');

-- Cuotas
INSERT INTO Cuota VALUES (1, 'CON001', 1850.00, '2026-04-01', 'Pagado');
INSERT INTO Cuota VALUES (2, 'CON001', 1850.00, '2026-05-01', 'Pagado');
INSERT INTO Cuota VALUES (3, 'CON001', 1850.00, '2026-06-01', 'Pendiente');

-- =============================================
-- CONSULTAS DE VERIFICACION
-- =============================================

-- Ver todos los leads con su asesor y cliente
SELECT
    l.ID_lead,
    c.Nombre_completo   AS Cliente,
    a.Nombre            AS Asesor,
    l.Fuente_origen,
    l.Etapa_funnel
FROM Lead l
JOIN Cliente c ON l.DNI_RUC = c.DNI_RUC
JOIN Asesor  a ON l.ID_asesor = a.ID_asesor;

-- Ver reservas con unidad y proyecto
SELECT
    r.Num_reserva,
    r.Fecha_reserva,
    r.Monto_reserva,
    u.Cod_unidad,
    u.Area_m2,
    p.Nombre AS Proyecto,
    p.Distrito
FROM Reserva r
JOIN Unidad_Inmobiliaria u ON r.Cod_unidad = u.Cod_unidad
JOIN Proyecto p             ON u.Cod_proyecto = p.Cod_proyecto;

-- Ver cronograma de cuotas por contrato
SELECT
    c.Num_contrato,
    c.Tipo_financiamiento,
    c.Precio_venta,
    cu.Num_cuota,
    cu.Monto_cuota,
    cu.Fecha_vencimiento,
    cu.Estado
FROM Contrato c
JOIN Cuota cu ON c.Num_contrato = cu.Num_contrato
ORDER BY c.Num_contrato, cu.Num_cuota;
