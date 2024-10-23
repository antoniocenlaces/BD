-- Tabla Estadios
CREATE TABLE estadio (
    nombre             VARCHAR2(50) NOT NULL,
    fecha_inauguracion NUMBER(4),
    aforo              NUMBER(7)
);

COMMENT ON COLUMN estadio.nombre IS
    'Nombre completo del estadio donde pueden disputarse partidos de fútbol.';

COMMENT ON COLUMN estadio.fecha_inauguracion IS
    'Año de inauguración del estadio.';

COMMENT ON COLUMN estadio.aforo IS
    ' Aforo del estadio.';

ALTER TABLE estadio ADD CONSTRAINT estadios_pk PRIMARY KEY ( nombre );

-- Tabla Equipo
CREATE TABLE equipo (
    nombre_oficial   VARCHAR2(60) NOT NULL,
    nombre_corto     VARCHAR2(20),
    nombre_historico VARCHAR2(60),
    otros_nombres    VARCHAR2(60),
    fecha_fundacion  NUMBER(4),
    ciudad           VARCHAR2(35),
    mi_estadio       VARCHAR2(60) NOT NULL
);

COMMENT ON COLUMN equipo.nombre_oficial IS
    'Nombre oficial del equipo que puede participar en un partido de fútbol.';

COMMENT ON COLUMN equipo.nombre_corto IS
    'Nombre corto del equipo.';

COMMENT ON COLUMN equipo.nombre_historico IS
    'Nombre histórico del equipo.';

COMMENT ON COLUMN equipo.otros_nombres IS
    'Otro nombre del equipo.';

COMMENT ON COLUMN equipo.fecha_fundacion IS
    'Año de fundación del equipo.';

COMMENT ON COLUMN equipo.mi_estadio IS
    'Referencia al estadio donde este equipo juega partidos como local.';

ALTER TABLE equipo ADD CONSTRAINT equipos_pk PRIMARY KEY ( nombre_oficial );

ALTER TABLE equipo
    ADD CONSTRAINT equipos_estadios_fk FOREIGN KEY ( mi_estadio )
        REFERENCES estadio ( nombre );

-- Tabla Temporada_Division
CREATE TABLE temporada_division (
    temporada       VARCHAR2(8) NOT NULL,
    division        VARCHAR2(25) NOT NULL,
    numero_jornadas NUMBER(3),
    numero_partidos NUMBER(4)
);

COMMENT ON COLUMN temporada_division.temporada IS
    'Identifica el momento temporal en que se juega un partido.';

COMMENT ON COLUMN temporada_division.division IS
    'Denominación oficial de la competición en la que se juega un partido.';

COMMENT ON COLUMN temporada_division.numero_jornadas IS
    'Número de jornadas totales en las que se han disputado partidos en esta temporada y división.';

COMMENT ON COLUMN temporada_division.numero_partidos IS
    'Número de partidos totales disputados en esta temporada y división.';

ALTER TABLE temporada_division ADD CONSTRAINT division_pk PRIMARY KEY ( temporada,
                                                                        division );

-- Tabla Participar
-- Añade un índice único sobre los atributos: temporada, division y equipo.
-- Con este índice la restricción que no pudo ser implementada en el modelo E/R:
--   Un equipo SOLO puede jugar en una división durante una temporada y en las 
--   promociones de esa temporada
-- queda implementada
CREATE TABLE participar (
    temporada   VARCHAR2(8) NOT NULL,
    division    VARCHAR2(25) NOT NULL,
    equipo      VARCHAR2(60) NOT NULL,
    puntos      NUMBER(5),
    total_goles NUMBER(6)
);

COMMENT ON COLUMN participar.puntos IS
    'Puntos totoales que este equipo ha conseguido en esta temporada y división. Un partido empatado da un punto para cada equipo, un equipo que gana un partido consigue tres puntos, quien pierde cero puntos.'
    ;

COMMENT ON COLUMN participar.total_goles IS
    'Total de goles que este equipo ha marcado  en esta temporada y división.';

ALTER TABLE participar
    ADD CONSTRAINT participar_pk PRIMARY KEY ( equipo,
                                               temporada,
                                               division );

ALTER TABLE participar
    ADD CONSTRAINT participar_divisiones_fk FOREIGN KEY ( temporada,
                                                          division )
        REFERENCES temporada_division ( temporada,
                                        division );

ALTER TABLE participar
    ADD CONSTRAINT participar_equipos_fk FOREIGN KEY ( equipo )
        REFERENCES equipo ( nombre_oficial );

-- Tabla Partido
-- Se añaden dos índices únicos sobre los atributos:
--      temporada, division, jornada, equipo_local
--      temporada, division, jornada, equipo_visitante
-- Para implementar parte de la restricción que no pudo ser implementada en el modelo E/R:
--      Un equipo SOLO puede jugar una vez en una jornada de la misma temporada.
--          Un equipo que juega como local en una jornada NO puede jugar como 
--          visitante en la misma jornada.
-- La parte implementada con estos índices es impedir que un equipo juegue mÃ¡s de una vez
-- como local o como visitante en la misma temporada, división y jornada. No impide que un
-- equipo juegue como local y visitante en la misma jornada.
CREATE TABLE partido (
    idpartido        NUMBER(10) NOT NULL,
    temporada        VARCHAR2(8) NOT NULL,
    division         VARCHAR2(25) NOT NULL,
    jornada          NUMBER(3) NOT NULL,
    equipo_local     VARCHAR2(60) NOT NULL,
    equipo_visitante VARCHAR2(60) NOT NULL,
    goles_local      NUMBER(3),
    goles_visitante  NUMBER(3)
);

COMMENT ON COLUMN partido.idpartido IS
    'Número único utilizado para identificar este partido.';

COMMENT ON COLUMN partido.temporada IS
    'Identifica el momento temporal en que se juega este partido.';

COMMENT ON COLUMN partido.division IS
    'Denominación oficial de la competición en la que se juega este partido.';

COMMENT ON COLUMN partido.jornada IS
    'Identifica el intervalo temporal, dentro de esta temporada, en el que se ha disputado este partido.';

COMMENT ON COLUMN partido.equipo_local IS
    'Referencia al equipo local que ha disputado este partido.';

COMMENT ON COLUMN partido.equipo_visitante IS
    'Referencia al equipo visitante que ha disputado este partido.';

COMMENT ON COLUMN partido.goles_local IS
    'Número de goles que el equipo local ha marcado en este partido.';

COMMENT ON COLUMN partido.goles_visitante IS
    'Número de goles que el equipo visitante ha marcado en este partido.';

CREATE UNIQUE INDEX partido_idx ON
    partido (
        temporada
    ASC,
        division
    ASC,
        jornada
    ASC,
        equipo_local
    ASC );

CREATE UNIQUE INDEX partido_idxv1 ON
    partido (
        temporada
    ASC,
        division
    ASC,
        jornada
    ASC,
        equipo_visitante
    ASC );

ALTER TABLE partido ADD CONSTRAINT partido_ck_1 CHECK ( goles_local >= 0 );

ALTER TABLE partido ADD CONSTRAINT partido_ck_2 CHECK ( goles_visitante >= 0 );

ALTER TABLE partido ADD CONSTRAINT partido_pk PRIMARY KEY ( idpartido );

ALTER TABLE partido
    ADD CONSTRAINT partido_equipos_fk FOREIGN KEY ( equipo_local )
        REFERENCES equipo ( nombre_oficial );

ALTER TABLE partido
    ADD CONSTRAINT partido_equipos_fkv2 FOREIGN KEY ( equipo_visitante )
        REFERENCES equipo ( nombre_oficial );

ALTER TABLE partido
    ADD CONSTRAINT partido_temporada_division_fk FOREIGN KEY ( temporada,
                                                               division )
        REFERENCES temporada_division ( temporada,
                                        division );

CREATE SEQUENCE part_idpartido_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER part_idpartido_trg BEFORE
    INSERT ON partido
    FOR EACH ROW
    WHEN ( new.idpartido IS NULL )
BEGIN
    :new.idpartido := part_idpartido_seq.nextval;
END;

-- Proceso para borrar tablas, sequence y trigger
DROP TABLE PARTIDO;
DROP TABLE PARTICIPAR;
DROP TABLE TEMPORADA_DIVISION;
DROP TABLE EQUIPO;
DROP TABLE ESTADIO;

DROP TRIGGER PART_IDPARTIDO_TRG;
DROP TRIGGER NOJUEGASIMISMO;
DROP TRIGGER SOLOUNADIVISION;

DROP SEQUENCE PART_IDPARTIDO_SEQ;

