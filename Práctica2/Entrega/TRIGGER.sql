--TRIGGER 1: Comprobar que el a�o de estreno de las precuelas es posterior a las otras
CREATE OR REPLACE TRIGGER verificar_anyo_precuela
BEFORE INSERT ON VINCULAR
FOR EACH ROW
DECLARE
    anyo_precuela INTEGER;
    anyo_original INTEGER;
    MAL_ANYO EXCEPTION;
BEGIN
    SELECT O1.anyo_estreno INTO anyo_precuela
    FROM OBRA O1
    WHERE O1.id_obra = :new.obra_1;

    SELECT O2.anyo_estreno INTO anyo_original
    FROM OBRA O2
    WHERE O2.id_obra = :new.obra_2;
    
    IF anyo_original > anyo_precuela THEN
        RAISE MAL_ANYO;
    END IF;
END;
/
--TRIGGER 2
CREATE OR REPLACE TRIGGER verifica_participar
BEFORE INSERT ON participar
FOR EACH ROW
DECLARE
    v_count NUMBER;
    FALLO_PARTICIPAR EXCEPTION;
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
        RAISE FALLO_PARTICIPAR;
    END IF;
END;
/
--TRIGGER 3
CREATE OR REPLACE TRIGGER trg_new_participar
BEFORE INSERT ON participar_new
FOR EACH ROW
DECLARE
    anyo_estreno_    NUMBER;
    tipo_           VARCHAR2(1);
BEGIN
    SELECT anyo_estreno INTO anyo_estreno_
    FROM OBRA
    WHERE id_obra = :new.obra;
    
    SELECT tipo INTO tipo_
    FROM OBRA
    WHERE id_obra = :new.obra;
    
    IF anyo_estreno_ < 1980 AND tipo_ = 'P' THEN
        :new.anyo_estreno := 0;
    ELSIF anyo_estreno_ > 1980 AND tipo_ = 'P' THEN
        :new.anyo_estreno := 1;
    END IF;
    :new.tipo := tipo_;
END;
/