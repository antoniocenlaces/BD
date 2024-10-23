--CUESTION 1: Directores para los cuales la última película en la que han participado ha sido como actor/actriz
CREATE OR REPLACE VIEW DIRECTORES AS 
SELECT distinct persona
FROM PARTICIPAR P, OBRA O
WHERE O.id_obra = P.obra AND --JOIN
    O.tipo = 'P' AND (P.funcion = 'actress' OR P.funcion = 'actor')    
    AND O.año_estreno >= (
    SELECT max(OAux.año_estreno)
    FROM PARTICIPAR PAux, OBRA OAux
    WHERE PAux.obra = OAux.id_obra --JOIN
        AND PAux.funcion = 'director' AND P.persona = PAux.persona);

SELECT P.nombre
FROM DIRECTORES D, PERSONA P
WHERE P.id_persona = D.persona;

select count(distinct name) from datosdb.datospeliculas;
select count(distinct name) from datospelextra;
select count(*) from persona;
