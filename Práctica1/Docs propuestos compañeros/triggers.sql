-- Prueba de guardado
--Un equipo NO puede jugar contra sí mismo
CREATE or REPLACE TRIGGER noJuegaSiMismo
BEFORE INSERT ON partido
FOR EACH ROW
WHEN (new.equipo_local = new.equipo_visitante) 
DECLARE NO_AUTO_PARTIDO EXCEPTION;
BEGIN
    RAISE NO_AUTO_PARTIDO;
END;

--Un equipo SOLO puede jugar en una divison y promociones durante una temporada
--trigger del equipo local
CREATE or REPLACE TRIGGER soloUnaDivision
BEFORE INSERT on partido
FOR EACH ROW
DECLARE _division VARCHAR2(25); 
BEGIN
    --vigilar equipo local
    SELECT divison INTO _division --devuelve la division en la que ha jugado el equipo local SI YA HA JUGADO EN ESA TEMPORADA
    FROM PARTICIPAR
    WHERE equipo_local = :new.equipo_local OR equipo_visitante = :new.equipo_local
    AND temporada = :new.temporada
    GROUP BY division;

    if division is not NULL THEN
        :new.division := _division
    end if;
END;


--trigger del equipo visitante
CREATE or REPLACE TRIGGER soloUnaDivision
BEFORE INSERT division on partido
FOR EACH ROW
DECLARE VARCHAR2(25) _division
BEGIN
    --vigilar equipo local
    SELECT divison INTO _division --devuelve la division en la que ha jugado el equipo local SI YA HA JUGADO EN ESA TEMPORADA
    FROM PARTICIPAR
    WHERE equipo_local = :new.equipo_visitante OR equipo_visitante = :new.equipo_visitante
    AND temporada = :new.temporada
    GROUP BY division

    if division is not NULL THEN
        :new.division := _division
    end if;
END;

--Un equipo solo puede jugar UNA VEZ en cada JORNADA
CREATE or REPLACE TRIGGER unaVezXJornada
BEFORE INSERT jornada on partido
FOR EACH ROW
DECLARE INT n
BEGIN
    SELECT COUNT(*) INTO n
    FROM partido
    WHERE jornada = :new.jornada AND temporada = :new.temporada
    
    if n is not 0 THEN
        raise exception("Un equipo no puede jugar dos veces en una jornada")
    end if;
END;
