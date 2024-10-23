-- SQL para respuesta a pregunta 1.
WITH LIGAS_GANADAS AS
-- Primero crea consulta temporal filtrar todos los equipos ganadores de Primera
-- División con su temporada, puntos y goles totales
    (
        SELECT EQUIPO, COUNT(EQUIPO) LIGAS_GANADAS
        FROM 
            (-- La consulta temporal se realiza sobre el resultado de una
             -- proyección de la tabla Participar filtrando los equipos con
             -- mayor número de puntos en cada temporada
                SELECT p.TEMPORADA, p.EQUIPO, p.PUNTOS, p.TOTAL_GOLES
                FROM PARTICIPAR p
                WHERE p.DIVISION='1' AND
                p.PUNTOS=
                        (
                            SELECT MAX(q.PUNTOS)
                            FROM PARTICIPAR q
                            WHERE q.DIVISION='1'
                            GROUP BY q.TEMPORADA
                            HAVING q.TEMPORADA=p.TEMPORADA
                        ) AND
                -- Filtro para eliminar empates en total de puntos
                -- el criterio es el equipo que más goles totales ha hecho
                p.TOTAL_GOLES >=
                        (-- selecciona el núemro máxinmo de goles que ha 
                         -- conseguido en esta temporada del conjunto de 
                         -- equipos que tiene mayor número de puntos en
                         -- esta temporada
                            SELECT MAX(r.TOTAL_GOLES)
                            FROM PARTICIPAR r
                            WHERE r.DIVISION='1' AND
                            r.TEMPORADA=p.TEMPORADA AND
                            r.PUNTOS=
                                    (
                                        SELECT MAX(q.PUNTOS)
                                        FROM PARTICIPAR q
                                        WHERE q.DIVISION='1'
                                        GROUP BY q.TEMPORADA
                                        HAVING q.TEMPORADA=p.TEMPORADA
                                    )
                        )
            )
        GROUP BY EQUIPO
    )
-- Sobre consulta anterior cuenta numero de veces que un equipo ha sido ganador
-- Y después muestra todos los equipos que han ganado el número máximo de
-- temporadas en primera division. (Primera división ya viene filtrado en la
-- cosnulta anterior)
SELECT EQUIPO, LIGAS_GANADAS
FROM LIGAS_GANADAS
WHERE LIGAS_GANADAS=
        (
            SELECT MAX(LIGAS_GANADAS)
            FROM LIGAS_GANADAS
        );

-- SQL para respuesta a pregunta 2.
SELECT T0.EQUIPO, T0.TEMPORADA, T0.DIVISION,
       T1.EQUIPO, T1.TEMPORADA, T1.DIVISION,
       T2.EQUIPO, T2.TEMPORADA, T2.DIVISION
FROM PARTICIPAR T0,
     PARTICIPAR T1,
     PARTICIPAR T2
WHERE T0.TEMPORADA>'20042005' AND --Establecer Temporada inicio
      --Condiciones de los join
      T0.EQUIPO=T1.EQUIPO AND 
      T0.EQUIPO=T2.EQUIPO AND
      --Temporada 0 en segunda división
      T0.DIVISION='2' AND
      --Temporada 1 en primera división
      (TO_NUMBER(SUBSTR(T1.TEMPORADA,1,4)))=(TO_NUMBER(SUBSTR(T0.TEMPORADA,1,4))+1) AND
      T1.DIVISION='1' AND
      --Temporada 2 en segunda división
      (TO_NUMBER(SUBSTR(T2.TEMPORADA,1,4)))=(TO_NUMBER(SUBSTR(T0.TEMPORADA,1,4))+2) AND
      T2.DIVISION='2';

-- SQL para respuesta a pregunta 3.
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