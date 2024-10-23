--------------CONSULTA 1------------------------
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
CREATE TABLE participar_new (
    obra        NUMBER(12) REFERENCES obra (id_obra) NOT NULL,
    persona     NUMBER(12) REFERENCES persona (id_persona) NOT NULL,
    funcion     VARCHAR2(40),
    papel       VARCHAR2(150),
    descripcion VARCHAR2(150),
    tipo        VARCHAR2(1),
    anyo_estreno NUMBER,
    CONSTRAINT papel_chk_new CHECK ((papel IS NOT NULL AND (funcion = 'actor' OR funcion = 'actress'))
                                OR (papel IS NULL AND (funcion <> 'actor' AND funcion <> 'actress')))
)
PARTITION BY RANGE (anyo_estreno) (
    PARTITION p_hasta_1979 VALUES LESS THAN (1980),
    PARTITION p_despues_1979 VALUES LESS THAN (MAXVALUE)
);

INSERT INTO participar_new (obra, persona, funcion, papel, descripcion, tipo, anyo_estreno)
SELECT P.obra, P.persona, P.funcion, P.papel, P.descripcion, O.tipo, O.anyo_estreno -- La entrada de anyo_exstreno como flag se hace desde el trigger 3
FROM participar P
JOIN obra O ON P.obra = O.id_obra;


explain plan for
WITH Actores AS (
    SELECT p.id_persona AS personaID, p.nombre AS nombre, ip.pais AS paisNacimiento, pa.obra AS obraID
    FROM participar_new pa
    JOIN persona p ON pa.persona = p.id_persona
    JOIN iden_pais ip ON p.nacimiento = ip.nacimiento
    WHERE pa.funcion IN ('actor')
        AND pa.tipo = 'P'
        AND pa.anyo_estreno = 1 
),
Actrices AS (
    SELECT p.id_persona AS personaID, p.nombre AS nombre, ip.pais AS paisNacimiento, pa.obra AS obraID
    FROM participar_new pa
    JOIN persona p ON pa.persona = p.id_persona
    JOIN iden_pais ip ON p.nacimiento = ip.nacimiento
    WHERE pa.funcion IN ('actress')
        AND pa.tipo = 'P' 
        AND pa.anyo_estreno = 1 
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
    
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

CREATE TABLE TABLA1 (CODIGO INTEGER);
SELECT * FROM TABLA1;
INSERT INTO TABLA1 VALUES(1);
INSERT INTO TABLA1 VALUES(2);
INSERT INTO TABLA1 VALUES(3);
create or replace view Tabla1_v as select * from pais join tabla1 on id_pais=codigo;
SELECT SUM(DECODE(CODIGO)) FROM TABLA1;
drop table tabla1;


