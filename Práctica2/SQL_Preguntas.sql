--CUESTION 1: Directores para los cuales la última película en la que han participado ha sido como actor/actriz
CREATE OR REPLACE VIEW DIRECTORES AS 
SELECT distinct persona
FROM PARTICIPAR P, OBRA O
WHERE O.id_obra = P.obra AND --JOIN
    O.tipo = 'P' AND (P.funcion = 'actress' OR P.funcion = 'actor')    
    AND O.anyo_estreno >= (
    SELECT max(OAux.anyo_estreno)
    FROM PARTICIPAR PAux, OBRA OAux
    WHERE PAux.obra = OAux.id_obra --JOIN
        AND PAux.funcion = 'director' AND P.persona = PAux.persona);

SELECT P.nombre
FROM DIRECTORES D, PERSONA P
WHERE P.id_persona = D.persona;

select count(distinct name) from datosdb.datospeliculas;
select count(distinct name) from datospelextra;
select count(*) from persona;

--CONSULTA 2:Obtener la saga de películas más larga (en número de películas), listando los títulos de las películas que la componen (incluyendo precuelas y secuelas)
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
   
   
SELECT v.obra_1 AS id_saga, o.titulo, COUNT(v.obra_2) AS cantidad_peliculas
    FROM VINCULAR v, OBRA o
    where v.obra_1 = o.ID_OBRA
    GROUP BY v.obra_1, o.titulo;

-- Consulta 3.
-- Para asegurar que podemos diferenciar la nacionalidad de cada persona
-- hemos obtenido el resultado de la conuslta:
SELECT DISTINCT nacimiento
FROM persona;
-- Sobre las 201 tuplas que se obtienen hemos definido cuál es el país
-- que corresponde a cada lugar de nacimiento y lo hemos cargado en la
-- tabla de excel IDEN_PAIS.csv
-- Tablas auxiliares para diferenciar cada persona por nacionalidad
-- Tabla IDEN_PAIS que contiene todos los diferentes lugares de nacimiento
-- que aparecen en la tabla PERSONA, además indicando a qué país pertenece
CREATE TABLE iden_pais (
    nacimiento  VARCHAR2(60) CONSTRAINT iden_pais2_pk PRIMARY KEY,
    pais        VARCHAR2(35) NOT NULL
);

-- Importar fichero IDEN_PAIS.csv
-- Comando a insertar en sqlplus2 en servidor lab000:
-- sqlldr2 $USER@barret.danae04.unizar.es control=datosIden_pais.ctl

-- Hacemos que el campo nacimiento de PERSONA sea una clave ajena referenciada en
-- IDEN_PAIS. De esta forma cuando se introduzca un nueva persona, ha de tener
-- su país previamente definido en IDEN_PAIS, o bien dejar nacimiento NULL
ALTER TABLE persona ADD CONSTRAINT persona_iden_pais_fk FOREIGN KEY (nacimiento) REFERENCES iden_pais(nacimiento);

-- SQL Consulta 3:
SELECT distinct g1.nombre nombre1,  g2.nombre nombre2-- COUNT(*) contador
FROM participar p1, participar p2, obra o, persona g1, persona g2, iden_pais ip1, iden_pais ip2
WHERE p1.obra = o.id_obra AND
      o.tipo = 'P' AND
      p1.persona > p2.persona AND
      (p1.funcion IN ('actor', 'actress')) AND
      (p2.funcion IN ('actor', 'actress')) AND
      o.anyo_estreno BETWEEN 1980 AND 2010 AND
      p1.persona = g1.id_persona AND
      p2.persona = g2.id_persona AND
      g1.nacimiento IS NOT NULL AND
      g1.nacimiento = ip1.nacimiento AND
      g2.nacimiento = ip2.nacimiento AND
      ip1.pais > ip2.pais AND
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
      );
GROUP BY p1.persona, g1.nombre, p2.persona, g2.nombre
ORDER BY contador DESC;

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
  );
GROUP BY g1.nombre, g2.nombre
ORDER BY contador DESC;