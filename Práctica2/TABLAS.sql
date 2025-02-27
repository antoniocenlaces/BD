-- SECUENCIA DE BORRADO DE TABLAS

DROP TABLE PARTICIPAR;
DROP TABLE CAPITULO;
DROP SEQUENCE cap_id_cap_seq;
DROP TABLE VINCULAR;
DROP TABLE PERSONA;
DROP SEQUENCE per_id_persona_seq;
DROP TABLE CLASIFICAR;
drop table genero;
DROP TABLE OBRA;
DROP SEQUENCE obr_id_obra_seq;

-- DROP SEQUENCE id_pais_seq;
-- DROP TRIGGER id_pais_trg;
DROP TRIGGER vin_id_vin_trg;
DROP TRIGGER cap_id_cap_trg;
DROP TRIGGER obr_id_obra_trg;
DROP TRIGGER per_id_persona_trg;

-- TABLA OBRA --

CREATE TABLE obra (
    id_obra         NUMBER(12) CONSTRAINT obra_pk PRIMARY KEY,
    titulo          VARCHAR2(150) NOT NULL,
    anyo_estreno     NUMBER(5),
    periodo_emision VARCHAR2(9),
    tipo            VARCHAR2(1) CONSTRAINT tipo_chk CHECK ( tipo IN ( 'P', 'S' ) ) NOT NULL
);

CREATE SEQUENCE obr_id_obra_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER obr_id_obra_trg BEFORE
    INSERT ON obra
    FOR EACH ROW
    WHEN ( new.id_obra IS NULL )
BEGIN
    :new.id_obra := obr_id_obra_seq.nextval;
END;

-- TABLA GENERO
CREATE TABLE genero (
    nombre  VARCHAR2(25) CONSTRAINT genero_pk PRIMARY KEY);
    
-- TABLA CLASIFICAR
CREATE TABLE clasificar (
    obra NUMBER(12) NOT NULL,
    genero VARCHAR(25) NOT NULL,
    CONSTRAINT clasificar_pk PRIMARY KEY (obra, genero),
    CONSTRAINT clasificar_obra_fk FOREIGN KEY (obra) REFERENCES obra(id_obra),
    CONSTRAINT clasificar_genero_fk FOREIGN KEY (genero) REFERENCES genero(nombre)
);
-- TABLA PERSONA --

CREATE TABLE persona (
    id_persona NUMBER(12) CONSTRAINT persona_pk PRIMARY KEY,
    nombre     VARCHAR2(60) NOT NULL,
    nacimiento VARCHAR2(60),
    genero     VARCHAR2(1) DEFAULT 'O' NOT NULL,
    CONSTRAINT genero_chk CHECK ( genero IN ( 'f', 'm', 'o' ) ) 
);

CREATE SEQUENCE per_id_persona_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER per_id_persona_trg BEFORE
    INSERT ON persona
    FOR EACH ROW
    WHEN ( new.id_persona IS NULL )
BEGIN
    :new.id_persona := per_id_persona_seq.nextval;
END;

-- TABLA VINCULAR --
CREATE TABLE vincular (
    obra_1  NUMBER(12) NOT NULL ,
    obra_2  NUMBER(12) NOT NULL,
    vinculo VARCHAR2(60) CONSTRAINT vinculo_chk CHECK ( vinculo IN ( 'precuela', 'remake', 'secuela' ) ) NOT NULL,
    CONSTRAINT vincular_pk PRIMARY KEY (obra_1, obra_2),
    CONSTRAINT vincular_obra_fk1 FOREIGN KEY ( obra_1 ) REFERENCES obra ( id_obra ),
    CONSTRAINT vincular_obra_fk2 FOREIGN KEY ( obra_2 ) REFERENCES obra ( id_obra ),
    CONSTRAINT vinvular_chk CHECK ( obra_1 <> obra_2 )
);

-- TABLA CAP�TULO
CREATE TABLE capitulo (
    id_cap     NUMBER(12) CONSTRAINT capitulo_pk PRIMARY KEY,
    n_cap      NUMBER(12) ,
    titulo_cap VARCHAR2(150) NOT NULL,
    temporada  VARCHAR2(40),
    mi_serie   NUMBER(12) REFERENCES obra ( id_obra ) NOT NULL
);

CREATE SEQUENCE cap_id_cap_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER cap_id_cap_trg BEFORE
    INSERT ON capitulo
    FOR EACH ROW
    WHEN ( new.id_cap IS NULL )
BEGIN
    :new.id_cap := cap_id_cap_seq.nextval;
END;

-- TABLA PARTICIPAR
CREATE TABLE participar (
    obra        NUMBER(12) REFERENCES obra ( id_obra ) NOT NULL,
    persona     NUMBER(12) REFERENCES persona ( id_persona ) NOT NULL,
    funcion     VARCHAR2(40) ,
    papel       VARCHAR2(150) ,
    descripcion VARCHAR2(150),
    CONSTRAINT papel_chk CHECK ( ( papel IS NOT NULL AND ( funcion = 'actor' OR funcion = 'actress' ) )
                OR ( papel IS NULL AND ( funcion <> 'actor' AND funcion <> 'actress' ) ) )
);