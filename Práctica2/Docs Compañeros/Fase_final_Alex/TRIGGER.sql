--TRIGGER 1: Comprobar que el a�o de estreno de las precuelas es posterior a las otras
CREATE OR REPLACE TRIGGER verificar_a�o_precuela
BEFORE INSERT ON VINCULAR
FOR EACH ROW
DECLARE
    a�o_precuela INTEGER;
    a�o_original INTEGER;
    MAL_A�O EXCEPTION;
BEGIN
    SELECT O1.a�o_estreno INTO a�o_precuela
    FROM OBRA O1
    WHERE O1.id_obra = :new.obra_1;

    SELECT O2.a�o_estreno INTO a�o_original
    FROM OBRA O2
    WHERE O2.id_obra = :new.obra_2;
    
    IF a�o_original > a�o_precuela THEN
        RAISE MAL_A�O;
    END IF;
END;

--TRIGGER 2: Mantener la integridad de PARTICIPAR, ya que el g�nero est� duplicado
CREATE OR REPLACE TRIGGER insertar_genero
BEFORE INSERT ON PARTICIPAR
FOR EACH ROW
DEClARE
    genero_pers VARCHAR(1);
BEGIN
    SELECT P.genero INTO genero_pers
    FROM PERSONA P
    WHERE :new.persona = P.persona;
    
    :new.genero := genero_pers;
END;

--TRIGGER 3: Verificar que en participar no se inserte una tupla igual a una ya existente. 
--NO se puede hacer con �ndices ya que papel y descripci�n pueden ser nulos 
CREATE OR REPLACE TRIGGER integridad_participar
BEFORE INSERT ON PARTICIPAR
FOR EACH ROW
DECLARE
    contador INTEGER;
    EXISTE EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO contador
    FROM PARTICIPAR
    WHERE :new.persona = persona AND :new.obra = obra AND 
        :new.funcion = funcion AND 
        ((:new.papel IS NULL AND papel IS NULL) OR :new.papel = papel) AND
        ((:new.descripcion IS NULL AND descripcion IS NULL) OR :new.descripcion = descripcion);
        
    IF contador > 0 THEN
        RAISE EXISTE;
    END IF;
END;