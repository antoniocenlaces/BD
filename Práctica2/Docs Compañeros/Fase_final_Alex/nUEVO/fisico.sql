ALTER TABLE VINCULAR
ADD titulo_obra_1 VARCHAR(150)
ADD titulo_obra_2 VARCHAR(150);

UPDATE vincular v
SET (v.titulo_obra_1, v.titulo_obra_2) = (
    SELECT o1.titulo, o2.titulo
    FROM obra o1
    JOIN obra o2 ON v.obra_1 = o1.id_obra AND v.obra_2 = o2.id_obra
);

WITH PeliculasPorSaga AS (
    SELECT obra_1 AS id_saga, COUNT(obra_2) AS cantidad_peliculas
    FROM VINCULAR
    GROUP BY obra_1
),
SagaMasLarga AS (
    SELECT id_saga
    FROM PeliculasPorSaga
    WHERE cantidad_peliculas = (SELECT MAX(cantidad_peliculas) FROM PeliculasPorSaga)
),
PeliculasSagaMax AS (
    SELECT DISTINCT obra_2 AS id_pelicula
    FROM VINCULAR
    WHERE obra_1 IN (SELECT id_saga FROM SagaMasLarga)
)
SELECT DISTINCT titulo_obra_1
FROM VINCULAR
WHERE obra_1 IN (SELECT id_pelicula FROM PeliculasSagaMax)
    OR obra_1 IN (SELECT id_saga FROM SagaMasLarga)
UNION 
SELECT DISTINCT titulo_obra_2
FROM VINCULAR
WHERE obra_2 IN (SELECT id_pelicula FROM PeliculasSagaMax)
    OR obra_2 IN (SELECT id_saga FROM SagaMasLarga);
    
--------------CONSULTA 3------------------------
-- 1. Agregar una nueva columna de partición
ALTER TABLE participar ADD (particion_funcion VARCHAR2(20));

-- 2. Mover los datos existentes a las particiones correspondientes
UPDATE participar SET particion_funcion = 'actor' WHERE funcion = 'actor';
UPDATE participar SET particion_funcion = 'actress' WHERE funcion = 'actress';

explain plan for
SELECT a.nombre AS actor_nombre, a.paisNacimiento AS actor_pais, b.nombre AS actriz_nombre, b.paisNacimiento AS actriz_pais, COUNT(*) AS NumPelis, a.TotalPelisActor, b.TotalPelisActriz 
FROM (
    SELECT p.nombre, ip.pais AS paisNacimiento, COUNT(*) AS TotalPelisActor 
    FROM participar pa 
    JOIN persona p ON pa.persona = p.id_persona 
    JOIN iden_pais ip ON p.nacimiento = ip.nacimiento 
    WHERE pa.funcion = 'actor' 
    GROUP BY p.nombre, ip.pais
) a, 
(
    SELECT p.nombre, ip.pais AS paisNacimiento, COUNT(*) AS TotalPelisActriz 
    FROM participar pa 
    JOIN persona p ON pa.persona = p.id_persona 
    JOIN iden_pais ip ON p.nacimiento = ip.nacimiento 
    WHERE pa.funcion = 'actress' 
    GROUP BY p.nombre, ip.pais
) b 
WHERE a.paisNacimiento != b.paisNacimiento 
GROUP BY a.nombre, b.nombre, a.paisNacimiento, b.paisNacimiento, a.TotalPelisActor, b.TotalPelisActriz 
ORDER BY NumPelis DESC;

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY())

