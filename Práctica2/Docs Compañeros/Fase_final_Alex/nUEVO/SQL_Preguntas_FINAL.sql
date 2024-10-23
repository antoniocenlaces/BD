--CUESTION 1: Directores para los cuales la última película en la que han participado ha sido como actor/actriz
WITH DIRECTORES AS (
    SELECT DISTINCT persona
    FROM PARTICIPAR P
    INNER JOIN OBRA O ON O.id_obra = P.obra
    WHERE O.tipo = 'P' 
    AND (P.funcion = 'actress' OR P.funcion = 'actor')    
    AND O.anyo_estreno >= (
        SELECT MAX(OAux.anyo_estreno)
        FROM PARTICIPAR PAux
        INNER JOIN OBRA OAux ON PAux.obra = OAux.id_obra
        WHERE PAux.funcion = 'director' AND P.persona = PAux.persona
    )
)
SELECT P.nombre
FROM DIRECTORES D, PERSONA P
WHERE P.id_persona = D.persona
ORDER BY nombre;

--CONSULTA 2:Obtener la saga de películas más larga (en número de películas), listando los títulos de las películas que la componen (incluyendo precuelas y secuelas)
explain plan for
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
SELECT DISTINCT titulo
FROM OBRA
WHERE id_obra IN (SELECT id_pelicula FROM PeliculasSagaMax)
    OR id_obra IN (SELECT id_saga FROM SagaMasLarga);
   
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY())

-- Consulta 3.
DROP TABLE IDEN_PAIS;
DROP TABLE PAIS;
DROP SEQUENCE id_pais_seq;
DROP TRIGGER id_pais_trg;
select distinct nacimiento from persona;
-- Tablas auxiliares para diferenciar cada persona por nacionalidad
-- Tabla IDEN_PAIS que contiene todos los diferentes lugares de nacimiento
-- que aparecen en la tabla PERSONA, además indicando a qué país pertenece

--Definitivo?
drop table iden_pais;
CREATE TABLE iden_pais (
    nacimiento  VARCHAR2(60) CONSTRAINT iden_pais2_pk PRIMARY KEY,
    pais        VARCHAR2(35) NOT NULL
);

-- Con las tablas creadas hay que importar los datos para poblarlas
-- Importar primero el excel PAIS.xlsx a la tabla PAIS
-- Importar excel IDEN_PAIS.xlsx a la tabla IDEN_PAIS
-- Siguiente consulta compruba que está bien poblado

-- ¡OJO! hay que volver a poblar persona con los datos de nacimiento de repetidos

-- Alterar tabla PERSONA para apuntar al país de cada lugar de nacimiento
WITH Actores AS (
    SELECT p.id_persona AS personaID, p.nombre AS nombre, p.nacimiento AS paisNacimiento, o.id_obra AS obraID
    FROM participar pa
    JOIN obra o ON pa.obra = o.id_obra
    JOIN persona p ON pa.persona = p.id_persona
    WHERE pa.funcion IN ('actor')
        AND o.tipo = 'P' -- Ajusta según tus datos si 'P' corresponde a películas
        AND o.anyo_estreno BETWEEN 1980 AND 2010 -- Filtra por el rango de años deseado
),
Actrices AS (
    SELECT p.id_persona AS personaID, p.nombre AS nombre, p.nacimiento AS paisNacimiento, o.id_obra AS obraID
    FROM participar pa
    JOIN obra o ON pa.obra = o.id_obra
    JOIN persona p ON pa.persona = p.id_persona
    WHERE pa.funcion IN ('actress')
        AND o.tipo = 'P' -- Ajusta según tus datos si 'P' corresponde a películas
        AND o.anyo_estreno BETWEEN 1980 AND 2010 -- Filtra por el rango de años deseado
)
SELECT a.nombre AS actor_nombre, a.paisNacimiento AS actor_pais, b.nombre AS actriz_nombre, b.paisNacimiento AS actriz_pais,
    COUNT(*) AS NumPelis,
    (SELECT COUNT(*) FROM Actores ac WHERE ac.personaID = a.personaID) AS TotalPelisActor,
    (SELECT COUNT(*) FROM Actrices act WHERE act.personaID = b.personaID) AS TotalPelisActriz
FROM Actores a
JOIN Actrices b ON a.obraID = b.obraID AND a.paisNacimiento != b.paisNacimiento
GROUP BY a.nombre,  b.nombre,  a.personaID, b.personaID, a.paisNacimiento, b.paisNacimiento
HAVING 
    COUNT(*) = (SELECT COUNT(*) FROM Actores ac WHERE ac.personaID = a.personaID)
    AND COUNT(*) = (SELECT COUNT(*) FROM Actrices act WHERE act.personaID = b.personaID)
ORDER BY 
    NumPelis DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT p1.persona idp_1, g1.nombre nombre1, p2.persona idp_2, g2.nombre nombre2, COUNT(*) contador
FROM participar p1, participar p2, obra o, persona g1, persona g2
WHERE p1.obra = o.id_obra AND
      o.tipo = 'P' AND
      p1.persona > p2.persona AND
      (p1.funcion = 'actor' OR p1.funcion = 'actress') AND
      (p2.funcion = 'actor' OR p2.funcion = 'actress') AND
      ( o.anyo_estreno >= 1980 AND
        o.anyo_estreno <= 2010 ) AND
      p1.persona = g1.id_persona AND
      p2.persona = g2.id_persona AND
      ((g1.genero='m' AND g2.genero='f') OR
      (g1.genero='f' AND g2.genero='m')) AND
      NOT EXISTS (
        SELECT p3.obra
        FROM participar p3
        WHERE p3.persona = p1.persona AND
              p2.persona NOT IN (
                SELECT p4.persona
                FROM participar p4
                WHERE p4.persona = p2.persona AND
                      p4.obra = p3.obra
              )
      )
GROUP BY p1.persona, g1.nombre, p2.persona, g2.nombre
ORDER BY contador DESC;

-----------------------------------------------------------------------------------------------------------------

SELECT  g1.nombre AS nombre1, g2.nombre AS nombre2--, COUNT(*) AS contador
FROM participar p1
JOIN obra o ON p1.obra = o.id_obra
JOIN persona g1 ON p1.persona = g1.id_persona
JOIN participar p2 ON p1.obra = p2.obra AND p1.persona > p2.persona
JOIN persona g2 ON p2.persona = g2.id_persona
WHERE o.tipo = 'P'
  AND (p1.funcion IN ('actor', 'actress'))
  AND (p2.funcion IN ('actor', 'actress'))
  AND o.anyo_estreno BETWEEN 1980 AND 2010
  AND ((g1.genero='m' AND g2.genero='f') OR (g1.genero='f' AND g2.genero='m'))
  AND NOT EXISTS (
    SELECT 1
    FROM participar p3
    WHERE p3.persona = p1.persona
      AND NOT EXISTS (
        SELECT 1
        FROM participar p4
        WHERE p4.persona = p2.persona AND p4.obra = p3.obra
      )
  )
GROUP BY g1.nombre, g2.nombre
ORDER BY contador DESC;



SELECT g1.nombre AS nombre1, g2.nombre AS nombre2, COUNT(*) AS contador
FROM participar p1
JOIN obra o ON p1.obra = o.id_obra
JOIN persona g1 ON p1.persona = g1.id_persona
JOIN participar p2 ON p1.obra = p2.obra AND p1.persona > p2.persona
JOIN persona g2 ON p2.persona = g2.id_persona
LEFT JOIN 
    (SELECT p3.obra,
        CASE 
            WHEN COUNT(*) = 2 THEN 1 
            ELSE 0 
        END AS valid_pair
    FROM participar p3
    WHERE p3.funcion IN ('actor', 'actress')
    GROUP BY p3.obra
    HAVING COUNT(DISTINCT p3.persona) = 2) valid_pairs ON valid_pairs.obra = p1.obra
WHERE o.tipo = 'P'
    AND p1.funcion IN ('actor', 'actress')
    AND p2.funcion IN ('actor', 'actress')
    AND o.anyo_estreno BETWEEN 1980 AND 2010
    AND ((g1.genero='m' AND g2.genero='f') OR (g1.genero='f' AND g2.genero='m'))
    AND valid_pairs.valid_pair IS NOT NULL
GROUP BY g1.nombre, g2.nombre
ORDER BY contador DESC;


SELECT g1.nombre AS nombre1, g2.nombre AS nombre2, COUNT(*) AS contador
FROM participar p1
JOIN obra o ON p1.obra = o.id_obra
JOIN persona g1 ON p1.persona = g1.id_persona
JOIN participar p2 ON p1.obra = p2.obra AND p1.persona > p2.persona
JOIN persona g2 ON p2.persona = g2.id_persona
LEFT JOIN 
    (SELECT p3.obra,
        CASE 
            WHEN COUNT(*) = 2 THEN 1 
            ELSE 0 
        END AS valid_pair
    FROM participar p3
    WHERE p3.funcion IN ('actor', 'actress')
    GROUP BY p3.obra
    HAVING COUNT(DISTINCT p3.persona) = 2) valid_pairs
ON valid_pairs.obra = p1.obra
LEFT JOIN 
    (SELECT obra, COUNT(*) AS solo_count
    FROM participar
    WHERE funcion IN ('actor', 'actress')
    GROUP BY obra
    HAVING COUNT(*) = 1) solo_works
ON solo_works.obra = p1.obra OR solo_works.obra = p2.obra
WHERE o.tipo = 'P'
    AND p1.funcion IN ('actor', 'actress')
    AND p2.funcion IN ('actor', 'actress')
    AND o.anyo_estreno BETWEEN 1980 AND 2010
    AND ((g1.genero='m' AND g2.genero='f') OR (g1.genero='f' AND g2.genero='m'))
    AND valid_pairs.valid_pair IS NOT NULL
    AND solo_works.obra IS NULL
GROUP BY g1.nombre, g2.nombre
ORDER BY contador DESC;









-------------------------------------------------------------------------------------------
with Actores as (
    Select mc.*, mp.tipo_rol, mp.numOrder, p.id as personaID, p.nombre, p.paisNacimiento 
    from mediaContent mc 
    join Multi_personal mp on mp.mediaId = mc.id and mp.tipo_rol = 'actor'
    join Personal p on p.id = mp.personaId 
    where mc.content_type = 'movie'
    and mc.production_year between 1980 and 2010 -- Filtrar por rango de años
),
Actrices as (
    Select mc.*, mp.tipo_rol, mp.numOrder, p.id as personaID, p.nombre, p.paisNacimiento 
    from mediaContent mc 
    join Multi_personal mp on mp.mediaId = mc.id and mp.tipo_rol = 'actress'
    join Personal p on p.id = mp.personaId 
    where mc.content_type = 'movie'
    and mc.production_year between 1980 and 2010 -- Filtrar por rango de años
)
Select a.nombre as actor_nombre, a.paisNacimiento as actor_pais, 
       b.nombre as actriz_nombre, b.paisNacimiento as actriz_pais,
       count(*) as NumPelis,
       (select count(*) from Actores ac where ac.personaID = a.personaID) as TotalPelisActor,
       (select count(*) from Actrices act where act.personaID = b.personaID) as TotalPelisActriz
from Actores a
join Actrices b on a.id = b.id and a.paisNacimiento != b.paisNacimiento
group by a.nombre, a.paisNacimiento, b.nombre, b.paisNacimiento, a.personaID, b.personaID
having count() = (select count() from Actores ac where ac.personaID = a.personaID)
    and count() = (select count() from Actrices act where act.personaID = b.personaID)
    -- utilizamos having para filtrar los resultados ya que sino obtendriamos las parejas de actores que 
    -- han trabajado alguna vez juntos pero que tambien podrían haber trabajado en otras peliculas por separado
order by NumPelis desc;


with actores as (
    Select mc.*, mp.funcion, mp.






----------------------------------------------------------------------------------------------
WITH Actores AS (
    SELECT 
        p.id_persona AS personaID, 
        p.nombre AS nombre, 
        --p.pais_nacimiento AS paisNacimiento,
        o.id_obra AS obraID
    FROM 
        participar pa
    JOIN 
        obra o ON pa.obra = o.id_obra
    JOIN 
        persona p ON pa.persona = p.id_persona
    WHERE 
        pa.funcion IN ('actor')
        AND o.tipo = 'P' -- Ajusta según tus datos si 'P' corresponde a películas
        AND o.anyo_estreno BETWEEN 1980 AND 2010 -- Filtra por el rango de años deseado
),
Actrices AS (
    SELECT 
        p.id_persona AS personaID, 
        p.nombre AS nombre, 
        --p.pais_nacimiento AS paisNacimiento,
        o.id_obra AS obraID
    FROM 
        participar pa
    JOIN 
        obra o ON pa.obra = o.id_obra
    JOIN 
        persona p ON pa.persona = p.id_persona
    WHERE 
        pa.funcion IN ('actress')
        AND o.tipo = 'P' -- Ajusta según tus datos si 'P' corresponde a películas
        AND o.anyo_estreno BETWEEN 1980 AND 2010 -- Filtra por el rango de años deseado
)
SELECT 
    a.nombre AS actor_nombre, 
    --a.paisNacimiento AS actor_pais, 
    b.nombre AS actriz_nombre, 
   -- b.paisNacimiento AS actriz_pais,
    COUNT(*) AS NumPelis,
    (SELECT COUNT(*) FROM Actores ac WHERE ac.personaID = a.personaID) AS TotalPelisActor,
    (SELECT COUNT(*) FROM Actrices act WHERE act.personaID = b.personaID) AS TotalPelisActriz
FROM 
    Actores a
JOIN 
    Actrices b ON a.obraID = b.obraID --AND a.paisNacimiento != b.paisNacimiento
GROUP BY 
    a.nombre,  b.nombre,  a.personaID, b.personaID --a.paisNacimiento, b.paisNacimiento,
HAVING 
    COUNT(*) = (SELECT COUNT(*) FROM Actores ac WHERE ac.personaID = a.personaID)
    AND COUNT(*) = (SELECT COUNT(*) FROM Actrices act WHERE act.personaID = b.personaID)
ORDER BY 
    NumPelis DESC;

