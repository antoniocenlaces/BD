-- SQL 1
-- Análisis de la consulta original
EXPLAIN PLAN FOR
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

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-- Añadiendo tabla auxiliar PUNTOS_GOLES
CREATE TABLE puntos_goles (
    temporada  VARCHAR2(8) NOT NULL,
    division   VARCHAR2(25) NOT NULL,
    max_puntos NUMBER(5)
);
ALTER TABLE puntos_goles ADD CONSTRAINT puntos_goles_pk PRIMARY KEY ( temporada,
                                                                      division );
ALTER TABLE puntos_goles
    ADD CONSTRAINT p_g_t_d_fk FOREIGN KEY ( temporada,
                                            division )
        REFERENCES temporada_division ( temporada,
                                        division );

-- Poblando tabla auxiliar PUNTOS_GOLES
INSERT INTO PUNTOS_GOLES
(TEMPORADA, DIVISION, MAX_PUNTOS)
SELECT TEMPORADA, DIVISION, MAX(PUNTOS)
FROM PARTICIPAR
GROUP BY TEMPORADA,DIVISION;

-- NUEVA SQL 1 usando la tabla auxiliar
EXPLAIN PLAN FOR
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

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-- SQL 2
EXPLAIN PLAN FOR
SELECT T0.EQUIPO, T0.TEMPORADA, T0.DIVISION,
       T1.EQUIPO, T1.TEMPORADA, T1.DIVISION,
       T2.EQUIPO, T2.TEMPORADA, T2.DIVISION
FROM PARTICIPAR T0,
     PARTICIPAR T1,
     PARTICIPAR T2
WHERE T0.TEMPORADA>'20042005' AND
      T0.EQUIPO=T1.EQUIPO AND
      T0.EQUIPO=T2.EQUIPO AND
      T0.DIVISION='2' AND
      (TO_NUMBER(SUBSTR(T1.TEMPORADA,1,4)))=(TO_NUMBER(SUBSTR(T0.TEMPORADA,1,4))+1) AND
      T1.DIVISION='1' AND
      (TO_NUMBER(SUBSTR(T2.TEMPORADA,1,4)))=(TO_NUMBER(SUBSTR(T0.TEMPORADA,1,4))+2) AND
      T2.DIVISION='2';
      
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-- SQL 3
EXPLAIN PLAN FOR
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

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-- Primero eliminar el ORDER BY
EXPLAIN PLAN FOR
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
                       GROUP BY TEMPORADA);
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());


-- Segundo creamos tabla auxiliar
CREATE TABLE goles_por_jornada (
    temporada     VARCHAR2(8) NOT NULL,
    jornada       NUMBER(3) NOT NULL,
    goles_jornada NUMBER(5)
);
ALTER TABLE goles_por_jornada ADD CONSTRAINT goles_por_jornada_pk PRIMARY KEY ( temporada,
                                                                                jornada );
-- Poblar tabla auxiliar                                
INSERT INTO goles_por_jornada
(TEMPORADA,JORNADA, GOLES_JORNADA)
SELECT TEMPORADA,JORNADA, SUM(GOLES_LOCAL) + SUM(GOLES_VISITANTE) GOLES_JORNADA
FROM PARTIDO
GROUP BY TEMPORADA,JORNADA;

-- Nueva consulta basada en tabla auxiliar
EXPLAIN PLAN FOR
SELECT g.TEMPORADA, g.JORNADA, g.GOLES_JORNADA
FROM GOLES_POR_JORNADA g
WHERE g.TEMPORADA>'20102011' AND
g.GOLES_JORNADA=(SELECT MAX(h.GOLES_JORNADA)
                       FROM GOLES_POR_JORNADA h
                       WHERE h.TEMPORADA=g.TEMPORADA
                       GROUP BY TEMPORADA);
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());
