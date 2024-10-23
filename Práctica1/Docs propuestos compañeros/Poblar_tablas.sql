-- Poblar tabla Estadio
insert into a143045.estadio (nombre, fecha_inauguracion, aforo)
select estadio, fecha_inag, aforo
from datosdb.ligahost
where estadio is not null
group by estadio, fecha_inag, aforo
order by estadio asc;

-- Poblar tabla Equipo
INSERT INTO a143045.EQUIPO (nombre_oficial,nombre_corto,otros_nombres,ciudad,
fecha_fundacion,nombre_historico, mi_estadio)
SELECT DISTINCT(CLUB) nombre_oficial,
       EQUIPO_LOCAL nombre_corto,
       EQUIPO otros_nombres,
       CIUDAD ciudad,
       FUNDACION fecha_fundacion,
       NOMBRE nombre_historico,
       ESTADIO mi_estadio
FROM datosdb.ligahost
WHERE CLUB IS NOT NULL
ORDER BY CLUB ASC;

-- Preparar tabla ligahost para que equipo_local y equipo_visitante indiquen un nombre_oficial
-- y TEMPORADA sea un atributo que une INICIO_TEMPORADA con FIN_TEMPORADA
CREATE OR REPLACE VIEW a143045.DATOS_LIGA_FILTRADA
(INICIO_TEMPORADA, FIN_TEMPORADA, DIVISION, JORNADA, EQUIPO_LOCAL, 
EQUIPO_VISITANTE, GOLES_LOCAL, GOLES_VISITANTE, CLUB, CIUDAD, FUNDACION,    
FUND_LEGAL, NOMBRE, ESTADIO, FECHA_INAG, AFORO, EQUIPO,
LOCAL_OFICIAL, VISITA_OFICIAL, TEMPORADA) AS
SELECT a.*, b.NOMBRE_OFICIAL LOCAL_OFICIAL, c.NOMBRE_OFICIAL VISITA_OFICIAL,
CONCAT(INICIO_TEMPORADA,FIN_TEMPORADA) AS TEMPORADA
FROM datosdb.ligahost a, a143045.EQUIPO b, a143045.EQUIPO c
WHERE a.EQUIPO_LOCAL=b.NOMBRE_CORTO AND
      a.EQUIPO_VISITANTE=c.NOMBRE_CORTO AND
      a.EQUIPO_LOCAL IS NOT NULL AND
      a.EQUIPO_VISITANTE IS NOT NULL;

-- Insertar en tabla Temporada-Division partiendo de la vista anterior
INSERT INTO a143045.TEMPORADA_DIVISION 
(TEMPORADA, DIVISION, NUMERO_JORNADAS, NUMERO_PARTIDOS)
SELECT  TEMPORADA, DIVISION, COUNT(DISTINCT(JORNADA)) numero_jornadas,
COUNT(*) numero_partidos
FROM DATOS_LIGA_FILTRADA
GROUP BY TEMPORADA, DIVISION
ORDER BY TEMPORADA, DIVISION ASC;

-- Insertar en tabla Partido partiendo de la vista DATOS_LIGA_FILTRADA
INSERT INTO a143045.PARTIDO (TEMPORADA, DIVISION, JORNADA, EQUIPO_LOCAL,
EQUIPO_VISITANTE, GOLES_LOCAL, GOLES_VISITANTE)
SELECT TEMPORADA, DIVISION, JORNADA, LOCAL_OFICIAL EQUIPO_LOCAL,
VISITA_OFICIAL EQUIPO_VISITANTE, GOLES_LOCAL, GOLES_VISITANTE
FROM a143045.DATOS_LIGA_FILTRADA;

-- Insertar en tabla Participar
-- Primero crea nueva vista RESULTADOS_PARTIDO
-- Donde calcula para cada partido de la tabla PARTIDO creada antes
-- Los puntos que obtiene de ese partido el equipo local,
-- los goles que ha metido en ese partido el equipo local,
-- Los puntos que obtiene de ese partido el equipo visitante,
-- los goles que ha metido en ese partido el equipo visitante.
-- Está formada por UNION (suma) de 6 consultas diferentes.
CREATE OR REPLACE VIEW a143045.RESULTADOS_PARTIDO
(TEMPORADA, DIVISION, JORNADA, EQUIPO, PUNTOS, GOLES) AS
-- Primera consulta obtiene los datos del equipo local que ha sido vencedor en este partido
(SELECT  TEMPORADA, DIVISION, JORNADA, EQUIPO_LOCAL AS EQUIPO,
3 PUNTOS, GOLES_LOCAL GOLES
FROM A143045.PARTIDO WHERE GOLES_LOCAL > GOLES_VISITANTE AND
EQUIPO_LOCAL IS NOT NULL AND
EQUIPO_VISITANTE IS NOT NULL)
UNION
-- Segunda consulta obtiene los datos del equipo visitante que ha sido perdedor en este partido
(SELECT  TEMPORADA, DIVISION, JORNADA,EQUIPO_VISITANTE AS EQUIPO,
0 PUNTOS, GOLES_VISITANTE GOLES
FROM A143045.PARTIDO WHERE GOLES_LOCAL > GOLES_VISITANTE AND
EQUIPO_LOCAL IS NOT NULL AND
EQUIPO_VISITANTE IS NOT NULL)
UNION
-- Tercera consulta obtiene los datos del equipo visitante que ha sido ganador de este partido
(SELECT  TEMPORADA, DIVISION, JORNADA,EQUIPO_VISITANTE AS EQUIPO,
3 PUNTOS, GOLES_VISITANTE GOLES
FROM A143045.PARTIDO WHERE GOLES_VISITANTE > GOLES_LOCAL AND
EQUIPO_LOCAL IS NOT NULL AND
EQUIPO_VISITANTE IS NOT NULL)
UNION
-- Cuarta consulta obtiene los datos del equipo local que ha sido perdedor en este partido
(SELECT  TEMPORADA, DIVISION, JORNADA,EQUIPO_LOCAL AS EQUIPO,
0 PUNTOS, GOLES_LOCAL GOLES
FROM A143045.PARTIDO WHERE GOLES_VISITANTE > GOLES_LOCAL AND
EQUIPO_LOCAL IS NOT NULL AND
EQUIPO_VISITANTE IS NOT NULL)
UNION
-- Quinta consulta obtiene los datos del equipo local que ha empatado en este partido
(SELECT  TEMPORADA, DIVISION, JORNADA,EQUIPO_LOCAL AS EQUIPO,
1 PUNTOS, GOLES_LOCAL GOLES
FROM A143045.PARTIDO WHERE GOLES_LOCAL = GOLES_VISITANTE AND
EQUIPO_LOCAL IS NOT NULL AND
EQUIPO_VISITANTE IS NOT NULL)
UNION
-- Sexta consulta obtiene los datos del equipo visitante que ha empatado en este partido
(SELECT  TEMPORADA, DIVISION, JORNADA,EQUIPO_VISITANTE AS EQUIPO,
1 PUNTOS, GOLES_VISITANTE GOLES
FROM A143045.PARTIDO WHERE GOLES_LOCAL = GOLES_VISITANTE AND
EQUIPO_LOCAL IS NOT NULL AND
EQUIPO_VISITANTE IS NOT NULL);

-- Los datos a insertar en PARTICIPAR son el resultado de una agrupación por
-- Temporada, División y Equipo de la vista RESULTADOS_PARTIDO
INSERT INTO a143045.PARTICIPAR
(TEMPORADA, DIVISION, EQUIPO, PUNTOS, TOTAL_GOLES)
SELECT TEMPORADA, DIVISION, EQUIPO, SUM(PUNTOS) PUNTOS, SUM(GOLES) TOTAL_GOLES
FROM a143045.RESULTADOS_PARTIDO
GROUP BY TEMPORADA, DIVISION, EQUIPO
ORDER BY TEMPORADA, DIVISION, EQUIPO;
COMMIT;