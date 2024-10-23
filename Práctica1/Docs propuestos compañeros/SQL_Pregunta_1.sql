-- Primero vista para que filtra todos los equipos ganadores de Primera divisi�n con su temporada, puntos y goles totales
CREATE OR REPLACE VIEW a143045.GANADORES
(TEMPORADA, EQUIPO, PUNTOS, TOTAL_GOLES) AS
    (
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
        p.TOTAL_GOLES >=
                (-- selecciona el n�emro m�xinmo de goles que ha conseguido en esta temporada
                 -- del conjunto de equipos que tiene mayor n�mero de puntos en esta temporada
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
    );
-- Sobre la vista anterior se cuenta el n�mero de veces que un equipo ha sido ganador
-- Y despu�s se muestran todos los equipos que han ganado el n�mero m�ximo de temporadas
-- en primera division. (Primera divisi�n ya viene filtrado en la cosnulta anterior)
WITH LIGAS_GANADAS AS
        (
            SELECT EQUIPO, COUNT(EQUIPO) LIGAS_GANADAS
            FROM GANADORES
            GROUP BY EQUIPO
            ORDER BY LIGAS_GANADAS DESC
        )
SELECT EQUIPO, LIGAS_GANADAS
FROM LIGAS_GANADAS
WHERE LIGAS_GANADAS=
        (
            SELECT MAX(LIGAS_GANADAS)
            FROM LIGAS_GANADAS
        );