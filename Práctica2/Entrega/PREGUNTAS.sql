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

WITH Actores AS (
    SELECT p.id_persona AS personaID, p.nombre AS nombre, ip.pais AS paisNacimiento, o.id_obra AS obraID
    FROM participar pa
    JOIN obra o ON pa.obra = o.id_obra
    JOIN persona p ON pa.persona = p.id_persona
    JOIN iden_pais ip ON p.nacimiento = ip.nacimiento
    WHERE pa.funcion IN ('actor')
        AND o.tipo = 'P'
        AND o.anyo_estreno BETWEEN 1980 AND 2010 
),
Actrices AS (
    SELECT p.id_persona AS personaID, p.nombre AS nombre, ip.pais AS paisNacimiento, o.id_obra AS obraID
    FROM participar pa
    JOIN obra o ON pa.obra = o.id_obra
    JOIN persona p ON pa.persona = p.id_persona
    JOIN iden_pais ip ON p.nacimiento = ip.nacimiento
    WHERE pa.funcion IN ('actress')
        AND o.tipo = 'P' 
        AND o.anyo_estreno BETWEEN 1980 AND 2010 
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
