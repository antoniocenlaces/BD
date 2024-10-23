--CUESTION 1: Directores para los cuales la última película en la que han participado ha sido como actor/actriz
EXPLAIN PLAN FOR
WITH DIRECTORES AS (
    SELECT DISTINCT persona
    FROM PARTICIPAR P
    INNER JOIN OBRA O ON O.id_obra = P.obra
    WHERE O.tipo = 'P' 
    AND (P.funcion = 'actress' OR P.funcion = 'actor')    
    AND O.año_estreno >= (
        SELECT MAX(OAux.año_estreno)
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
DROP TABLE IDEN_PAIS;
DROP TABLE PAIS;
DROP SEQUENCE id_pais_seq;
DROP TRIGGER id_pais_trg;

-- Tablas auxiliares para diferenciar cada persona por nacionalidad

-- Tabla PAIS
CREATE TABLE pais (
    id_pais         NUMBER(12) CONSTRAINT pais_pk PRIMARY KEY,
    denominacion    VARCHAR2(40) NOT NULL
);

CREATE SEQUENCE id_pais_seq INCREMENT BY 1 START WITH 124 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER id_pais_trg BEFORE
    INSERT ON pais
    FOR EACH ROW
    WHEN ( new.id_pais IS NULL )
BEGIN
    :new.id_pais := id_pais_seq.nextval;
END;

-- Tabla IDEN_PAIS que contiene todos los diferentes lugares de nacimiento
-- que aparecen en la tabla PERSONA, además indicando a qué país pertenece
CREATE TABLE iden_pais (
    nacimiento  VARCHAR2(60) CONSTRAINT iden_pais_pk PRIMARY KEY,
    pais        VARCHAR2(35) NOT NULL,
    id_pais     NUMBER(12)   NOT NULL,
    CONSTRAINT pais_iden_pais_fk FOREIGN KEY (id_pais) REFERENCES pais (id_pais)
);

-- Con las tablas creadas hay que importar los datos para poblarlas
-- Importar primero el excel PAIS.xlsx a la tabla PAIS
-- Importar excel IDEN_PAIS.xlsx a la tabla IDEN_PAIS
-- Siguiente consulta compruba que está bien poblado

-- ¡OJO! hay que volver a poblar persona con los datos de nacimiento de repetidos

-- Alterar tabla PERSONA para apuntar al país de cada lugar de nacimiento
ALTER TABLE persona ADD (pais NUMBER(12));
ALTER TABLE persona DROP (PAIS);

UPDATE persona SET nacimiento = (
    SELECT d.pais
    FROM iden_pais d
    WHERE d.nacimiento = nacimiento and
    rownum =1
);

CREATE OR REPLACE PROCEDURE UpdatePersonaNacimiento AS
    v_pais iden_pais.pais%TYPE;
BEGIN
    FOR rec IN (SELECT p.id_persona, p.nacimiento
                FROM persona p)
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
SELECT p1.persona idp_1, g1.nombre nombre1, p2.persona idp_2, g2.nombre nombre2, COUNT(*) contador
FROM participar p1, participar p2, obra o, persona g1, persona g2
WHERE p1.obra = o.id_obra AND
      o.tipo = 'P' AND
      p1.persona > p2.persona AND
      (p1.funcion = 'actor' OR p1.funcion = 'actress') AND
      (p2.funcion = 'actor' OR p2.funcion = 'actress') AND
      ( o.año_estreno >= 1980 AND
        o.año_estreno <= 2010 ) AND
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
