-- Tabla Estadio
CREATE TABLE estadio (nombre VARCHAR2(50) NOT NULL, fecha_inauguracion NUMBER(4), aforo NUMBER(7));
ALTER TABLE estadio ADD CONSTRAINT estadios_pk PRIMARY KEY ( nombre );

-- Tabla Equipo
CREATE TABLE equipo (nombre_oficial VARCHAR2(60) NOT NULL, nombre_corto VARCHAR2(20),
    nombre_historico VARCHAR2(60), otros_nombres VARCHAR2(60),
    fecha_fundacion NUMBER(4), ciudad VARCHAR2(35), mi_estadio VARCHAR2(60) NOT NULL);
ALTER TABLE equipo ADD CONSTRAINT equipos_pk PRIMARY KEY ( nombre_oficial );
ALTER TABLE equipo ADD CONSTRAINT equipos_estadios_fk FOREIGN KEY ( mi_estadio )
        REFERENCES estadio ( nombre );

-- Tabla Temporada_Division
CREATE TABLE temporada_division (
    temporada VARCHAR2(8) NOT NULL, division VARCHAR2(25) NOT NULL, numero_jornadas NUMBER(3),
    numero_partidos NUMBER(4));
ALTER TABLE temporada_division ADD CONSTRAINT division_pk PRIMARY KEY ( temporada, division );

-- Tabla Participar
CREATE TABLE participar (
    equipo  VARCHAR2(60) NOT NULL, temporada VARCHAR2(8) NOT NULL, division VARCHAR2(25) NOT NULL,
    puntos NUMBER(5), total_goles NUMBER(5));
ALTER TABLE participar ADD CONSTRAINT participar_pk PRIMARY KEY ( equipo, temporada, division );
ALTER TABLE participar ADD CONSTRAINT participar_divisiones_fk FOREIGN KEY ( temporada, division )
        REFERENCES temporada_division ( temporada, division );
ALTER TABLE participar ADD CONSTRAINT participar_equipos_fk FOREIGN KEY ( equipo )
        REFERENCES equipo ( nombre_oficial );

-- Tabla Partido
-- Se añaden dos índices únicos sobre los atributos:
--      temporada, division, jornada, equipo_local
--      temporada, division, jornada, equipo_visitante
-- Para implementar parte de la restricción que no pudo ser implementada en el modelo E/R:
--      Un equipo SOLO puede jugar una vez en una jornada de la misma temporada.
--          Un equipo que juega como local en una jornada NO puede jugar como 
--          visitante en la misma jornada.
-- La parte implementada con estos índices es impedir que un equipo juegue más de una vez
-- como local o como visitante en la misma temporada, división y jornada. No impide que un
-- equipo juegue como local y visitante en la misma jornada.

-- Tabla Partido
CREATE TABLE partido (
    idpartido NUMBER(10) NOT NULL, temporada VARCHAR2(8) NOT NULL, division VARCHAR2(25) NOT NULL,
    jornada NUMBER(3) NOT NULL, equipo_local VARCHAR2(60) NOT NULL, 
    equipo_visitante VARCHAR2(60) NOT NULL,goles_local NUMBER(3), goles_visitante NUMBER(3));
CREATE UNIQUE INDEX partido_idx ON partido (temporada ASC,division ASC,jornada ASC,equipo_local ASC );
CREATE UNIQUE INDEX partido_idxv1 ON partido (temporada ASC, division ASC, jornada ASC,
                                              equipo_visitante ASC );
ALTER TABLE partido ADD CONSTRAINT partido_ck_1 CHECK ( goles_local >= 0 );
ALTER TABLE partido ADD CONSTRAINT partido_ck_2 CHECK ( goles_visitante >= 0 );
ALTER TABLE partido ADD CONSTRAINT partido_pk PRIMARY KEY ( idpartido );
ALTER TABLE partido ADD CONSTRAINT partido_equipos_fk FOREIGN KEY ( equipo_local )
        REFERENCES equipo ( nombre_oficial );
ALTER TABLE partido ADD CONSTRAINT partido_equipos_fkv2 FOREIGN KEY ( equipo_visitante )
        REFERENCES equipo ( nombre_oficial );
ALTER TABLE partido ADD CONSTRAINT partido_temporada_division_fk FOREIGN KEY ( temporada,division )
        REFERENCES temporada_division ( temporada,division );
CREATE SEQUENCE part_idpartido_seq START WITH 1 NOCACHE ORDER;
CREATE OR REPLACE TRIGGER part_idpartido_trg BEFORE INSERT ON partido
    FOR EACH ROW
    WHEN ( new.idpartido IS NULL )
BEGIN
    :new.idpartido := part_idpartido_seq.nextval;
END;