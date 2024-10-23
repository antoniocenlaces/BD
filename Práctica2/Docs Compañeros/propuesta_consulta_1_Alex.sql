--CUESTION 1: Directores para los cuales la �ltima pel�cula en la que han participado ha sido como actor/actriz
SELECT PERS.nombre
FROM PERSONA PERS
WHERE PERS.id_persona = (
    SELECT persona
    FROM PARTICIPAR P, OBRA O
    WHERE O.id_obra = P.obra AND --JOIN
        O.tipo = 'P' AND (P.funcion = 'actress' OR P.funcion = 'actor')    
        AND O.a�o_produccion > (
        SELECT OAux.a�o_produccion
        FROM PARTICIPAR PAux, OBRA OAux
        WHERE PAux.obra = OAux.id_obra --JOIN
            AND PAux.funcion = 'director' AND P.persona = PAux.persona));