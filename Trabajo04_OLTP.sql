USE InmobiliariaDB;
GO

CREATE TABLE Cliente (
    DNI_RUC         VARCHAR(15)     NOT NULL,
    Nombre_completo NVARCHAR(150)   NOT NULL,
    Telefono        VARCHAR(15)     NULL,
    CONSTRAINT PK_Cliente PRIMARY KEY (DNI_RUC)
);
GO

CREATE TABLE Proyecto (
    Cod_proyecto    VARCHAR(10)     NOT NULL,
    Nombre          NVARCHAR(100)   NOT NULL,
    Distrito        NVARCHAR(80)    NULL,
    CONSTRAINT PK_Proyecto PRIMARY KEY (Cod_proyecto)
);
GO

CREATE TABLE Cliente_Proyecto (
    DNI_RUC         VARCHAR(15)     NOT NULL,
    Cod_proyecto    VARCHAR(10)     NOT NULL,
    Fecha_contacto  DATE            NULL,
    CONSTRAINT PK_Cliente_Proyecto  PRIMARY KEY (DNI_RUC, Cod_proyecto),
    CONSTRAINT FK_CP_Cliente        FOREIGN KEY (DNI_RUC)      REFERENCES Cliente(DNI_RUC),
    CONSTRAINT FK_CP_Proyecto       FOREIGN KEY (Cod_proyecto) REFERENCES Proyecto(Cod_proyecto)
);
GO

CREATE TABLE Asesor (
    ID_asesor       INT             NOT NULL IDENTITY(1,1),
    Nombre          NVARCHAR(150)   NOT NULL,
    CONSTRAINT PK_Asesor PRIMARY KEY (ID_asesor)
);
GO

CREATE TABLE Unidad_Inmobiliaria (
    Cod_unidad      VARCHAR(10)     NOT NULL,
    Estado          NVARCHAR(20)    NOT NULL DEFAULT 'Disponible',
    Area_m2         DECIMAL(8,2)    NOT NULL,
    Precio_lista    DECIMAL(12,2)   NOT NULL,
    Cod_proyecto    VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_Unidad            PRIMARY KEY (Cod_unidad),
    CONSTRAINT FK_Unidad_Proyecto   FOREIGN KEY (Cod_proyecto) REFERENCES Proyecto(Cod_proyecto),
    CONSTRAINT CHK_Estado_Unidad    CHECK (Estado IN ('Disponible','Reservado','Vendido'))
);
GO

CREATE TABLE Lead (
    ID_lead         INT             NOT NULL IDENTITY(1,1),
    Fuente_origen   NVARCHAR(50)    NULL,
    Etapa_funnel    NVARCHAR(50)    NULL,
    ID_asesor       INT             NOT NULL,
    DNI_RUC         VARCHAR(15)     NOT NULL,
    CONSTRAINT PK_Lead              PRIMARY KEY (ID_lead),
    CONSTRAINT FK_Lead_Asesor       FOREIGN KEY (ID_asesor) REFERENCES Asesor(ID_asesor),
    CONSTRAINT FK_Lead_Cliente      FOREIGN KEY (DNI_RUC)   REFERENCES Cliente(DNI_RUC)
);
GO

CREATE TABLE Reserva (
    Num_reserva     VARCHAR(10)     NOT NULL,
    Fecha_reserva   DATE            NOT NULL,
    Monto_reserva   DECIMAL(12,2)   NOT NULL,
    ID_lead         INT             NOT NULL,
    Cod_unidad      VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_Reserva           PRIMARY KEY (Num_reserva),
    CONSTRAINT FK_Reserva_Lead      FOREIGN KEY (ID_lead)    REFERENCES Lead(ID_lead),
    CONSTRAINT FK_Reserva_Unidad    FOREIGN KEY (Cod_unidad) REFERENCES Unidad_Inmobiliaria(Cod_unidad)
);
GO

CREATE TABLE Contrato (
    Num_contrato        VARCHAR(10)     NOT NULL,
    Fecha_firma         DATE            NOT NULL,
    Tipo_financiamiento NVARCHAR(30)    NOT NULL,
    Precio_venta        DECIMAL(12,2)   NOT NULL,
    Num_reserva         VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_Contrato              PRIMARY KEY (Num_contrato),
    CONSTRAINT FK_Contrato_Reserva      FOREIGN KEY (Num_reserva) REFERENCES Reserva(Num_reserva),
    CONSTRAINT UQ_Contrato_Reserva      UNIQUE (Num_reserva),
    CONSTRAINT CHK_Tipo_Financiamiento  CHECK (Tipo_financiamiento IN ('Contado','Credito hipotecario','Cuotas propias'))
);
GO

CREATE TABLE Cuota (
    Num_cuota           INT             NOT NULL,
    Num_contrato        VARCHAR(10)     NOT NULL,
    Monto_cuota         DECIMAL(12,2)   NOT NULL,
    Fecha_vencimiento   DATE            NOT NULL,
    Estado              NVARCHAR(20)    NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT PK_Cuota             PRIMARY KEY (Num_cuota, Num_contrato),
    CONSTRAINT FK_Cuota_Contrato    FOREIGN KEY (Num_contrato) REFERENCES Contrato(Num_contrato),
    CONSTRAINT CHK_Estado_Cuota     CHECK (Estado IN ('Pendiente','Pagado','Vencido'))
);
GO

INSERT INTO Cliente VALUES ('12345678',    'Juan Perez Lopez',         '987654321');
INSERT INTO Cliente VALUES ('87654321',    'Maria Garcia Torres',      '976543210');
INSERT INTO Cliente VALUES ('20512345678', 'Corporacion ABC SAC',      '014567890');
INSERT INTO Cliente VALUES ('45678912',    'Carlos Mendoza Rivera',    '965432109');
INSERT INTO Cliente VALUES ('78912345',    'Ana Flores Huaman',        '954321098');
INSERT INTO Cliente VALUES ('32165498',    'Roberto Silva Castillo',   '943210987');
INSERT INTO Cliente VALUES ('65498732',    'Lucia Rojas Paredes',      '932109876');
INSERT INTO Cliente VALUES ('20698741236', 'Inversiones XYZ EIRL',     '012345678');
GO

INSERT INTO Proyecto VALUES ('PROY001', 'Residencial Los Olivos',   'Los Olivos');
INSERT INTO Proyecto VALUES ('PROY002', 'Torre Miraflores',         'Miraflores');
INSERT INTO Proyecto VALUES ('PROY003', 'Condominio San Borja',     'San Borja');
INSERT INTO Proyecto VALUES ('PROY004', 'Edificio Surco Center',    'Santiago de Surco');
INSERT INTO Proyecto VALUES ('PROY005', 'Park View Barranco',       'Barranco');
INSERT INTO Proyecto VALUES ('PROY006', 'Residencial La Molina',    'La Molina');
GO

INSERT INTO Asesor (Nombre) VALUES ('Carlos Mendoza Quispe');
INSERT INTO Asesor (Nombre) VALUES ('Ana Flores Vargas');
INSERT INTO Asesor (Nombre) VALUES ('Luis Torres Salas');
INSERT INTO Asesor (Nombre) VALUES ('Patricia Ramos Diaz');
INSERT INTO Asesor (Nombre) VALUES ('Jorge Vasquez Leon');
INSERT INTO Asesor (Nombre) VALUES ('Sofia Huaman Cruz');
GO

INSERT INTO Unidad_Inmobiliaria VALUES ('U001', 'Vendido',    75.50,  185000.00, 'PROY001');
INSERT INTO Unidad_Inmobiliaria VALUES ('U002', 'Reservado',  62.00,  155000.00, 'PROY001');
INSERT INTO Unidad_Inmobiliaria VALUES ('U003', 'Disponible', 88.00,  210000.00, 'PROY001');
INSERT INTO Unidad_Inmobiliaria VALUES ('U004', 'Vendido',   120.00,  320000.00, 'PROY002');
INSERT INTO Unidad_Inmobiliaria VALUES ('U005', 'Disponible',  95.00, 280000.00, 'PROY002');
INSERT INTO Unidad_Inmobiliaria VALUES ('U006', 'Reservado',   70.00, 195000.00, 'PROY003');
INSERT INTO Unidad_Inmobiliaria VALUES ('U007', 'Disponible',  65.00, 175000.00, 'PROY003');
INSERT INTO Unidad_Inmobiliaria VALUES ('U008', 'Vendido',    110.00, 350000.00, 'PROY004');
INSERT INTO Unidad_Inmobiliaria VALUES ('U009', 'Disponible',  80.00, 220000.00, 'PROY004');
INSERT INTO Unidad_Inmobiliaria VALUES ('U010', 'Reservado',   55.00, 145000.00, 'PROY005');
INSERT INTO Unidad_Inmobiliaria VALUES ('U011', 'Disponible', 135.00, 420000.00, 'PROY006');
INSERT INTO Unidad_Inmobiliaria VALUES ('U012', 'Vendido',     90.00, 260000.00, 'PROY006');
GO

INSERT INTO Cliente_Proyecto VALUES ('12345678',    'PROY001', '2026-01-05');
INSERT INTO Cliente_Proyecto VALUES ('12345678',    'PROY002', '2026-01-20');
INSERT INTO Cliente_Proyecto VALUES ('87654321',    'PROY001', '2026-01-10');
INSERT INTO Cliente_Proyecto VALUES ('87654321',    'PROY003', '2026-02-01');
INSERT INTO Cliente_Proyecto VALUES ('20512345678', 'PROY004', '2026-02-10');
INSERT INTO Cliente_Proyecto VALUES ('45678912',    'PROY002', '2026-02-15');
INSERT INTO Cliente_Proyecto VALUES ('78912345',    'PROY005', '2026-03-01');
INSERT INTO Cliente_Proyecto VALUES ('32165498',    'PROY006', '2026-03-10');
INSERT INTO Cliente_Proyecto VALUES ('65498732',    'PROY003', '2026-03-15');
INSERT INTO Cliente_Proyecto VALUES ('20698741236', 'PROY004', '2026-04-01');
GO

INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Web',          'Contacto inicial',  1, '12345678');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Feria',        'Negociacion',       1, '12345678');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Referido',     'Cierre',            2, '87654321');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Redes sociales','Contacto inicial', 2, '87654321');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Web',          'Negociacion',       3, '20512345678');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Feria',        'Cierre',            3, '45678912');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Referido',     'Contacto inicial',  4, '45678912');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Web',          'Negociacion',       4, '78912345');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Redes sociales','Cierre',           5, '78912345');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Feria',        'Contacto inicial',  5, '32165498');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Web',          'Negociacion',       6, '32165498');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Referido',     'Cierre',            6, '65498732');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Web',          'Contacto inicial',  1, '65498732');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Feria',        'Negociacion',       2, '20698741236');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Redes sociales','Cierre',           3, '20698741236');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Web',          'Contacto inicial',  4, '12345678');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Referido',     'Negociacion',       5, '87654321');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Feria',        'Cierre',            6, '45678912');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Web',          'Contacto inicial',  1, '78912345');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Redes sociales','Negociacion',      2, '32165498');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Referido',     'Cierre',            3, '65498732');
INSERT INTO Lead (Fuente_origen, Etapa_funnel, ID_asesor, DNI_RUC) VALUES ('Web',          'Negociacion',       4, '20698741236');
GO

INSERT INTO Reserva VALUES ('RES001', '2026-01-10', 5000.00,  2,  'U001');
INSERT INTO Reserva VALUES ('RES002', '2026-01-15', 5000.00,  3,  'U004');
INSERT INTO Reserva VALUES ('RES003', '2026-01-20', 4000.00,  6,  'U008');
INSERT INTO Reserva VALUES ('RES004', '2026-02-01', 5000.00,  9,  'U012');
INSERT INTO Reserva VALUES ('RES005', '2026-02-05', 4500.00,  12, 'U002');
INSERT INTO Reserva VALUES ('RES006', '2026-02-10', 5000.00,  5,  'U006');
INSERT INTO Reserva VALUES ('RES007', '2026-02-15', 4000.00,  8,  'U010');
INSERT INTO Reserva VALUES ('RES008', '2026-02-20', 5000.00,  11, 'U003');
INSERT INTO Reserva VALUES ('RES009', '2026-03-01', 6000.00,  15, 'U005');
INSERT INTO Reserva VALUES ('RES010', '2026-03-05', 5000.00,  18, 'U007');
INSERT INTO Reserva VALUES ('RES011', '2026-03-10', 4500.00,  21, 'U009');
INSERT INTO Reserva VALUES ('RES012', '2026-03-15', 5000.00,  1,  'U011');
INSERT INTO Reserva VALUES ('RES013', '2026-03-20', 4000.00,  4,  'U001');
INSERT INTO Reserva VALUES ('RES014', '2026-03-25', 5000.00,  7,  'U004');
INSERT INTO Reserva VALUES ('RES015', '2026-04-01', 4500.00,  10, 'U008');
INSERT INTO Reserva VALUES ('RES016', '2026-04-05', 5000.00,  13, 'U012');
INSERT INTO Reserva VALUES ('RES017', '2026-04-10', 4000.00,  16, 'U002');
INSERT INTO Reserva VALUES ('RES018', '2026-04-15', 5000.00,  19, 'U006');
INSERT INTO Reserva VALUES ('RES019', '2026-04-20', 4500.00,  22, 'U010');
INSERT INTO Reserva VALUES ('RES020', '2026-04-25', 5000.00,  14, 'U003');
GO

INSERT INTO Contrato VALUES ('CON001', '2026-01-20', 'Credito hipotecario', 185000.00, 'RES001');
INSERT INTO Contrato VALUES ('CON002', '2026-01-25', 'Contado',             320000.00, 'RES002');
INSERT INTO Contrato VALUES ('CON003', '2026-01-30', 'Cuotas propias',      350000.00, 'RES003');
INSERT INTO Contrato VALUES ('CON004', '2026-02-10', 'Credito hipotecario', 260000.00, 'RES004');
INSERT INTO Contrato VALUES ('CON005', '2026-02-15', 'Cuotas propias',      155000.00, 'RES005');
INSERT INTO Contrato VALUES ('CON006', '2026-02-20', 'Credito hipotecario', 195000.00, 'RES006');
INSERT INTO Contrato VALUES ('CON007', '2026-02-25', 'Contado',             145000.00, 'RES007');
INSERT INTO Contrato VALUES ('CON008', '2026-03-05', 'Cuotas propias',      210000.00, 'RES008');
INSERT INTO Contrato VALUES ('CON009', '2026-03-10', 'Credito hipotecario', 280000.00, 'RES009');
INSERT INTO Contrato VALUES ('CON010', '2026-03-15', 'Cuotas propias',      175000.00, 'RES010');
INSERT INTO Contrato VALUES ('CON011', '2026-03-20', 'Credito hipotecario', 220000.00, 'RES011');
INSERT INTO Contrato VALUES ('CON012', '2026-03-25', 'Contado',             420000.00, 'RES012');
INSERT INTO Contrato VALUES ('CON013', '2026-03-28', 'Cuotas propias',      185000.00, 'RES013');
INSERT INTO Contrato VALUES ('CON014', '2026-04-02', 'Credito hipotecario', 320000.00, 'RES014');
INSERT INTO Contrato VALUES ('CON015', '2026-04-07', 'Cuotas propias',      350000.00, 'RES015');
INSERT INTO Contrato VALUES ('CON016', '2026-04-12', 'Credito hipotecario', 260000.00, 'RES016');
INSERT INTO Contrato VALUES ('CON017', '2026-04-17', 'Cuotas propias',      155000.00, 'RES017');
INSERT INTO Contrato VALUES ('CON018', '2026-04-22', 'Credito hipotecario', 195000.00, 'RES018');
INSERT INTO Contrato VALUES ('CON019', '2026-04-27', 'Contado',             145000.00, 'RES019');
INSERT INTO Contrato VALUES ('CON020', '2026-04-30', 'Cuotas propias',      210000.00, 'RES020');
GO

INSERT INTO Cuota VALUES (1, 'CON001', 1850.00, '2026-03-01', 'Pagado');
INSERT INTO Cuota VALUES (2, 'CON001', 1850.00, '2026-04-01', 'Pagado');
INSERT INTO Cuota VALUES (3, 'CON001', 1850.00, '2026-05-01', 'Pendiente');

INSERT INTO Cuota VALUES (1, 'CON003', 3500.00, '2026-03-01', 'Pagado');
INSERT INTO Cuota VALUES (2, 'CON003', 3500.00, '2026-04-01', 'Pagado');
INSERT INTO Cuota VALUES (3, 'CON003', 3500.00, '2026-05-01', 'Pendiente');

INSERT INTO Cuota VALUES (1, 'CON004', 2600.00, '2026-03-15', 'Pagado');
INSERT INTO Cuota VALUES (2, 'CON004', 2600.00, '2026-04-15', 'Pagado');
INSERT INTO Cuota VALUES (3, 'CON004', 2600.00, '2026-05-15', 'Pendiente');

INSERT INTO Cuota VALUES (1, 'CON005', 1550.00, '2026-03-20', 'Pagado');
INSERT INTO Cuota VALUES (2, 'CON005', 1550.00, '2026-04-20', 'Vencido');
INSERT INTO Cuota VALUES (3, 'CON005', 1550.00, '2026-05-20', 'Pendiente');

INSERT INTO Cuota VALUES (1, 'CON006', 1950.00, '2026-03-25', 'Pagado');
INSERT INTO Cuota VALUES (2, 'CON006', 1950.00, '2026-04-25', 'Pendiente');
INSERT INTO Cuota VALUES (3, 'CON006', 1950.00, '2026-05-25', 'Pendiente');

INSERT INTO Cuota VALUES (1, 'CON008', 2100.00, '2026-04-10', 'Pagado');
INSERT INTO Cuota VALUES (2, 'CON008', 2100.00, '2026-05-10', 'Pendiente');
INSERT INTO Cuota VALUES (3, 'CON008', 2100.00, '2026-06-10', 'Pendiente');

INSERT INTO Cuota VALUES (1, 'CON009', 2800.00, '2026-04-15', 'Pagado');
INSERT INTO Cuota VALUES (2, 'CON009', 2800.00, '2026-05-15', 'Pendiente');
INSERT INTO Cuota VALUES (3, 'CON009', 2800.00, '2026-06-15', 'Pendiente');

INSERT INTO Cuota VALUES (1, 'CON010', 1750.00, '2026-04-20', 'Pendiente');
INSERT INTO Cuota VALUES (2, 'CON010', 1750.00, '2026-05-20', 'Pendiente');
INSERT INTO Cuota VALUES (3, 'CON010', 1750.00, '2026-06-20', 'Pendiente');
GO

SELECT 'Cliente'             AS Tabla, COUNT(*) AS Registros FROM Cliente
UNION ALL
SELECT 'Proyecto',                     COUNT(*) FROM Proyecto
UNION ALL
SELECT 'Asesor',                       COUNT(*) FROM Asesor
UNION ALL
SELECT 'Unidad_Inmobiliaria',          COUNT(*) FROM Unidad_Inmobiliaria
UNION ALL
SELECT 'Cliente_Proyecto',             COUNT(*) FROM Cliente_Proyecto
UNION ALL
SELECT 'Lead',                         COUNT(*) FROM Lead
UNION ALL
SELECT 'Reserva',                      COUNT(*) FROM Reserva
UNION ALL
SELECT 'Contrato',                     COUNT(*) FROM Contrato
UNION ALL
SELECT 'Cuota',                        COUNT(*) FROM Cuota;
GO
