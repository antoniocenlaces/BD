-- 1) Equipo que más ligas de primera división ha ganado.
-- Usamos una subconsulta para contar el número de ligas ganadas por cada equipo en primera división
-- y luego seleccionamos el equipo(s) con el máximo valor.
SELECT EQUIPO, MAX(LIGAS) AS LIGAS_GANADAS
FROM (
  SELECT EQUIPO_LOCAL AS EQUIPO, COUNT(DISTINCT(TEMPORADA)) AS LIGAS
  FROM  PARTIDO
  WHERE DIVISION = 'Primera'
  AND GOLES_LOCAL > GOLES_VISITANTE -- El equipo local gana el partido
  GROUP BY EQUIPO_LOCAL
  UNION
  SELECT EQUIPO_VISITANTE AS EQUIPO, COUNT(DISTINCT(TEMPORADA)) AS LIGAS
  FROM  PARTIDO
  WHERE DIVISION = 'Primera'
  AND GOLES_VISITANTE > GOLES_LOCAL -- El equipo visitante gana el partido
  GROUP BY EQUIPO_VISITANTE
)
GROUP BY EQUIPO
ORDER BY LIGAS_GANADAS DESC;

-- 2) Equipos de segunda división que han ascendido a primera y al año siguiente han vuelto a descender
-- en las últimas diez temporadas.
-- Usamos una subconsulta para obtener las temporadas de las últimas diez temporadas
-- y luego usamos un JOIN para unir las tablas Temporada_Division y Equipo
-- y filtramos los equipos que han cambiado de división entre temporadas consecutivas.
SELECT DISTINCT(E.NOMBRE_OFICIAL) AS EQUIPO, T1.TEMPORADA AS ASCENSO, T2.TEMPORADA AS DESCENSO
FROM (
  SELECT TEMPORADA
  FROM  TEMPORADA_DIVISION
  ORDER BY TEMPORADA DESC
  LIMIT 10 -- Las últimas diez temporadas
)
JOIN  TEMPORADA_DIVISION AS T1 ON T.TEMPORADA = T1.TEMPORADA
JOIN  TEMPORADA_DIVISION AS T2 ON T1.TEMPORADA + 1 = T2.TEMPORADA -- Temporadas consecutivas
JOIN  EQUIPO AS E ON T1.DIVISION = E.DIVISION
WHERE T1.DIVISION = 'Segunda' AND T2.DIVISION = 'Primera' -- Ascenso de segunda a primera
AND  
-- Comprobamos que no hayan vuelto a ascender después del descenso
(  SELECT 1
  FROM  TEMPORADA_DIVISION AS T3
  WHERE T3.TEMPORADA = T2.TEMPORADA + 1
  AND T3.DIVISION = 'Segunda'
  AND T3.EQUIPO = E.EQUIPO
) IS NULL;

-- 3) Jornadas de las últimas cinco temporadas donde se han marcado más goles.
-- Usamos una subconsulta para obtener las temporadas de las últimas cinco temporadas
-- y luego usamos un GROUP BY para sumar los goles marcados por cada jornada
-- y finalmente ordenamos los resultados de forma descendente
WITH GOLES_POR_JORNADA AS
    (
        SELECT TEMPORADA,JORNADA, SUM(GOLES_LOCAL) + SUM(GOLES_VISITANTE) GOLES_JORNADA
        FROM PARTIDO
        GROUP BY TEMPORADA,JORNADA
    )
SELECT g.TEMPORADA, g.JORNADA, g.GOLES_JORNADA
FROM GOLES_POR_JORNADA g
WHERE g.TEMPORADA>'20102011' AND
g.GOLES_JORNADA=(SELECT MAX(h.GOLES_JORNADA)
                       FROM GOLES_POR_JORNADA h
                       WHERE h.TEMPORADA=g.TEMPORADA
                       GROUP BY TEMPORADA)
ORDER BY TEMPORADA DESC;