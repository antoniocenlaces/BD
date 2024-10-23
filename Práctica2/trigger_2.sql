CREATE OR REPLACE TRIGGER verifica_participar
BEFORE INSERT ON participar
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM participar
    WHERE obra = :NEW.obra
      AND persona = :NEW.persona
      AND funcion = :NEW.funcion
      AND ((:NEW.papel IS NULL AND descripcion = :NEW.descripcion) OR
           (:NEW.descripcion IS NULL AND papel = :NEW.papel));

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Existe otra fila con el mismo valor de obra, persona, y funcion. Esta nueva fila debe tener papel o descripcion diferente.');
    END IF;
END;
/