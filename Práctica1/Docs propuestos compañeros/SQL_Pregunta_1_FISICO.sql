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
                        (   SELECT PG.MAX_PUNTOS
                            FROM PUNTOS_GOLES PG
                            WHERE PG.DIVISION='1' AND
                            PG.TEMPORADA=p.TEMPORADA
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
                                        SELECT PG.MAX_PUNTOS
                                        FROM PUNTOS_GOLES PG
                                        WHERE PG.DIVISION='1' AND
                                        PG.TEMPORADA=p.TEMPORADA
                                    )
                        )
            )
        GROUP BY EQUIPO
        ORDER BY LIGAS_GANADAS DESC
    )
-- Sobre consulta anterior cuenta número de veces que un equipo ha sido ganador
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