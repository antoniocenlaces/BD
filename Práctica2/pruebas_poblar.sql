SELECT PERSON_INFO FROM DATOSDB.DATOSPELICULAS
WHERE INFO_CONTEXT = 'birth notes';

SELECT DISTINCT NAME, GENDER, PERSON_INFO
FROM DATOSDB.DATOSPELICULAS
WHERE INFO_CONTEXT = 'birth notes';


SELECT NAME, GENDER, PERSON_INFO
FROM DATOSDB.DATOSPELICULAS
WHERE INFO_CONTEXT = 'birth notes' AND
NAME = 'Sheldon, Ralph';

SELECT DISTINCT NAME, GENDER, PERSON_INFO, ROLE
FROM DATOSDB.DATOSPELICULAS
WHERE GENDER IS NULL AND NAME IS NOT NULL
ORDER BY NAME;

SELECT *
FROM PERSONA
WHERE NACIMIENTO IS NULL;
describe persona;

DROP TABLE PERSONA;
DROP SEQUENCE per_id_persona_seq;
DELETE FROM PERSONA
WHERE ID_PERSONA > 0;

DROP VIEW NACIDOS;
CREATE VIEW NACIDOS AS 
    SELECT DISTINCT(NAME), TRIM(TRAILING ']' FROM
            TRIM(SUBSTR(PERSON_INFO, INSTR(PERSON_INFO, ',', -1) +1)))
            AS NACIMIENTO
    FROM  DATOSDB.DATOSPELICULAS
    WHERE INFO_CONTEXT = 'birth notes';
    
INSERT INTO PERSONA (NOMBRE, NACIMIENTO, GENERO)
SELECT DISTINCT(P.NAME), N.NACIMIENTO, P.GENDER 
FROM  DATOSDB.DATOSPELICULAS P
FULL OUTER JOIN NACIDOS N ON P.NAME = N.NAME
WHERE P.GENDER IS NOT NULL;

SELECT DISTINCT(P.NAME), N.NACIMIENTO, P.GENDER 
FROM DATOSDB.DATOSPELICULAS P
FULL OUTER JOIN NACIDOS N ON P.NAME = N.NAME
WHERE P.GENDER IS NOT NULL AND
      P.NAME NOT IN (
        SELECT *
        FROM REPETIDO);
        
select length('Schreiberhau, Lower Silesia, Germany [now Szklarska Poreba, Dolnoslaskie, Poland]') from dual;

SELECT *
FROM PERSONA
WHERE NOMBRE LIKE '%1%';
DESCRIBE PERSONA;

SELECT DISTINCT(NAME), TRIM(TRAILING ']' FROM 
        TRIM(SUBSTR(PERSON_INFO, INSTR(PERSON_INFO, ',', -1) +1))) AS NAC
FROM  DATOSDB.DATOSPELICULAS
WHERE INFO_CONTEXT = 'birth notes';


-- También es necesario insertar en PERSONA quien tiene género NULL
-- Hay personas sin género y con info de nacimiento
-- en la vista NACIDOS ya están todos
SELECT * FROM DATOSDB.DATOSPELICULAS
WHERE GENDER IS NULL AND
      INFO_CONTEXT='birth notes';
-- Un caso de ejemplo:
SELECT * FROM NACIDOS
WHERE NAME = 'Goitia, Alberto';

-- Antes de inicar la inserción hay que cambiar la tabla
ALTER TABLE PERSONA DISABLE CONSTRAINT genero_chk;
ALTER TABLE PERSONA DROP CONSTRAINT genero_chk;
ALTER TABLE PERSONA ADD CONSTRAINT genero_chk CHECK ( genero IN ( 'f', 'm', 'o' ) );
ALTER TABLE PERSONA ADD CONSTRAINT GENERO  NOT NULL;
describe persona;
-- Ahora la inserción de los no repetidos
INSERT INTO PERSONA (NOMBRE, NACIMIENTO, GENERO)
SELECT DISTINCT(P.NAME), N.NACIMIENTO, 'o' GENERO 
FROM DATOSDB.DATOSPELICULAS P
FULL OUTER JOIN NACIDOS N ON P.NAME = N.NAME
WHERE P.GENDER IS NULL AND
      P.NAME NOT IN (
        SELECT *
        FROM REPETIDO
        );
-- Número de género NULL en datos de base (sin los repetidos)
SELECT COUNT(*) 
FROM DATOSDB.DATOSPELICULAS
WHERE GENDER IS NULL AND
      NAME NOT IN (SELECT * FROM REPETIDO);
-- Número de género NULL en datos filtrados
SELECT COUNT(*) 
FROM DATOSPELEXTRA
WHERE GENDER IS NULL AND
      NAME NOT IN (SELECT * FROM REPETIDO);

-- Borramos los elementos intermedios
DROP VIEW NACIDOS;


-- OBTENER DOS GENEROS DE LA MISMA PELÍCULA
SELECT DISTINCT A1.KEYWORD, A2.KEYWORD
FROM  DATOSDB.DATOSPELICULAS A1, DATOSDB.DATOSPELICULAS A2
WHERE A1.TITLE = 'Tacones lejanos' AND
      A2.TITLE = 'Tacones lejanos' AND
      A1.KEYWORD > A2.KEYWORD;

-- OBRA
SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME = 'OBRA';

CREATE VIEW OBRA_REPETIDA AS
SELECT TITLE, KEYWORD, PRODUCTION_YEAR
FROM DATOSDB.DATOSPELICULAS
WHERE KIND='movie'
GROUP BY TITLE, KEYWORD, PRODUCTION_YEAR
ORDER BY TITLE;

SELECT * FROM  DATOSDB.DATOSPELICULAS
WHERE TITLE = 'Canción de cuna';

SELECT distinct A1.TITLE, A1.PRODUCTION_YEAR , A2.PRODUCTION_YEAR
FROM DATOSDB.DATOSPELICULAS A1,DATOSDB.DATOSPELICULAS A2
WHERE A1.PRODUCTION_YEAR <> A2.PRODUCTION_YEAR AND 
      A1.TITLE = A2.TITLE AND
      A1.KIND='movie'
ORDER BY A1.TITLE;

SELECT MAX(COUNT(*))
FROM OBRA_REPETIDA
GROUP BY TITLE,PRODUCTION_YEAR;

SELECT COUNT(*) CONTADOR, TITLE,PRODUCTION_YEAR
FROM OBRA_REPETIDA
GROUP BY TITLE,PRODUCTION_YEAR
ORDER BY CONTADOR DESC;

SELECT DISTINCT TITLE AS TITULO, CONCAT_GENERO(TITLE) GENERO,
       PRODUCTION_YEAR ANYO_ESTRENO
FROM OBRA_REPETIDA;

SELECT CONCAT_GENERO('Tacones lejanos')
FROM DUAL;

SELECT DISTINCT KIND FROM  DATOSDB.DATOSPELICULAS;

SELECT DISTINCT TITLE, SERIE_TITLE
FROM  DATOSDB.DATOSPELICULAS
WHERE KIND='episode' AND
      SERIE_TITLE IS NULL;

-- SQL PARA POBLAR OBRA CON PELICULAS
INSERT INTO OBRA (TITULO, ANYO_ESTRENO,TIPO)
SELECT TITLE, PRODUCTION_YEAR, 'P' TIPO
FROM  DATOSDB.DATOSPELICULAS
WHERE KIND='movie'
GROUP BY TITLE,PRODUCTION_YEAR
ORDER BY TITLE;

DELETE FROM OBRA WHERE ID_OBRA>0;
ROLLBACK;
DROP TABLE CLASIFICAR;
DROP TABLE PARTICIPAR;
DROP TABLE CAPITULO;
DROP TABLE VINCULAR;
DROP TABLE OBRA;
DROP SEQUENCE obr_id_obra_seq;

DESCRIBE OBRA;

-- SQL PARA POBLAR OBRA CON SERIES
INSERT INTO OBRA (TITULO, PERIODO_EMISION, TIPO)
SELECT TITLE, SERIES_YEARS, 'S' TIPO
FROM  DATOSDB.DATOSPELICULAS
WHERE KIND='tv series'
GROUP BY TITLE, SERIES_YEARS
ORDER BY TITLE;

-- Comprueba si una misma serie se ha emitido en periodos diferentes
SELECT distinct A.TITLE, A.SERIES_YEARS, B.SERIES_YEARS
FROM  DATOSDB.DATOSPELICULAS A,  DATOSDB.DATOSPELICULAS B
WHERE A.TITLE = B.TITLE AND
      A.SERIES_YEARS > B.SERIES_YEARS AND
      A.KIND='tv series';

CREATE VIEW series_1 as
SELECT TITLE, SERIES_YEARS, 'S' TIPO
FROM  DATOSDB.DATOSPELICULAS
WHERE KIND='tv series'
GROUP BY TITLE, SERIES_YEARS
ORDER BY TITLE;

CREATE VIEW series_2 as
SELECT TITLE,  'S' TIPO
FROM  DATOSDB.DATOSPELICULAS
WHERE KIND='tv series'
GROUP BY TITLE
ORDER BY TITLE;

SELECT DISTINCT KEYWORD NOMBRE FROM  DATOSDB.DATOSPELICULAS WHERE KEYWORD IS NOT NULL;

-- POBLAR GENERO
INSERT INTO GENERO (NOMBRE)
SELECT DISTINCT KEYWORD NOMBRE 
FROM DATOSDB.DATOSPELICULAS 
WHERE KEYWORD IS NOT NULL;

INSERT INTO CLASIFICAR (OBRA, GENERO)
WITH GENERO_PELI AS
        (SELECT D.TITLE TITULO, D.PRODUCTION_YEAR ANYO_PRODUCCION, D.KEYWORD GENERO,O.ID_OBRA OBRA
        FROM  DATOSDB.DATOSPELICULAS D, OBRA O
        WHERE D.KIND='movie' AND
              D.KEYWORD IS NOT NULL AND
              O.TITULO = D.TITLE AND
              O.ANYO_ESTRENO = D.PRODUCTION_YEAR
        GROUP BY D.TITLE, D.PRODUCTION_YEAR, D.KEYWORD, O.ID_OBRA
        ORDER BY D.TITLE),
    GENERO_SERIE AS
        (SELECT D.TITLE TITULO, D.SERIES_YEARS PERIODO_EMISION, D.KEYWORD GENERO,O.ID_OBRA OBRA
        FROM  DATOSDB.DATOSPELICULAS D, OBRA O
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


SELECT * FROM  DATOSDB.DATOSPELICULAS
WHERE TITLE='A cara descuberta';

SELECT * FROM OBRA
WHERE ID_OBRA=1;

-- Comprobar que el número de registros creados en CLASIFICAR es correcto
WITH C AS (
SELECT D.TITLE, D.PRODUCTION_YEAR, D.KEYWORD FROM  DATOSDB.DATOSPELICULAS D
WHERE D.KIND='movie' AND
      D.KEYWORD IS NOT NULL
GROUP BY D.TITLE, D.PRODUCTION_YEAR, D.KEYWORD)
SELECT COUNT(*) FROM C;

WITH C AS (
SELECT D.TITLE, D.SERIES_YEARS, D.KEYWORD FROM  DATOSDB.DATOSPELICULAS D
WHERE D.KIND='tv series' AND
      D.KEYWORD IS NOT NULL
GROUP BY D.TITLE, D.SERIES_YEARS, D.KEYWORD)
SELECT COUNT(*) FROM C;
select count(*) from clasificar;

-- Pruebas para poblar PARTICIPAR-
-- Primero ver si hay personas con nombre repetido y distinto genero o lugar nacimeinto
SELECT A.NOMBRE, A.GENERO,B.GENERO
FROM PERSONA A, PERSONA B
WHERE A.NOMBRE = B.NOMBRE AND
      A.GENERO > B.GENERO;
-- > No existe el mismo nombre con distinto género
      
SELECT A.ID_PERSONA,A.NOMBRE, A.NACIMIENTO,B.ID_PERSONA,B.NACIMIENTO
FROM PERSONA A, PERSONA B
WHERE A.NACIMIENTO IS NOT NULL AND
      A.NOMBRE = B.NOMBRE AND
      A.NACIMIENTO > B.NACIMIENTO;
-- > Exiten 20 personas con el mismo nombre pero distinto NACIMIENTO
select distinct info_context from  DATOSDB.DATOSPELICULAS;

WITH CUMPLE AS (
    SELECT DISTINCT NAME, PERSON_INFO
    FROM  DATOSDB.DATOSPELICULAS
    WHERE INFO_CONTEXT='birth date')
SELECT A.NAME, A.PERSON_INFO, B.PERSON_INFO
FROM CUMPLE A, CUMPLE B
WHERE A.NAME = B.NAME AND
      A.PERSON_INFO > B.PERSON_INFO;
      
select * from DATOSDB.DATOSPELICULAS
where name='González Sinde, José María';

DROP TABLE DIRECTORIO;
create table directorio (name varchar2(60) not null, person_info varchar2(150), info_context varchar2(25));

-- Tabla DIRECTORIO: recoge todos los nombres que aparecen en DATOSPELICULAS
-- en cada línea se describe alguna información de la persona, si la tiene
INSERT INTO DIRECTORIO (NAME, PERSON_INFO, INFO_CONTEXT)
SELECT NAME, PERSON_INFO, INFO_CONTEXT
FROM DATOSDB.DATOSPELICULAS
WHERE NAME IS NOT NULL
GROUP BY NAME, PERSON_INFO, INFO_CONTEXT;

-- Cuando un NAME no tiene INFO_COTEXT no tiene nada de datos adicionales
SELECT * FROM DIRECTORIO
WHERE (PERSON_INFO IS NULL AND INFO_CONTEXT IS NOT NULL) OR
       (PERSON_INFO IS NOT NULL AND INFO_CONTEXT IS NULL);
       
-- Todas las personas que teniendo algún dato en INFO_CONTEXT
-- aparecen repetidas de nombre con diferentes person_info  para el mismo info_context
SELECT A.NAME, A.PERSON_INFO INFO1, A.INFO_CONTEXT C1, B.PERSON_INFO INFO2, B.INFO_CONTEXT C2
FROM DIRECTORIO A, DIRECTORIO B
WHERE A.INFO_CONTEXT IS NOT NULL AND
      A.NAME=B.NAME AND
      A.INFO_CONTEXT = B.INFO_CONTEXT AND
      A.PERSON_INFO > B.PERSON_INFO
ORDER BY A.NAME;

-- Ayuda a diferenciar las personas con el mismo nombre, añadiendo
-- obra y función de esa persona
CREATE VIEW PERSONA_REPETIDA AS
SELECT TITLE, PRODUCTION_YEAR,SERIES_YEARS,KIND, NAME, PERSON_INFO, INFO_CONTEXT, ROLE
FROM DATOSDB.DATOSPELICULAS
WHERE NAME IN
(SELECT A.NAME
FROM DIRECTORIO A, DIRECTORIO B
WHERE A.INFO_CONTEXT IS NOT NULL AND
      A.NAME=B.NAME AND
      A.INFO_CONTEXT = B.INFO_CONTEXT AND
      A.PERSON_INFO > B.PERSON_INFO)
GROUP BY TITLE, PRODUCTION_YEAR,SERIES_YEARS,KIND, NAME, PERSON_INFO, INFO_CONTEXT, ROLE;

-- TABLA REPETIDO
CREATE TABLE REPETIDO (NOMBRE VARCHAR2(60) PRIMARY KEY);
-- Personas cuyo nombre está repetido al menos una vez
-- Repetido: mismo NAME (NOMBRE) que tiene información de persona
-- diferente para el mismo concepto en al menos una otra tupla de la tabla
INSERT INTO REPETIDO
SELECT distinct A.NAME
FROM DIRECTORIO A, DIRECTORIO B
WHERE A.INFO_CONTEXT IS NOT NULL AND
      A.NAME=B.NAME AND
      A.INFO_CONTEXT = B.INFO_CONTEXT AND
      A.PERSON_INFO > B.PERSON_INFO;

-- COMPROBACIÓN SI EN LOS DATOS FILTRADOS EN EXCEL HAY REPETIDOS

-- Borrar directorio
delete from directorio;
-- Inserta de nuevo en Directorio apuntando a DATOSPELEXTRA
INSERT INTO DIRECTORIO (NAME, PERSON_INFO, INFO_CONTEXT)
SELECT NAME, PERSON_INFO, INFO_CONTEXT
FROM DATOSPELEXTRA
WHERE NAME IS NOT NULL
GROUP BY NAME, PERSON_INFO, INFO_CONTEXT;

-- Borrar REPETIDO
delete from repetido;
-- Insertar de nuevo en REPETIDO
INSERT INTO REPETIDO
SELECT distinct A.NAME
FROM DIRECTORIO A, DIRECTORIO B
WHERE A.INFO_CONTEXT IS NOT NULL AND
      A.NAME=B.NAME AND
      A.INFO_CONTEXT = B.INFO_CONTEXT AND
      A.PERSON_INFO > B.PERSON_INFO;

-- 4 CONSULTAS QUE ASOCIAN A CADA NOMBRE NO REPETIDO
-- UNA DE LAS INFORMACIONES DE PERSONA
WITH CUMPLE AS
(SELECT DISTINCT NAME, PERSON_INFO FECHA_NACIMIENTO
FROM DATOSDB.DATOSPELICULAS
WHERE NAME IS NOT NULL AND
      INFO_CONTEXT = 'birth date' AND
      NAME NOT IN (SELECT * FROM REPETIDO)),
NACIONALIDAD AS
(SELECT DISTINCT NAME, PERSON_INFO LUGAR_NACIMIENTO
FROM DATOSDB.DATOSPELICULAS
WHERE NAME IS NOT NULL AND
      INFO_CONTEXT = 'birth notes' AND
      NAME NOT IN (SELECT * FROM REPETIDO)),
PASSED AS
(SELECT DISTINCT NAME, PERSON_INFO FECHA_FALLECIMIENTO
FROM DATOSDB.DATOSPELICULAS
WHERE NAME IS NOT NULL AND
      INFO_CONTEXT = 'death date' AND
      NAME NOT IN (SELECT * FROM REPETIDO)),
DEATH_PLACE AS
(SELECT DISTINCT NAME, PERSON_INFO LUGAR_FALLECIMIENTO
FROM DATOSDB.DATOSPELICULAS
WHERE NAME IS NOT NULL AND
      INFO_CONTEXT = 'death notes' AND
      NAME NOT IN (SELECT * FROM REPETIDO))
SELECT A.NAME, A.FECHA_NACIMIENTO, B.LUGAR_NACIMIENTO,
       C.FECHA_FALLECIMIENTO, D.LUGAR_FALLECIMIENTO
FROM CUMPLE A, NACIONALIDAD B, PASSED C, DEATH_PLACE D
WHERE A.NAME=B.NAME AND
      A.NAME=C.NAME AND
      A.NAME=D.NAME;
      
-- PARA AHORRAR ESPACIO:
DROP MATERIALIZED VIEW PERSONA_FULL;

-- POBLAR PARTICIPAR
-- La tabla DIRECTORIO debe contener todas las tuplas de DATOSPELICULAS que 
-- contengan alguna información sobre personas. La tabla REPETIDO ha de contener
-- todos los nombres repetidos en la fuente de datos
-- PASO1: Poblar PARTICIPAR con los datos de quien haya participado en pelicula
-- exlcuyendo aqueyos nombres que están repetidos

--TITLE, PRODUCTION_YEAR,
-- A.ID_OBRA, B.ID_PERSONA,
-- ESTA VERSIÓN SOLO USA LAS TUPLAS QUE ESTÉN EN OBRA
CREATE VIEW NOMBRE_FUNCION2 AS
SELECT C.TITLE, C.PRODUCTION_YEAR, C.NAME, C.ROLE, C.ROLE_NAME, C.NOTE
FROM OBRA A, PERSONA B, DATOSDB.DATOSPELICULAS C
WHERE A.TITULO = C.TITLE AND
      A.ANYO_ESTRENO = C.PRODUCTION_YEAR AND
      A.TIPO = 'P' AND
      B.NOMBRE = C.NAME AND
      C.NAME NOT IN (SELECT * FROM REPETIDO)
GROUP BY C.TITLE, C.PRODUCTION_YEAR, C.NAME, C.ROLE, C.ROLE_NAME, C.NOTE;

-- ESTA VERSIÓN USA TODAS LAS TUPLAS DE DATOSPELICULAS QUE TIENEN INFORMACIÓN
-- SOBRE LA FUNCIÓN DE UNA PERSONA EN UNA OBRA
CREATE OR REPLACE VIEW NOMBRE_FUNCION AS
SELECT C.TITLE, C.SERIE_TITLE, C.PRODUCTION_YEAR, C.SERIES_YEARS, C.SERIE_PROD_YEAR, C.KIND, C.NAME, C.ROLE, C.ROLE_NAME, C.NOTE
FROM DATOSDB.DATOSPELICULAS C
WHERE  C.NAME NOT IN (SELECT * FROM REPETIDO)
GROUP BY C.TITLE, C.SERIE_TITLE, C.PRODUCTION_YEAR, C.SERIES_YEARS, C.SERIE_PROD_YEAR, C.KIND, C.NAME, C.ROLE, C.ROLE_NAME, C.NOTE;
-- la diferencia entre las dos counsultas ANTERIORES está en que no hemos
-- registrado todas las personas sin género
select count(*) from NOMBRE_FUNCION;
select count(*) from NOMBRE_FUNCION2;

DROP VIEW NOMBRE_FUNCION;

select count(*) from datosdb.datospeliculas;

select count(*) from obra where tipo='P';
with intermedia as
(select title,production_year from DATOSDB.DATOSPELICULAS
where kind='movie' group by title,production_year)
select count(*) from intermedia;

-- Para poder encontrar una obra en la tabla OBRA necesito diferenciar por TIPO
-- Primer paso es insertar en PARTICIPAR los datos de peliculas
SELECT A.ID_OBRA,A.TIPO, B.ID_PERSONA, C.TITLE, C.PRODUCTION_YEAR, C.NAME, C.ROLE, C.ROLE_NAME, C.NOTE
FROM NOMBRE_FUNCION C
JOIN  OBRA A ON (A.TITULO = C.TITLE AND A.ANYO_ESTRENO = C.PRODUCTION_YEAR AND A.TIPO='P')
JOIN PERSONA B ON B.NOMBRE = C.NAME;

-- Segundo paso es insertar en PARTICIPAR los datos de series
SELECT A.ID_OBRA,A.TIPO, B.ID_PERSONA, C.TITLE, C.SERIES_YEARS, C.NAME, C.ROLE, C.ROLE_NAME, C.NOTE
FROM NOMBRE_FUNCION C
JOIN  OBRA A ON (A.TITULO = C.TITLE AND A.PERIODO_EMISION = C.SERIES_YEARS AND A.TIPO='S')
JOIN PERSONA B ON B.NOMBRE = C.NAME;

-- Investigar sobre capitulos
select * from DATOSDB.DATOSPELICULAS
where kind='episode' and 
serie_title is null;
-- como se ve arriba todo capítulo apunta a una serie
-- falta asegurar si la serie apuntada se puede diferenciar de otra por series_years
select * from DATOSDB.DATOSPELICULAS
where kind='episode' and 
series_years is null;

select * from DATOSDB.DATOSPELICULAS
where kind='tv series';

-- Usando los 4 primeros caracteres de SERIES_YEARS ha de coincidir con el
-- SERIE_PROD_YEAR de un capítulo. Por ahí podremos encontrar el ID_OBRA
SELECT A.TITLE, A.SERIE_TITLE, A.SERIE_PROD_YEAR, A.KIND, B.SERIES_YEARS, B.TITLE
FROM DATOSDB.DATOSPELICULAS A, DATOSDB.DATOSPELICULAS B
WHERE A.KIND = 'episode' AND
      A.SERIE_TITLE = B.TITLE AND
      A.SERIE_PROD_YEAR = SUBSTR(B.SERIES_YEARS,1,4);

-- Tercer paso es insertar en PARTICIPAR los datos de CAPÍTULOS
SELECT A.ID_OBRA,A.TIPO, B.ID_PERSONA, C.TITLE, C.SERIE_TITLE, C.SERIE_PROD_YEAR, C.KIND, C.NAME, C.ROLE, C.ROLE_NAME, C.NOTE
FROM NOMBRE_FUNCION C
JOIN  OBRA A ON (A.TITULO = C.SERIE_TITLE AND C.SERIE_PROD_YEAR = SUBSTR(A.PERIODO_EMISION,1,4) AND A.TIPO='S')
JOIN PERSONA B ON (B.NOMBRE = C.NAME)
WHERE C.KIND = 'episode';

SELECT * FROM PARTICIPAR;
DROP TABLE PARTICIPAR;
describe participar;
ALTER TABLE PARTICIPAR
DISABLE CONSTRAINT participar_pk;
-- CASE WHEN C.ROLE_NAME IS NULL THEN 'no especificado' ELSE C.ROLE_NAME END

-- Iniciamos el poblado real de PARTICIPAR
-- Vista de apoyo con todos los datos de participantes en cualquier obra
CREATE OR REPLACE VIEW NOMBRE_FUNCION AS
SELECT C.TITLE, C.SERIE_TITLE, C.PRODUCTION_YEAR, C.SERIES_YEARS, C.SERIE_PROD_YEAR, C.KIND, C.NAME, C.ROLE, C.ROLE_NAME, C.NOTE
FROM DATOSDB.DATOSPELICULAS C
WHERE  C.NAME NOT IN (SELECT * FROM REPETIDO)
GROUP BY C.TITLE, C.SERIE_TITLE, C.PRODUCTION_YEAR, C.SERIES_YEARS, C.SERIE_PROD_YEAR, C.KIND, C.NAME, C.ROLE, C.ROLE_NAME, C.NOTE;
-- Paso 1 Películas
INSERT INTO PARTICIPAR (OBRA, PERSONA, CLAVE, FUNCION, PAPEL, DESCRIPCION)
SELECT A.ID_OBRA, B.ID_PERSONA, C.ROLE || C.ROLE_NAME || C.NOTE CLAVE, C.ROLE, C.ROLE_NAME, C.NOTE
FROM NOMBRE_FUNCION C
JOIN  OBRA A ON (A.TITULO = C.TITLE AND A.ANYO_ESTRENO = C.PRODUCTION_YEAR AND A.TIPO='P')
JOIN PERSONA B ON B.NOMBRE = C.NAME
WHERE ((C.ROLE_NAME IS NOT NULL AND
            ( C.ROLE = 'actor' OR C.ROLE = 'actress')) 
    OR ( C.ROLE_NAME IS NULL AND 
            ( C.ROLE <> 'actor' AND C.ROLE <> 'actress' )))
GROUP BY A.ID_OBRA, B.ID_PERSONA, C.ROLE, C.ROLE_NAME, C.NOTE;

-- Paso 2 Series
INSERT INTO PARTICIPAR (OBRA, PERSONA, CLAVE, FUNCION, PAPEL, DESCRIPCION)
SELECT A.ID_OBRA, B.ID_PERSONA, C.ROLE || C.ROLE_NAME || C.NOTE CLAVE, C.ROLE, C.ROLE_NAME, C.NOTE
FROM NOMBRE_FUNCION C
JOIN  OBRA A ON (A.TITULO = C.TITLE AND A.PERIODO_EMISION = C.SERIES_YEARS AND A.TIPO='S')
JOIN PERSONA B ON B.NOMBRE = C.NAME
WHERE ((C.ROLE_NAME IS NOT NULL AND
            ( C.ROLE = 'actor' OR C.ROLE = 'actress')) 
    OR ( C.ROLE_NAME IS NULL AND 
            ( C.ROLE <> 'actor' AND C.ROLE <> 'actress' )))
GROUP BY A.ID_OBRA, B.ID_PERSONA, C.ROLE, C.ROLE_NAME, C.NOTE;

SELECT A.ID_OBRA,A.TIPO, B.ID_PERSONA, C.TITLE, C.SERIE_TITLE, C.SERIE_PROD_YEAR, C.KIND, C.NAME, C.ROLE, C.ROLE_NAME, C.NOTE
FROM NOMBRE_FUNCION C
JOIN  OBRA A ON (A.TITULO = C.SERIE_TITLE AND C.SERIE_PROD_YEAR = SUBSTR(A.PERIODO_EMISION,1,4) AND A.TIPO='S')
JOIN PERSONA B ON (B.NOMBRE = C.NAME)
WHERE C.KIND = 'episode';

-- Paso 3 Capítulos
CREATE OR REPLACE VIEW PARTICIPA_CAPITULO AS
SELECT A.ID_OBRA OBRA, B.ID_PERSONA PERSONA, C.ROLE || C.ROLE_NAME || C.NOTE CLAVE, C.ROLE FUNCION, C.ROLE_NAME PAPEL, C.NOTE DESCRIPCION
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
INSERT INTO PARTICIPAR (OBRA, PERSONA, CLAVE, FUNCION, PAPEL, DESCRIPCION)
SELECT OBRA, PERSONA, CLAVE, FUNCION, PAPEL, DESCRIPCION FROM PARTICIPA_CAPITULO
MINUS
SELECT OBRA, PERSONA, CLAVE, FUNCION, PAPEL, DESCRIPCION FROM PARTICIPAR;

-- Poblar tabla VINCULAR
-- Por si hay que volver a poner primary key como contador secuencial
-- TABLA VINCULAR --

-- Polblar VINCULAR: REMAKE
INSERT INTO VINCULAR (obra_1, obra_2, vinculo)
SELECT DISTINCT O1.id_obra, O2.id_obra, 'remake' vinculo
FROM DATOSDB.DATOSPELICULAS M, OBRA O1, OBRA O2
WHERE --M.link = 'remake of' OR M.link = -- Completar .... AND
    (M.link = 'version of' OR M.link = 'remake of') AND
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
WHERE --M.link = 'remake of' OR M.link = -- Completar .... AND
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
SELECT DISTINCT O2.id_obra, O1.id_obra, 'secuela' vinculo
FROM DATOSDB.DATOSPELICULAS M, OBRA O1, OBRA O2
WHERE --M.link = 'remake of' OR M.link = -- Completar .... AND
    M.link = 'followed by'  AND
    M.kind = 'movie' AND
    O1.titulo = M.title AND
    O1.anyo_estreno = M.production_year AND
    O2.titulo = M.titlelink AND
    O2.anyo_estreno = M.productionyearlink AND
    O1.TIPO = 'P' AND O2.TIPO = 'P' AND
    O1.anyo_estreno < O2.anyo_estreno;
    
INSERT INTO VINCULAR (obra_1, obra_2, vinculo)
SELECT DISTINCT O1.id_obra, O2.id_obra, 'secuela' vinculo
FROM DATOSDB.DATOSPELICULAS M, OBRA O1, OBRA O2
WHERE --M.link = 'remake of' OR M.link = -- Completar .... AND
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
WHERE --M.link = 'remake of' OR M.link = -- Completar .... AND
    M.link = 'follows'  AND
    M.kind = 'movie' AND
    O1.titulo = M.title AND
    O1.anyo_estreno = M.production_year AND
    O2.titulo = M.titlelink AND
    O2.anyo_estreno = M.productionyearlink AND
    O1.TIPO = 'P' AND O2.TIPO = 'P' AND
    O1.anyo_estreno < O2.anyo_estreno;

INSERT INTO VINCULAR (obra_1, obra_2, vinculo)
SELECT DISTINCT O1.id_obra, O2.id_obra, 'precuela' vinculo
FROM DATOSDB.DATOSPELICULAS M, OBRA O1, OBRA O2
WHERE --M.link = 'remake of' OR M.link = -- Completar .... AND
    M.link = 'followed by'  AND
    M.kind = 'movie' AND
    O1.titulo = M.title AND
    O1.anyo_estreno = M.production_year AND
    O2.titulo = M.titlelink AND
    O2.anyo_estreno = M.productionyearlink AND
    O1.TIPO = 'P' AND O2.TIPO = 'P' AND
    O1.anyo_estreno > O2.anyo_estreno;
    
CREATE OR REPLACE VIEW VINCULO_REPE AS
SELECT DISTINCT O1.id_obra obra_1, O2.id_obra obra_2, 'precuela' vinculo
FROM DATOSDB.DATOSPELICULAS M, OBRA O1, OBRA O2
WHERE --M.link = 'remake of' OR M.link = -- Completar .... AND
    M.link = 'followed by'  AND
    M.kind = 'movie' AND
    O1.titulo = M.title AND
    O1.anyo_estreno = M.production_year AND
    O2.titulo = M.titlelink AND
    O2.anyo_estreno = M.productionyearlink AND
    O1.TIPO = 'P' AND O2.TIPO = 'P';
    
select v.obra_1,v.obra_2,v.vinculo 
from vincular v
where v.obra_1 in (select obra_1 from vinculo_repe) and
      v.obra_2 in (select obra_2 from vinculo_repe);

DELETE FROM VINCULAR
WHERE OBRA_1=2929 AND OBRA_2=2408 AND VINCULO='remake';
select title, link, titlelink;

CREATE OR REPLACE VIEW VINCULO_EXPLICADO AS
SELECT V.OBRA_1 OBRA1, O1.TITULO TITULO1, O1.ANYO_ESTRENO ANYO_ESTRENO_1,V.VINCULO, V.OBRA_2 OBRA2, B.TITULO TITULO2, B.ANYO_ESTRENO ANYO_ESTRENO_2
FROM VINCULAR V, OBRA O1, OBRA B
WHERE V.OBRA_1=O1.ID_OBRA AND
      V.OBRA_2=B.ID_OBRA;

select distinct link from DATOSDB.DATOSPELICULAS
where link is not null;

select distinct title,production_year, link, titlelink,productionyearlink
from DATOSDB.DATOSPELICULAS
where link='followed by'
order by production_year;

select * from DATOSDB.DATOSPELICULAS
where title = 'Sense títol, s/n' or
title = 'Sense títol 2';

delete from vincular;

select * from DATOSDB.DATOSPELICULAS
where title = 'El hombre perseguido por un O.V.N.I.' and
titlelink='Sueca bisexual necesita semental';

select * from obra
where id_obra=3332;

-- conculta 2 versión NURIA
select  a.primera_obra, a.num_secuelas
from
(
SELECT DISTINCT (v.obra_1) AS primera_obra,
(select count(*) from vincular v1 WHERE v1.obra_2=v.obra_1 and v1.vinculo='secuela' ) as num_secuelas
FROM vincular  v
WHERE (((v.obra_1) Not In (SELECT distinct V1.OBRA_1 FROM vincular V1 WHERE V1.VINCULO IN ('secuela', 'remake'))))
) a
order by a.num_secuelas desc;

-- Parejas actor / actriz de diferente nacionalidad
SELECT p1.id_persona P1, p1.nombre N1,p1.genero G1, p2.id_persona P2, p2.nombre N2,p2.genero G2
FROM persona p1, persona p2
WHERE p1.id_persona>p2.id_persona AND
    (p1.genero='m' AND p2.genero='f') OR  (p1.genero='f' AND p2.genero='m') AND
    p1.nacimiento <> p2.nacimiento;
    
SELECT p1.persona idp_1, g1.nombre nombre1, p2.persona idp_2, g2.nombre nombre2
FROM participar p1, participar p2, obra o, persona g1, persona g2
WHERE p1.obra = o.id_obra AND
      o.tipo = 'P' AND
      p1.persona > p2.persona AND
      (p1.funcion = 'actor' OR p1.funcion = 'actress') AND
      (p2.funcion = 'actor' OR p2.funcion = 'actress') AND
      ( o.anyo_estreno >= 1980 AND
        o.anyo_estreno <= 2010 ) AND
      p1.persona = g1.id_persona AND
      p2.persona = g2.id_persona AND
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
      )
GROUP BY p1.persona, g1.nombre, p2.persona, g2.nombre
ORDER BY contador DESC;

select count(*) from participar;

create table iden_pais as
select distinct nacimiento from persona;
alter table iden_pais add (pais varchar2(35));

select trim(substr('Russia Ukraine',instr('Russia Ukraine','now',-1)+3)) from dual;

update iden_pais set pais = 
case
    when instr(nacimiento,'now',-1)=0 then nacimiento
    else trim(substr(nacimiento,instr(nacimiento,'now',-1)+3))
end;

select * from DATOSDB.DATOSPELICULAS
where person_info like '%Yugoslavia%' and
info_context='birth notes';

select * from iden_pais
where nacimiento like '%Bosnia and Her%';

select * from persona where nacimiento ='No definido';

UPDATE persona SET nacimiento = 'No definido'
WHERE nacimiento IS NULL;

CREATE TABLE pais (
    id_pais     NUMBER(12) CONSTRAINT pais_pk PRIMARY KEY,
    denominacion      VARCHAR2(40)
);

CREATE SEQUENCE id_pais_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER id_pais_trg BEFORE
    INSERT ON pais
    FOR EACH ROW
    WHEN ( new.id_pais IS NULL )
BEGIN
    :new.id_pais := id_pais_seq.nextval;
END;

-- Poblar la tabla PAIS con los diferentes paises que se han filtrado en iden_pais
INSERT INTO pais (denominacion)
SELECT DISTINCT pais
FROM iden_pais
ORDER BY pais;

-- Añade el campo id_pais a IDEN_PAIS
ALTER TABLE iden_pais add (id_pais NUMBER(12));

-- Puebla el campo id_pais de IDEN_PAIS con la clave del pais en tabla PAIS
UPDATE iden_pais SET id_pais = (
    SELECT p.id_pais
    FROM pais p
    WHERE p.denominacion = pais);

-- Comprueba que está bien poblado
with tablas_c as (
select d.nacimiento, d.pais pais_or, p.denominacion pais_2, d.id_pais id_or, p.id_pais id_2
from iden_pais d, pais p
where d.id_pais = p.id_pais)
select *
from tablas_c
where id_or <> id_2;

-- Define clave primaria en IDEN_PAIS una vez poblada
ALTER TABLE iden_pais ADD CONSTRAINT iden_pais_pk PRIMARY KEY (nacimiento);
-- Una vez poblado define id_pais de IDEN_PAIS como clave ajena
-- alter table iden_pais drop constraint iden_pais_pais_fk;
ALTER TABLE iden_pais MODIFY (id_pais NUMBER(12) NOT NULL);
ALTER TABLE iden_pais ADD CONSTRAINT iden_pais_pais_fk 
    FOREIGN KEY (id_pais) REFERENCES pais (id_pais);
DESCRIBE IDEN_PAIS;

select * from datosdb.datospeliculas
where name is not null and
role='writer';

delete from vincular;

select count(*) from persona;

SELECT * FROM DIRECTORIO
WHERE NAME LIKE 'Moreno%';


ALTER TABLE VINCULAR DROP CONSTRAINT vincular_pk;
ALTER TABLE VINCULAR ADD CONSTRAINT vincular_pk PRIMARY KEY (obra_1, obra_2);

delete from vincular;

alter table iden_pais drop column id_pais;

CREATE OR REPLACE PROCEDURE UpdatePersonaNacimiento AS
    v_pais iden_pais.pais%TYPE;
BEGIN
    FOR rec IN (SELECT p.id_persona, p.nacimiento
                FROM persona p
                WHERE p.nacimiento IS NOT NULL)
    LOOP
        -- Busca en la tabla IDEN_PAIS el valor de pais para este nacimiento
        SELECT iden_p.pais
        INTO v_pais
        FROM iden_pais iden_p
        WHERE iden_p.nacimiento = rec.nacimiento;

        -- Altera el valor de nacimiento en la tabla persona al valor de pais
        UPDATE persona
        SET nacimiento = v_pais
        WHERE id_persona = rec.id_persona;
    END LOOP;
END;
/

BEGIN
    UpdatePersonaNacimiento;
    COMMIT;
END;
/


SELECT p1.persona idp_1, g1.nombre nombre1, p2.persona idp_2, g2.nombre nombre2
FROM participar p1, participar p2, obra o, persona g1, persona g2, iden_pais ip1, iden_pais ip2
WHERE p1.obra = o.id_obra AND
      o.tipo = 'P' AND
      p1.persona > p2.persona AND
      (p1.funcion = 'actor' OR p1.funcion = 'actress') AND
      (p2.funcion = 'actor' OR p2.funcion = 'actress') AND
      ( o.anyo_estreno >= 1980 AND
        o.anyo_estreno <= 2010 ) AND
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
      
select count(*) from participar;
select * from participar;

select * from participar
where persona in (10186,24671);

with p1 as(
SELECT p.obra, p.persona
                FROM participar p
                WHERE p.funcion IN ('actor', 'actress'))
select count(*) from p1;


SELECT ip.pais
        FROM persona p, iden_pais ip
        WHERE p.id_persona = 1 AND
              p.nacimiento = 'Spain';
              

SELECT p1.persona idp_1, g1.nombre nombre1, p2.persona idp_2, g2.nombre nombre2
FROM participar p1, participar p2, obra o, persona g1, persona g2, iden_pais ip1, iden_pais ip2
WHERE NOT EXISTS (
        SELECT p3.obra
        FROM participar p3
        WHERE p3.persona = p1.persona AND
              p3.anyo_estreno BETWEEN 1980 AND 2010 AND
              (p1.funcion IN ('actor', 'actress')) AND
              (p2.funcion IN ('actor', 'actress')) AND
              p2.persona NOT IN (
                SELECT p4.persona
                FROM participar p4
                WHERE p4.persona = p2.persona AND
                      p4.obra = p3.obra
              )
      )
p1.obra = o.id_obra AND
      o.tipo = 'P' AND
      p1.persona > p2.persona AND
      (p1.funcion = 'actor' OR p1.funcion = 'actress') AND
      (p2.funcion = 'actor' OR p2.funcion = 'actress') AND
      ( o.anyo_estreno >= 1980 AND
        o.anyo_estreno <= 2010 ) AND
      p1.persona = g1.id_persona AND
      p2.persona = g2.id_persona AND
      g1.nacimiento IS NOT NULL AND
      g1.nacimiento = ip1.nacimiento AND
      g2.nacimiento = ip2.nacimiento AND
      ip1.pais > ip2.pais AND
      ((g1.genero='m' AND g2.genero='f') OR
      (g1.genero='f' AND g2.genero='m')) AND
      ;

WITH Actores AS (
    SELECT pa.persona AS personaID, p.nombre AS nombre, pa.pais AS paisNacimiento, pa.obra AS obraID
    FROM participar pa
    JOIN persona p ON pa.persona = p.id_persona
    WHERE pa.funcion IN ('actor')
        AND pa.tipo = 'P'
        AND pa.anyo_estreno BETWEEN 1980 AND 2010 
),
Actrices AS (
    SELECT pa.persona AS personaID, p.nombre AS nombre, pa.pais AS paisNacimiento, pa.obra AS obraID
    FROM participar pa
    JOIN persona p ON pa.persona = p.id_persona
    WHERE pa.funcion IN ('actress')
        AND pa.tipo = 'P'
        AND pa.anyo_estreno BETWEEN 1980 AND 2010  
)
SELECT a.personaID AS ApersonaID,a.nombre AS actor_nombre, a.paisNacimiento AS actor_pais, b.personaID AS BpersonaID, b.nombre AS actriz_nombre, b.paisNacimiento AS actriz_pais,
    COUNT(*) AS NumPelis,
    (SELECT COUNT(*) FROM Actores ac WHERE ac.personaID = a.personaID) AS TotalPelisActor,
    (SELECT COUNT(*) FROM Actrices act WHERE act.personaID = b.personaID) AS TotalPelisActriz
FROM Actores a
JOIN Actrices b ON a.obraID = b.obraID AND a.paisNacimiento != b.paisNacimiento
GROUP BY a.personaID, a.nombre, a.paisNacimiento, b.personaID, b.personaID, b.nombre, b.paisNacimiento
HAVING 
    COUNT(*) = (SELECT COUNT(*) FROM Actores ac WHERE ac.personaID = a.personaID)
    AND COUNT(*) = (SELECT COUNT(*) FROM Actrices act WHERE act.personaID = b.personaID)
ORDER BY 
    NumPelis DESC;
    
SELECT a.nombre AS actor_nombre, a.paisNacimiento AS actor_pais, b.nombre AS actriz_nombre, b.paisNacimiento AS actriz_pais, COUNT(*) AS NumPelis, a.TotalPelisActor, b.TotalPelisActriz 
FROM (
    SELECT p.nombre, ip.pais AS paisNacimiento, COUNT(*) AS TotalPelisActor 
    FROM participar pa 
    JOIN persona p ON pa.persona = p.id_persona 
    JOIN iden_pais ip ON p.nacimiento = ip.nacimiento 
    WHERE pa.funcion = 'actor' 
    GROUP BY p.nombre, ip.pais
) a, 
(
    SELECT p.nombre, ip.pais AS paisNacimiento, COUNT(*) AS TotalPelisActriz 
    FROM participar pa 
    JOIN persona p ON pa.persona = p.id_persona 
    JOIN iden_pais ip ON p.nacimiento = ip.nacimiento 
    WHERE pa.funcion = 'actress' 
    GROUP BY p.nombre, ip.pais
) b 
WHERE a.paisNacimiento != b.paisNacimiento 
GROUP BY a.nombre, b.nombre, a.paisNacimiento, b.paisNacimiento, a.TotalPelisActor, b.TotalPelisActriz 
ORDER BY NumPelis DESC;