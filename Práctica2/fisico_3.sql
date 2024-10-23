ALTER TABLE participar
ADD anyo_estreno NUMBER(5)
ADD tipo         VARCHAR2(1)
ADD genero       VARCHAR2(1)
ADD pais         VARCHAR2(35);

CREATE OR REPLACE PROCEDURE UpdateParticipar AS
    v_estreno  obra.anyo_estreno%TYPE;
    v_genero   persona.genero%TYPE;
    v_pais     iden_pais.pais%TYPE;
    
BEGIN
    FOR rec IN (SELECT p.obra, p.persona
                FROM participar p, persona n, obra o
               WHERE p.funcion IN ('actor', 'actress') AND
                      p.persona = n.id_persona AND
                      n.nacimiento IS NOT NULL AND
                      o.id_obra = p.obra AND
                      o.id_obra = 'P')
    LOOP
        -- Busca en la tabla OBRA el valor de anyo_estreno y tipo
        SELECT o.anyo_estreno
        INTO v_estreno
        FROM obra o
        WHERE o.id_obra = rec.obra;
        -- Busca en la tabla PERSONA el valor de genero para esta persona
        SELECT p.genero
        INTO v_genero
        FROM persona p
        WHERE p.id_persona = rec.persona;
        -- Busca en la tabla IDEN_PAIS el valor de pais para esta persona
        SELECT ip.pais
        INTO v_pais
        FROM persona p, iden_pais ip
        WHERE p.id_persona = rec.persona AND
              p.nacimiento = ip.nacimiento;

        -- Altera el valor de nacimiento en la tabla persona al valor de pais
        UPDATE participar
        SET anyo_estreno = v_estreno,
            tipo = 'P',
            genero = v_genero,
            pais = v_pais
        WHERE obra = rec.obra AND
              persona = rec.persona;
    END LOOP;
END;
/

BEGIN
    UpdateParticipar;

END;
/

CREATE OR REPLACE PROCEDURE UpdateParticipar1 AS
    v_estereno obra.anyo_estreno%TYPE;    
BEGIN
    FOR rec IN (SELECT p.obra
                FROM participar p
                WHERE p.funcion IN ('actor', 'actress'))
    LOOP
        -- Busca en la tabla OBRA el valor de anyo_estreno y tipo
        SELECT o.anyo_estreno
        INTO v_estereno
        FROM obra o
        WHERE o.id_obra = rec.obra;

        -- Altera el valor de nacimiento en la tabla persona al valor de pais
        UPDATE participar
        SET anyo_estreno = v_estereno
        WHERE obra = rec.obra;
    END LOOP;
END;
/

BEGIN
    UpdateParticipar1;

END;
/

CREATE OR REPLACE PROCEDURE UpdateParticipar2 AS
    v_tipo     obra.tipo%TYPE;    
BEGIN
    FOR rec IN (SELECT p.obra
                FROM participar p
                WHERE p.funcion IN ('actor', 'actress'))
    LOOP
       -- Busca en la tabla OBRA el valor de anyo_estreno y tipo
        SELECT o.tipo
        INTO v_tipo
        FROM obra o
        WHERE o.id_obra = rec.obra;

        -- Altera el valor de nacimiento en la tabla persona al valor de pais
        UPDATE participar
        SET tipo = v_tipo
        WHERE obra = rec.obra;
    END LOOP;
END;
/

BEGIN
    UpdateParticipar2;

END;
/

CREATE OR REPLACE PROCEDURE UpdateParticipar3 AS
    v_genero   persona.genero%TYPE;    
BEGIN
    FOR rec IN (SELECT p.persona
                FROM participar p
                WHERE p.funcion IN ('actor', 'actress'))
    LOOP
       -- Busca en la tabla PERSONA el valor de genero para esta persona
        SELECT p.genero
        INTO v_genero
        FROM persona p
        WHERE p.id_persona = rec.persona;

        -- Altera el valor de nacimiento en la tabla persona al valor de pais
        UPDATE participar
        SET genero = v_genero
        WHERE persona = rec.persona;
    END LOOP;
END;
/

BEGIN
    UpdateParticipar3;

END;
/
CREATE OR REPLACE PROCEDURE UpdateParticipar4 AS
    v_pais     iden_pais.pais%TYPE;    
BEGIN
    FOR rec IN (SELECT p.persona
                FROM participar p, persona n
                WHERE p.funcion IN ('actor', 'actress') AND
                      p.persona = n.id_persona AND
                      n.nacimiento IS NOT NULL)
    LOOP
       -- Busca en la tabla IDEN_PAIS el valor de pais para esta persona
        SELECT ip.pais
        INTO v_pais
        FROM persona p, iden_pais ip
        WHERE  p.id_persona = rec.persona AND
               p.nacimiento = ip.nacimiento;

        -- Altera el valor de nacimiento en la tabla persona al valor de pais
        UPDATE participar
        SET pais = v_pais
        WHERE persona = rec.persona;
    END LOOP;
END;
/

BEGIN
    UpdateParticipar4;

END;
/


SELECT  g1.nombre AS nombre1, g2.nombre AS nombre2, COUNT(*) AS contador
FROM participar p1
JOIN participar p2 ON p1.persona > p2.persona
JOIN persona g1 ON p1.persona = g1.id_persona
JOIN persona g2 ON p2.persona = g2.id_persona
WHERE p1.tipo = 'P'
  AND (p1.funcion IN ('actor', 'actress'))
  AND (p2.funcion IN ('actor', 'actress'))
  AND p1.anyo_estreno BETWEEN 1980 AND 2010
  AND ((p1.genero='m' AND p2.genero='f') OR (p1.genero='f' AND p2.genero='m'))
  AND NOT EXISTS (
    SELECT 1
    FROM participar p3
    WHERE p3.persona = p1.persona
      AND NOT EXISTS (
        SELECT 1
        FROM participar p4
        WHERE p4.persona = p2.persona AND p4.obra = p3.obra
      )
  )
GROUP BY g1.nombre, g2.nombre
ORDER BY contador DESC;


SELECT  g1.nombre AS nombre1, g2.nombre AS nombre2 -- COUNT(*) AS contador
FROM participar p1
JOIN participar p2 ON p1.persona > p2.persona
JOIN persona g1 ON p1.persona = g1.id_persona
JOIN persona g2 ON p2.persona = g2.id_persona
WHERE p1.tipo = 'P'
  AND (p1.funcion IN ('actor', 'actress'))
  AND (p2.funcion IN ('actor', 'actress'))
  AND p1.anyo_estreno BETWEEN 1980 AND 2010
  AND ((p1.genero='m' AND p2.genero='f') OR (p1.genero='f' AND p2.genero='m'))
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