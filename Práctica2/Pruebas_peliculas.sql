-- Atributos de DATOSPELICULAS
DESCRIBE DATOSDB.DATOSPELICULAS;
-- Todas las tuplas de DATOSPELICULAS
SELECT * FROM DATOSDB.DATOSPELICULAS;
-- N�mero total de tuplas en DATOSPELICULAS
SELECT COUNT(*) FROM DATOSDB.DATOSPELICULAS;
-- N�mero diferente de personas que participan en pel�cula o serie
SELECT COUNT(DISTINCT(NAME))FROM DATOSDB.DATOSPELICULAS;
-- Diferentes personas que aparecen en DATOSPELICULAS
SELECT DISTINCT(NAME)FROM DATOSDB.DATOSPELICULAS;
-- Diferentes roles que aparecen en DATOSPELICULAS
SELECT DISTINCT(ROLE)FROM DATOSDB.DATOSPELICULAS;
-- N�mero de veces que se repite cada role (hay nulos que no los cuenta)
SELECT ROLE,COUNT(ROLE) FROM DATOSDB.DATOSPELICULAS GROUP BY ROLE;
-- Todas las tuplas de DATOSPELICULAS donde ROLE=NULL
SELECT * FROM DATOSDB.DATOSPELICULAS WHERE ROLE IS NULL;
-- Todas las tuplas que tienen alg�n dato en ROLE, pero que el mismo TITLE tiene alguna tupla con ROLE=NULL
SELECT * FROM DATOSDB.DATOSPELICULAS WHERE TITLE IN (SELECT TITLE FROM DATOSDB.DATOSPELICULAS WHERE ROLE IS NULL) AND ROLE IS NOT NULL;
-- Diferentes INFO_CONTEXT que aparecen en DATOSPELICULAS
SELECT DISTINCT(INFO_CONTEXT) FROM DATOSDB.DATOSPELICULAS;
-- Tuplas que forman una secuencia (remake, secuela o precuela)
SELECT * FROM DATOSDB.DATOSPELICULAS WHERE titlelink is not null;
-- Diferentes tipos de secuencia
SELECT DISTINCT(link) FROM DATOSDB.DATOSPELICULAS WHERE link is not null;
-- Roles nulos
SELECT COUNT(ROLE) FROM DATOSDB.DATOSPELICULAS WHERE ROLE IS NULL;
-- A�o de producci�n m�s reciente
SELECT MAX(PRODUCTION_YEAR) FROM DATOSDB.DATOSPELICULAS;
-- Pel�culas con el mismo nombre en diferente a�o de producci�n
SELECT DISTINCT(ROLE) FROM DATOSDB.DATOSPELICULAS;
SELECT A.TITLE
FROM DATOSDB.DATOSPELICULAS A
WHERE A.TITLE IN (SELECT B.TITLE
        FROM DATOSDB.DATOSPELICULAS B
        WHERE A.TITLE=B.TITLE AND
              A.PRODUCTION_YEAR<>B.PRIDUCTION_YEAR);
-- Pel�culas que con el mismo t�tulo tienen diferentes a�os de producci�n
SELECT A.TITLE, A.PRODUCTION_YEAR
FROM DATOSDB.DATOSPELICULAS A
WHERE A.TITLE IN (SELECT B.TITLE
        FROM DATOSDB.DATOSPELICULAS B
        WHERE A.TITLE=B.TITLE AND
              A.PRODUCTION_YEAR<>B.PRODUCTION_YEAR)
              ORDER BY A.TITLE;
              
drop table obra;
delete from obra where id_obra>0;

drop sequence obr_id_obra_seq;