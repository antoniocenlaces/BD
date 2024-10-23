CREATE or REPLACE TRIGGER noJuegaSiMismo
BEFORE INSERT ON partido  --  debemos verificar que se inserte en la tabla de manera correcta
FOR EACH ROW
WHEN (new.equipo_local = new.equipo_visitante) -- cuando los dos equipos son el mismo

DECLARE NO_AUTO_PARTIDO EXCEPTION;  -- declaración de excepción
BEGIN
    RAISE NO_AUTO_PARTIDO;  -- lanzamos una excepción para que no se inserten los datos que violan las condiciones de la base de datos
                                                         
END;

CREATE or REPLACE TRIGGER soloUnaDivision
BEFORE INSERT division on partido
FOR EACH ROW
DECLARE VARCHAR2(25) _division
BEGIN
    --vigilar equipo local
    SELECT divison INTO _division --devuelve la division en la que ha 
                                    jugado el equipo local.
                                    Si no ha jugado devuelve null
    FROM PARTICIPAR
    WHERE equipo_local = :new.equipo_local OR --el equipo ya ha jugado de visitante O                                           
          equipo_visitante = :new.equipo_local -- de visitante
    AND temporada = :new.temporada -- en esta temporada
    GROUP BY division

    if division is not NULL THEN --si el equipo no ha jugado esta temporda
        :new.division = _division --se asigna esta temporada como la "buena"
    end if;
END;


CREATE or REPLACE TRIGGER soloUnaDivision
BEFORE INSERT division on partido
FOR EACH ROW
DECLARE VARCHAR2(25) _division
BEGIN
    --vigilar equipo local
    SELECT divison INTO _division --devuelve la division en la que ha 
                                    jugado el equipo local.
                                    Si no ha jugado devuelve null
    FROM PARTICIPAR
    WHERE equipo_local = :new.equipo_visitante OR --el equipo ya ha jugado de visitante O
          equipo_visitante = :new.equipo_visitante -- de visitante
    AND temporada = :new.temporada -- en esta temporada
    GROUP BY division

    if division is not NULL THEN --si el equipo no ha jugado esta temporda
        :new.division = _division --se asigna esta temporada como la "buena"
    end if;
END;

CREATE or REPLACE TRIGGER unaVezXJornada
BEFORE INSERT ON partido
FOR EACH ROW
DECLARE INT n
DECLARE NO_AUTO_JORNADA EXCEPTION;  -- declaración de excepción
BEGIN
    SELECT COUNT(*) INTO n -- contamos cuántas veces ha jugado durante esta jornada en esta temporada                     
    FROM partido
    WHERE jornada = :new.jornada AND temporada = :new.temporada
                                                               
    if n is not 0 THEN -- si no es cero ya ha jugado, lanzamos una excepción
        RAISE NO_AUTO_PARTIDO;  
    end if;
END;
