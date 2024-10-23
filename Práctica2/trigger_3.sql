CREATE OR REPLACE TRIGGER mantener_particion
BEFORE INSERT ON participar
FOR EACH ROW
DECLARE
   
BEGIN
    IF :NEW.funcion = 'actress' THEN
        :NEW.particion_funcion := 'actress';
    ELSIF :NEW.funcion = 'actor' THEN
        :NEW.particion_funcion := 'actor';
    END IF;
END;
/