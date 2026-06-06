USE InmobiliariaDB;
GO

-- PARTE 1: CONSULTAS BASICAS E INTERMEDIAS

-- 1. Listar todos los clientes registrados
SELECT DNI_RUC, Nombre_completo, Telefono
FROM Cliente;

-- 2. Listar todos los proyectos con su distrito
SELECT Cod_proyecto, Nombre, Distrito
FROM Proyecto;

-- 3. Mostrar todas las unidades inmobiliarias disponibles
SELECT Cod_unidad, Area_m2, Precio_lista, Cod_proyecto
FROM Unidad_Inmobiliaria
WHERE Estado = 'Disponible';

-- 4. Contar cuántos leads hay por etapa del funnel
SELECT Etapa_funnel, COUNT(*) AS Total_leads
FROM Lead
GROUP BY Etapa_funnel;

-- 5. Listar reservas ordenadas por fecha descendente
SELECT Num_reserva, Fecha_reserva, Monto_reserva, Cod_unidad
FROM Reserva
ORDER BY Fecha_reserva DESC;

-- 6. Mostrar clientes con su proyecto de interés
SELECT c.Nombre_completo, p.Nombre AS Proyecto,
       cp.Fecha_contacto
FROM Cliente_Proyecto cp
JOIN Cliente  c ON cp.DNI_RUC      = c.DNI_RUC
JOIN Proyecto p ON cp.Cod_proyecto = p.Cod_proyecto;

-- 7. Listar leads con el nombre del asesor asignado
SELECT l.ID_lead, c.Nombre_completo AS Cliente,
       a.Nombre AS Asesor, l.Fuente_origen, l.Etapa_funnel
FROM Lead l
JOIN Asesor  a ON l.ID_asesor = a.ID_asesor
JOIN Cliente c ON l.DNI_RUC   = c.DNI_RUC;

-- 8. Precio promedio, mínimo y máximo de unidades por proyecto
SELECT p.Nombre AS Proyecto,
       AVG(u.Precio_lista) AS Precio_Promedio,
       MIN(u.Precio_lista) AS Precio_Minimo,
       MAX(u.Precio_lista) AS Precio_Maximo
FROM Unidad_Inmobiliaria u
JOIN Proyecto p ON u.Cod_proyecto = p.Cod_proyecto
GROUP BY p.Nombre;

-- 9. Contratos con su tipo de financiamiento y datos del cliente
SELECT ct.Num_contrato, ct.Tipo_financiamiento,
       ct.Precio_venta, ct.Fecha_firma,
       c.Nombre_completo AS Cliente
FROM Contrato ct
JOIN Reserva  r ON ct.Num_reserva = r.Num_reserva
JOIN Lead     l ON r.ID_lead      = l.ID_lead
JOIN Cliente  c ON l.DNI_RUC      = c.DNI_RUC;

-- 10. Cuotas pendientes de pago ordenadas por fecha de vencimiento
SELECT cu.Num_cuota, cu.Num_contrato,
       cu.Monto_cuota, cu.Fecha_vencimiento
FROM Cuota cu
WHERE cu.Estado = 'Pendiente'
ORDER BY cu.Fecha_vencimiento;


-- PARTE 2: CONSULTAS AVANZADAS Y EXPERTAS

-- 11. Ranking de asesores por cantidad de leads asignados
SELECT a.Nombre AS Asesor,
       COUNT(l.ID_lead) AS Total_Leads,
       RANK() OVER (ORDER BY COUNT(l.ID_lead) DESC) AS Ranking
FROM Asesor a
LEFT JOIN Lead l ON a.ID_asesor = l.ID_asesor
GROUP BY a.ID_asesor, a.Nombre;

-- 12. Tasa de conversión de leads a reservas por asesor
SELECT a.Nombre AS Asesor,
       COUNT(DISTINCT l.ID_lead)     AS Total_Leads,
       COUNT(DISTINCT r.Num_reserva) AS Total_Reservas,
       CAST(
           COUNT(DISTINCT r.Num_reserva) * 100.0
           / NULLIF(COUNT(DISTINCT l.ID_lead), 0)
       AS DECIMAL(5,2))              AS Tasa_Conversion_Pct
FROM Asesor a
LEFT JOIN Lead    l ON a.ID_asesor = l.ID_asesor
LEFT JOIN Reserva r ON l.ID_lead   = r.ID_lead
GROUP BY a.ID_asesor, a.Nombre;

-- 13. Unidades vendidas vs disponibles vs reservadas por proyecto
SELECT p.Nombre AS Proyecto,
       COUNT(CASE WHEN u.Estado = 'Disponible' THEN 1 END) AS Disponibles,
       COUNT(CASE WHEN u.Estado = 'Reservado'  THEN 1 END) AS Reservadas,
       COUNT(CASE WHEN u.Estado = 'Vendido'    THEN 1 END) AS Vendidas,
       COUNT(*)                                             AS Total
FROM Proyecto p
JOIN Unidad_Inmobiliaria u ON p.Cod_proyecto = u.Cod_proyecto
GROUP BY p.Cod_proyecto, p.Nombre;

-- 14. CTE: clientes con más de una reserva activa
WITH Reservas_por_cliente AS (
    SELECT l.DNI_RUC, COUNT(*) AS Total_Reservas
    FROM Reserva r
    JOIN Lead l ON r.ID_lead = l.ID_lead
    GROUP BY l.DNI_RUC
)
SELECT c.Nombre_completo, rc.Total_Reservas
FROM Reservas_por_cliente rc
JOIN Cliente c ON rc.DNI_RUC = c.DNI_RUC
WHERE rc.Total_Reservas > 1;

-- 15. Ingresos totales por proyecto
SELECT p.Nombre AS Proyecto,
       SUM(ct.Precio_venta)   AS Ingresos_Totales,
       COUNT(ct.Num_contrato) AS Contratos_Firmados
FROM Contrato ct
JOIN Reserva             r  ON ct.Num_reserva = r.Num_reserva
JOIN Unidad_Inmobiliaria u  ON r.Cod_unidad   = u.Cod_unidad
JOIN Proyecto            p  ON u.Cod_proyecto = p.Cod_proyecto
GROUP BY p.Cod_proyecto, p.Nombre
ORDER BY Ingresos_Totales DESC;

-- 16. Cuotas vencidas con días de mora calculados a la fecha actual
SELECT cu.Num_cuota, cu.Num_contrato,
       cu.Monto_cuota, cu.Fecha_vencimiento,
       DATEDIFF(DAY, cu.Fecha_vencimiento, GETDATE()) AS Dias_Mora
FROM Cuota cu
WHERE cu.Estado = 'Pendiente'
  AND cu.Fecha_vencimiento < GETDATE()
ORDER BY Dias_Mora DESC;

-- 17. Window function: ventas acumuladas por mes y proyecto (CORREGIDA)
SELECT p.Nombre AS Proyecto,
       YEAR(ct.Fecha_firma)  AS Anio,
       MONTH(ct.Fecha_firma) AS Mes,
       SUM(ct.Precio_venta)  AS Ventas_Mes,
       SUM(SUM(ct.Precio_venta)) OVER (
           PARTITION BY p.Cod_proyecto
           ORDER BY YEAR(ct.Fecha_firma), MONTH(ct.Fecha_firma)
       ) AS Ventas_Acumuladas
FROM Contrato ct
JOIN Reserva             r  ON ct.Num_reserva = r.Num_reserva
JOIN Unidad_Inmobiliaria u  ON r.Cod_unidad   = u.Cod_unidad
JOIN Proyecto            p  ON u.Cod_proyecto = p.Cod_proyecto
GROUP BY p.Cod_proyecto, p.Nombre, 
         YEAR(ct.Fecha_firma), MONTH(ct.Fecha_firma);

-- 18. Subquery: clientes que tienen lead pero aún no tienen reserva
SELECT c.DNI_RUC, c.Nombre_completo
FROM Cliente c
WHERE EXISTS (
    SELECT 1 FROM Lead l WHERE l.DNI_RUC = c.DNI_RUC
)
AND NOT EXISTS (
    SELECT 1
    FROM Reserva r
    JOIN Lead l ON r.ID_lead = l.ID_lead
    WHERE l.DNI_RUC = c.DNI_RUC
);

-- 19. CTE recursiva: tabla de amortización acumulada por contrato
WITH Amortizacion AS (
    SELECT Num_contrato, Num_cuota, 
           CAST(Monto_cuota AS DECIMAL(12,2)) AS Monto_cuota,
           CAST(Monto_cuota AS DECIMAL(12,2)) AS Saldo_Pagado
    FROM Cuota
    WHERE Num_cuota = 1

    UNION ALL

    SELECT c.Num_contrato, c.Num_cuota,
           CAST(c.Monto_cuota AS DECIMAL(12,2)),
           CAST(a.Saldo_Pagado + c.Monto_cuota AS DECIMAL(12,2))
    FROM Cuota c
    JOIN Amortizacion a
        ON  c.Num_contrato = a.Num_contrato
        AND c.Num_cuota    = a.Num_cuota + 1
)
SELECT Num_contrato, Num_cuota,
       Monto_cuota, Saldo_Pagado
FROM Amortizacion
ORDER BY Num_contrato, Num_cuota;

-- 20. Reporte ejecutivo: resumen general del negocio
SELECT
    (SELECT COUNT(*) FROM Cliente)                           AS Total_Clientes,
    (SELECT COUNT(*) FROM Lead)                              AS Total_Leads,
    (SELECT COUNT(*) FROM Reserva)                           AS Total_Reservas,
    (SELECT COUNT(*) FROM Contrato)                          AS Total_Contratos,
    (SELECT SUM(Precio_venta) FROM Contrato)                 AS Ingresos_Totales,
    (SELECT COUNT(*) FROM Unidad_Inmobiliaria
     WHERE Estado = 'Disponible')                            AS Unidades_Disponibles,
    (SELECT COUNT(*) FROM Cuota WHERE Estado = 'Pendiente')  AS Cuotas_Pendientes;
