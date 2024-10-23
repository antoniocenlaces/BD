-- POBLAR PERSONA
-- En los datos de partida (DATOSDB.DATOSPELICULAS) el atributo PERSON_INFO es
-- multivaluado.
-- Denominamos a un nombre (campo NAME) como REPETIDO cuando para el mismo valor
-- de NAME se encuentran valores diferentes en PERSON_INFO para el mismo
-- INFO_CONTEXT

-- Realizado el poblado en dos fases. Fase A: cargar en tabla PERSONA todos los
-- nombres no nulos y que el campo NAME no está repetido.
-- Fase B: usando herramienta externa (excel) hemos filtrado los datos del
-- campo PERSON_INFO para que cada persona tenga un nombre diferente, como
-- resultado creamos la tabla DATOSPELEXTRA, que contiene lso datos que había
-- en DATOSDB.DATOSPELICULAS pero sin repetición de nombre para personas
-- diferentes.

-- Fase A.
-- Paso A1: Datos de lugar de nacimiento
-- Extraae del campo PERSON_INFO lo que está después de la última coma, si la hay
-- después filtra los espacios y quita los caracteres []()
-- Las personas que no tengan un género definido en GENDER son cargadas a la
-- tabla PERSONA con el valor 'o' en el atributo GENRO
CREATE OR REPLACE VIEW NACIDOS AS 
    SELECT DISTINCT(NAME), TRANSLATE(
            TRIM(SUBSTR(PERSON_INFO, INSTR(PERSON_INFO, ',', -1) +1)),
            'x[]()','x')
            AS NACIMIENTO
    FROM DATOSDB.DATOSPELICULAS
    WHERE INFO_CONTEXT = 'birth notes';

-- Paso A2: crear y poblar tabla DIRECTORIO que va a contener todas las personas
-- con todos los datos que estas tengan en la tabla DATOSDB.DATOSPELICULAS 
create table directorio (name varchar2(60) not null, person_info varchar2(150),
    info_context varchar2(25));

-- Poblar DIRECTORIO: recoge todos los nombres que aparecen en DATOSPELICULAS
-- en cada línea se describe alguna información de la persona, si la tiene
INSERT INTO DIRECTORIO (NAME, PERSON_INFO, INFO_CONTEXT)
    SELECT NAME, PERSON_INFO, INFO_CONTEXT
    FROM DATOSDB.DATOSPELICULAS
    WHERE NAME IS NOT NULL
    GROUP BY NAME, PERSON_INFO, INFO_CONTEXT;

-- Paso A3: TABLA REPETIDO Personas cuyo nombre está repetido al menos una vez
-- Repetido: mismo NAME (NOMBRE) que tiene información de persona
-- diferente para el mismo concepto en al menos una otra tupla de la tabla
CREATE TABLE REPETIDO (NOMBRE VARCHAR2(60) PRIMARY KEY);

-- Poblar REPETIDO
INSERT INTO REPETIDO
    SELECT distinct A.NAME
    FROM DIRECTORIO A, DIRECTORIO B
    WHERE A.INFO_CONTEXT IS NOT NULL AND
      A.NAME=B.NAME AND
      A.INFO_CONTEXT = B.INFO_CONTEXT AND
      A.PERSON_INFO > B.PERSON_INFO;
      
-- Paso A4: Insertar los NO repetidos en PERSONA
INSERT INTO PERSONA (NOMBRE, NACIMIENTO, GENERO)
SELECT DISTINCT(P.NAME), N.NACIMIENTO, 
    CASE 
        WHEN P.GENDER IS NULL THEN 'o'
        ELSE P.GENDER
    END GENERO
FROM DATOSDB.DATOSPELICULAS P
FULL OUTER JOIN NACIDOS N ON P.NAME = N.NAME
WHERE P.NAME NOT IN (
        SELECT *
        FROM REPETIDO
        );

-- Fase B.
-- Paso B1: importar a la tabla DATOSPELEXTRA los datos del excel:
-- DATOSPELEXTRA.csv

-- Paso B1: importar datos filtrados de personas
-- Primero crea la tabla DATOSPELEXTRA idéntica a DATOSDB.DATOSPELICULAS
CREATE TABLE DATOSPELEXTRA AS
SELECT * FROM DATOSDB.DATOSPELICULAS
WHERE NAME='Amaya, Carmen';
-- borra los registros creados
delete from datospelextra;
commit;
alter table DATOSPELEXTRA MODIFY (NAME VARCHAR2(45));
-- Importar fichero DATOSPELEXTRA.csv
-- Comando a insertar en sqlplus2 en servidor lab000:
-- sqlldr2 $USER@barret.danae04.unizar.es control=datosDatospelextra.ctl


-- Paso B2: poblar de nuevo DIRECTORIO con los datos de DATOSPELEXTRA
DELETE FROM DIRECTORIO;

INSERT INTO DIRECTORIO (NAME, PERSON_INFO, INFO_CONTEXT)
    SELECT NAME, PERSON_INFO, INFO_CONTEXT
    FROM DATOSPELEXTRA
    WHERE NAME IS NOT NULL
    GROUP BY NAME, PERSON_INFO, INFO_CONTEXT;

-- Paso B3: obtener los datos de lugar de nacimiento de DATOSPELEXTRA
CREATE OR REPLACE VIEW NACIDOS AS 
    SELECT DISTINCT(NAME), TRANSLATE(
            TRIM(SUBSTR(PERSON_INFO, INSTR(PERSON_INFO, ',', -1) +1)),
            'x[]()','x')
            AS NACIMIENTO
    FROM DATOSPELEXTRA
    WHERE INFO_CONTEXT = 'birth notes';

-- Paso B4: insertar las personas adicionales en PERSONA
INSERT INTO PERSONA (NOMBRE, NACIMIENTO, GENERO)
SELECT DISTINCT(P.NAME), N.NACIMIENTO,
    CASE 
        WHEN P.GENDER IS NULL THEN 'o'
        ELSE P.GENDER
    END GENERO
FROM DATOSPELEXTRA P
FULL OUTER JOIN NACIDOS N ON P.NAME = N.NAME;

-- SQL PARA POBLAR OBRA CON PELICULAS
INSERT INTO OBRA (TITULO, ANYO_ESTRENO,TIPO)
SELECT TITLE, PRODUCTION_YEAR, 'P' TIPO
FROM DATOSDB.DATOSPELICULAS
WHERE KIND='movie'
GROUP BY TITLE,PRODUCTION_YEAR
ORDER BY TITLE;

-- SQL PARA POBLAR OBRA CON SERIES
INSERT INTO OBRA (TITULO, PERIODO_EMISION, TIPO)
SELECT TITLE, SERIES_YEARS, 'S' TIPO
FROM DATOSDB.DATOSPELICULAS
WHERE KIND='tv series'
GROUP BY TITLE, SERIES_YEARS
ORDER BY TITLE;

-- POBLAR GENERO
INSERT INTO GENERO (NOMBRE)
SELECT DISTINCT KEYWORD NOMBRE 
FROM DATOSDB.DATOSPELICULAS 
WHERE KEYWORD IS NOT NULL;

-- POBLAR CLASIFICAR
INSERT INTO CLASIFICAR (OBRA, GENERO)
WITH GENERO_PELI AS
        (SELECT D.TITLE TITULO, D.PRODUCTION_YEAR ANYO_PRODUCCION, D.KEYWORD GENERO,O.ID_OBRA OBRA
        FROM DATOSDB.DATOSPELICULAS D, OBRA O
        WHERE D.KIND='movie' AND
              D.KEYWORD IS NOT NULL AND
              O.TITULO = D.TITLE AND
              O.ANYO_ESTRENO = D.PRODUCTION_YEAR
        GROUP BY D.TITLE, D.PRODUCTION_YEAR, D.KEYWORD, O.ID_OBRA
        ORDER BY D.TITLE),
    GENERO_SERIE AS
        (SELECT D.TITLE TITULO, D.SERIES_YEARS PERIODO_EMISION, D.KEYWORD GENERO,O.ID_OBRA OBRA
        FROM DATOSDB.DATOSPELICULAS D, OBRA O
        WHERE D.KIND='tv series' AND
              D.KEYWORD IS NOT NULL AND
              O.TITULO = D.TITLE AND
              O.PERIODO_EMISION = D.SERIES_YEARS
        GROUP BY D.TITLE, D.SERIES_YEARS, D.KEYWORD, O.ID_OBRA
        ORDER BY D.TITLE)
SELECT OBRA, GENERO
FROM GENERO_PELI
UNION
SELECT OBRA, GENERO
FROM GENERO_SERIE;

-- Poblar CAPITULO
-- Hay que buscar para cada capítulo su ID_OBRA metiendo en el filtro:
-- SERIES_YEARS (por parte de OBRA) y SERIE_PROD_YEAR (por parte de DATOSPELI)
CREATE OR REPLACE VIEW capitulos AS (  --Saca los id_obra de la serie de cada cap?tulo
        SELECT distinct O.id_obra, M.title
        FROM OBRA O, DATOSDB.DATOSPELICULAS M
        WHERE O.titulo = M.serie_title 
    );
INSERT INTO CAPITULO (n_cap, titulo_cap, temporada, mi_serie)
SELECT DISTINCT (M.episode_nr), M.title, M.season_nr, O.id_obra
FROM DATOSDB.DATOSPELICULAS M, OBRA O
WHERE M.serie_title = O.titulo AND 
      M.serie_prod_year = SUBSTR(O.periodo_emision,1,4) AND
      M.kind = 'episode';

-- Poblar PARTICIPAR
-- Vamos a seguir la misma estrategia que con PERSONA
-- FASE A: personas con nombre NO repetido

-- Paso A0: Volver a crear la lista de repetidos
DELETE FROM DIRECTORIO;
INSERT INTO DIRECTORIO (NAME, PERSON_INFO, INFO_CONTEXT)
    SELECT NAME, PERSON_INFO, INFO_CONTEXT
    FROM DATOSDB.DATOSPELICULAS
    WHERE NAME IS NOT NULL
    GROUP BY NAME, PERSON_INFO, INFO_CONTEXT;

DELETE FROM repetido;
INSERT INTO REPETIDO
    SELECT distinct A.NAME
    FROM DIRECTORIO A, DIRECTORIO B
    WHERE A.INFO_CONTEXT IS NOT NULL AND
      A.NAME=B.NAME AND
      A.INFO_CONTEXT = B.INFO_CONTEXT AND
      A.PERSON_INFO > B.PERSON_INFO;
      
-- Paso A1: insertar todos los participantes cuyo nombre no está en REPTIDO
-- Como apoyo la siguiente vista solo nos da los datos de personas que no están en REPETIDO
-- Vista de apoyo con todos los datos de participantes en cualquier obra
CREATE OR REPLACE VIEW NOMBRE_FUNCION AS
SELECT C.TITLE, C.SERIE_TITLE, C.PRODUCTION_YEAR, C.SERIES_YEARS, C.SERIE_PROD_YEAR, C.KIND, C.NAME, C.ROLE, C.ROLE_NAME, C.NOTE
FROM DATOSDB.DATOSPELICULAS C
WHERE  C.NAME NOT IN (SELECT * FROM REPETIDO)
GROUP BY C.TITLE, C.SERIE_TITLE, C.PRODUCTION_YEAR, C.SERIES_YEARS, C.SERIE_PROD_YEAR, C.KIND, C.NAME, C.ROLE, C.ROLE_NAME, C.NOTE;

-- Paso A2: Películas
INSERT INTO PARTICIPAR (OBRA, PERSONA, FUNCION, PAPEL, DESCRIPCION)
SELECT A.ID_OBRA, B.ID_PERSONA, C.ROLE, C.ROLE_NAME, C.NOTE
FROM NOMBRE_FUNCION C
JOIN  OBRA A ON (A.TITULO = C.TITLE AND A.ANYO_ESTRENO = C.PRODUCTION_YEAR AND A.TIPO='P')
JOIN PERSONA B ON B.NOMBRE = C.NAME
WHERE ((C.ROLE_NAME IS NOT NULL AND
            ( C.ROLE = 'actor' OR C.ROLE = 'actress')) 
    OR ( C.ROLE_NAME IS NULL AND 
            ( C.ROLE <> 'actor' AND C.ROLE <> 'actress' )))
GROUP BY A.ID_OBRA, B.ID_PERSONA, C.ROLE, C.ROLE_NAME, C.NOTE;

-- Paso 2 Series
INSERT INTO PARTICIPAR (OBRA, PERSONA, FUNCION, PAPEL, DESCRIPCION)
SELECT A.ID_OBRA, B.ID_PERSONA, C.ROLE, C.ROLE_NAME, C.NOTE
FROM NOMBRE_FUNCION C
JOIN  OBRA A ON (A.TITULO = C.TITLE AND A.PERIODO_EMISION = C.SERIES_YEARS AND A.TIPO='S')
JOIN PERSONA B ON B.NOMBRE = C.NAME
WHERE ((C.ROLE_NAME IS NOT NULL AND
            ( C.ROLE = 'actor' OR C.ROLE = 'actress')) 
    OR ( C.ROLE_NAME IS NULL AND 
            ( C.ROLE <> 'actor' AND C.ROLE <> 'actress' )))
GROUP BY A.ID_OBRA, B.ID_PERSONA, C.ROLE, C.ROLE_NAME, C.NOTE;

-- Paso 3 Capítulos
CREATE OR REPLACE VIEW PARTICIPA_CAPITULO AS
SELECT A.ID_OBRA OBRA, B.ID_PERSONA PERSONA, C.ROLE FUNCION, C.ROLE_NAME PAPEL, C.NOTE DESCRIPCION
FROM NOMBRE_FUNCION C
JOIN  OBRA A ON (A.TITULO = C.SERIE_TITLE AND C.SERIE_PROD_YEAR = SUBSTR(A.PERIODO_EMISION,1,4) AND A.TIPO='S')
JOIN PERSONA B ON B.NOMBRE = C.NAME
WHERE ((C.ROLE_NAME IS NOT NULL AND
            ( C.ROLE = 'actor' OR C.ROLE = 'actress')) 
    OR ( C.ROLE_NAME IS NULL AND 
            ( C.ROLE <> 'actor' AND C.ROLE <> 'actress' )))
GROUP BY A.ID_OBRA, B.ID_PERSONA, C.ROLE, C.ROLE_NAME, C.NOTE;
-- Como en la consulta de arriba nos da tuplas que ya existen en PARTICIPAR
-- Hacemos un filtro de las que ya están las elimina.
INSERT INTO PARTICIPAR (OBRA, PERSONA, FUNCION, PAPEL, DESCRIPCION)
SELECT OBRA, PERSONA, FUNCION, PAPEL, DESCRIPCION FROM PARTICIPA_CAPITULO
MINUS
SELECT OBRA, PERSONA, FUNCION, PAPEL, DESCRIPCION FROM PARTICIPAR;

-- FASE B: insertar todos los participantes cuyo nombre está en REPTIDO
-- Como apoyo la siguiente vista solo nos da los datos de personas que no están en REPETIDO
-- Vista de apoyo con todos los datos de participantes en cualquier obra
CREATE OR REPLACE VIEW NOMBRE_FUNCION AS
SELECT TITLE, SERIE_TITLE, PRODUCTION_YEAR, SERIES_YEARS, SERIE_PROD_YEAR, KIND, NAME, ROLE, ROLE_NAME, NOTE
FROM DATOSPELEXTRA
GROUP BY TITLE, SERIE_TITLE, PRODUCTION_YEAR, SERIES_YEARS, SERIE_PROD_YEAR, KIND, NAME, ROLE, ROLE_NAME, NOTE;
-- Paso 1 Películas
INSERT INTO PARTICIPAR (OBRA, PERSONA, FUNCION, PAPEL, DESCRIPCION)
SELECT A.ID_OBRA, B.ID_PERSONA, C.ROLE, C.ROLE_NAME, C.NOTE
FROM NOMBRE_FUNCION C
JOIN  OBRA A ON (A.TITULO = C.TITLE AND A.ANYO_ESTRENO = C.PRODUCTION_YEAR AND A.TIPO='P')
JOIN PERSONA B ON B.NOMBRE = C.NAME
WHERE ((C.ROLE_NAME IS NOT NULL AND
            ( C.ROLE = 'actor' OR C.ROLE = 'actress')) 
    OR ( C.ROLE_NAME IS NULL AND 
            ( C.ROLE <> 'actor' AND C.ROLE <> 'actress' )))
GROUP BY A.ID_OBRA, B.ID_PERSONA, C.ROLE, C.ROLE_NAME, C.NOTE;

-- Paso 2 Series
INSERT INTO PARTICIPAR (OBRA, PERSONA, FUNCION, PAPEL, DESCRIPCION)
SELECT A.ID_OBRA, B.ID_PERSONA, C.ROLE, C.ROLE_NAME, C.NOTE
FROM NOMBRE_FUNCION C
JOIN  OBRA A ON (A.TITULO = C.TITLE AND A.PERIODO_EMISION = C.SERIES_YEARS AND A.TIPO='S')
JOIN PERSONA B ON B.NOMBRE = C.NAME
WHERE ((C.ROLE_NAME IS NOT NULL AND
            ( C.ROLE = 'actor' OR C.ROLE = 'actress')) 
    OR ( C.ROLE_NAME IS NULL AND 
            ( C.ROLE <> 'actor' AND C.ROLE <> 'actress' )))
GROUP BY A.ID_OBRA, B.ID_PERSONA, C.ROLE, C.ROLE_NAME, C.NOTE;

-- Paso 3 Capítulos
CREATE OR REPLACE VIEW PARTICIPA_CAPITULO AS
SELECT A.ID_OBRA OBRA, B.ID_PERSONA PERSONA, C.ROLE FUNCION, C.ROLE_NAME PAPEL, C.NOTE DESCRIPCION
FROM NOMBRE_FUNCION C
JOIN  OBRA A ON (A.TITULO = C.SERIE_TITLE AND C.SERIE_PROD_YEAR = SUBSTR(A.PERIODO_EMISION,1,4) AND A.TIPO='S')
JOIN PERSONA B ON B.NOMBRE = C.NAME
WHERE ((C.ROLE_NAME IS NOT NULL AND
            ( C.ROLE = 'actor' OR C.ROLE = 'actress')) 
    OR ( C.ROLE_NAME IS NULL AND 
            ( C.ROLE <> 'actor' AND C.ROLE <> 'actress' )))
GROUP BY A.ID_OBRA, B.ID_PERSONA, C.ROLE, C.ROLE_NAME, C.NOTE;
-- Como en la consulta de arriba nos da tuplas que ya existen en PARTICIPAR
-- Hacemos un filtro y las que ya están las elimina.
INSERT INTO PARTICIPAR (OBRA, PERSONA, FUNCION, PAPEL, DESCRIPCION)
SELECT OBRA, PERSONA, FUNCION, PAPEL, DESCRIPCION FROM PARTICIPA_CAPITULO
MINUS
SELECT OBRA, PERSONA, FUNCION, PAPEL, DESCRIPCION FROM PARTICIPAR;

-- Eliminar los elementos temporales usados hasta ahora:
DROP VIEW nacidos;
DROP VIEW capitulos;
DROP VIEW nombre_funcion;
DROP VIEW participa_capitulo;
DROP TABLE directorio;
DROP TABLE repetido;

-- Polblar VINCULAR: REMAKE

INSERT INTO VINCULAR (obra_1, obra_2, vinculo)
SELECT DISTINCT O1.id_obra, O2.id_obra, 'remake' vinculo
FROM DATOSDB.DATOSPELICULAS M, OBRA O1, OBRA O2
WHERE -- M.link = 'version of' OR 
    M.link = 'remake of' AND
    M.kind = 'movie' AND
    O1.titulo = M.title AND
    O1.anyo_estreno = M.production_year AND
    O2.titulo = M.titlelink AND
    O2.anyo_estreno = M.productionyearlink AND
    O1.TIPO = 'P' AND O2.TIPO = 'P' AND
    O1.anyo_estreno > O2.anyo_estreno;

INSERT INTO VINCULAR (obra_1, obra_2, vinculo)
SELECT DISTINCT O2.id_obra, O1.id_obra, 'remake' vinculo
FROM DATOSDB.DATOSPELICULAS M, OBRA O1, OBRA O2
WHERE
    M.link = 'edited into' AND
    M.kind = 'movie' AND
    O1.titulo = M.title AND
    O1.anyo_estreno = M.production_year AND
    O2.titulo = M.titlelink AND
    O2.anyo_estreno = M.productionyearlink AND
    O1.TIPO = 'P' AND O2.TIPO = 'P' AND
    O1.anyo_estreno < O2.anyo_estreno;

-- Poblar VINCULAR: SECUELA

INSERT INTO VINCULAR (obra_1, obra_2, vinculo)
SELECT DISTINCT O1.id_obra, O2.id_obra, 'secuela' vinculo
FROM DATOSDB.DATOSPELICULAS M, OBRA O1, OBRA O2
WHERE
    M.link = 'follows'  AND
    M.kind = 'movie' AND
    O1.titulo = M.title AND
    O1.anyo_estreno = M.production_year AND
    O2.titulo = M.titlelink AND
    O2.anyo_estreno = M.productionyearlink AND
    O1.TIPO = 'P' AND O2.TIPO = 'P' AND
    O1.anyo_estreno > O2.anyo_estreno;

-- Poblar VINCULAR: PRECUELA

INSERT INTO VINCULAR (obra_1, obra_2, vinculo)
SELECT DISTINCT O1.id_obra, O2.id_obra, 'precuela' vinculo
FROM DATOSDB.DATOSPELICULAS M, OBRA O1, OBRA O2
WHERE 
    M.link = 'followed by'  AND
    M.kind = 'movie' AND
    O1.titulo = M.title AND
    O1.anyo_estreno = M.production_year AND
    O2.titulo = M.titlelink AND
    O2.anyo_estreno = M.productionyearlink AND
    O1.TIPO = 'P' AND O2.TIPO = 'P' AND
    O1.anyo_estreno > O2.anyo_estreno;