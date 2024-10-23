-- Tabla Estadio
CREATE TABLE estadio (nombre VARCHAR2(50) NOT NULL, fecha_inauguracion NUMBER(4), aforo NUMBER(7));
ALTER TABLE estadio ADD CONSTRAINT estadios_pk PRIMARY KEY ( nombre );
-- Desripción de los atributos de Estadio:
-- nombre:             'Nombre completo del estadio donde pueden disputarse partidos
--                      de fútbol.'
-- fecha_inauguracion: 'Año de inauguración del estadio.'
-- aforo:              'Aforo del estadio.'

-- Tabla Equipo
CREATE TABLE equipo (nombre_oficial VARCHAR2(60) NOT NULL, nombre_corto VARCHAR2(20),
    nombre_historico VARCHAR2(60), otros_nombres VARCHAR2(60),
    fecha_fundacion NUMBER(4), ciudad VARCHAR2(35), mi_estadio VARCHAR2(60) NOT NULL);
ALTER TABLE equipo ADD CONSTRAINT equipos_pk PRIMARY KEY ( nombre_oficial );
ALTER TABLE equipo ADD CONSTRAINT equipos_estadios_fk FOREIGN KEY ( mi_estadio )
        REFERENCES estadio ( nombre );
-- Desripción de los atributos de Equipo:
-- nombre_oficial:    'Nombre oficial del equipo que puede participar en un partido
--                     de fútbol.'
-- nombre_corto:      'Nombre corto del equipo.'
-- nombre_historico:  'Nombre histórico del equipo.'
-- otros_nombres:     'Otro nombre del equipo.'
-- fecha_fundacion:   'Año de fundación del equipo.'
-- ciudad:            'Ciudad donde reside este Equipo.'
-- mi_estadio:        'Referencia al estadio donde este equipo juega partidos como
--                     local.'

-- Tabla Temporada_Division
CREATE TABLE temporada_division (
    temporada VARCHAR2(8) NOT NULL, division VARCHAR2(25) NOT NULL, numero_jornadas NUMBER(3),
    numero_partidos NUMBER(4));
ALTER TABLE temporada_division ADD CONSTRAINT division_pk PRIMARY KEY ( temporada, division );
-- Desripción de los atributos de Temporada_Division:
-- temporada:        'Identifica el momento temporal en que se juega un partido.'
-- division:         'Denominación oficial de la competición en la que se juega un partido.'
-- numero_jornadas:  'Número de jornadas totales en las que se han disputado partidos en esta
--                    temporada y división.'
-- numero_partidos:  'Número de partidos totales disputados en esta temporada y división.'

-- Tabla Participar
CREATE TABLE participar (
    equipo  VARCHAR2(60) NOT NULL, temporada VARCHAR2(8) NOT NULL, division VARCHAR2(25) NOT NULL,
    puntos NUMBER(5), total_goles NUMBER(5));
ALTER TABLE participar ADD CONSTRAINT participar_pk PRIMARY KEY ( equipo, temporada, division );
ALTER TABLE participar ADD CONSTRAINT participar_divisiones_fk FOREIGN KEY ( temporada, division )
        REFERENCES temporada_division ( temporada, division );
ALTER TABLE participar ADD CONSTRAINT participar_equipos_fk FOREIGN KEY ( equipo )
        REFERENCES equipo ( nombre_oficial );
-- Desripción de los atributos de Participar:
-- puntos:         'Puntos totales que este equipo ha conseguido en esta temporada y división. 
--                  Un partido empatado da un punto para cada equipo, un equipo que gana un
--                  partido consigue tres puntos, quien pierde cero puntos.'
-- total_goles:    'Total de goles que este equipo ha marcado en esta temporada y división.'

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
-- Desripción de los atributos de Partido:
-- idpartido:         'Número único utilizado para identificar este partido.'
-- temporada:         'Identifica el momento temporal en que se juega este partido.'
-- division:          'Denominación oficial de la competición en la que se juega este partido.'
-- jornada:           'Identifica el intervalo temporal, dentro de esta temporada, en el que se
--                     ha disputado este partido.'
-- equipo_local:      'Referencia al equipo local que ha disputado este partido.'
-- equipo_visitante:  'Referencia al equipo visitante que ha disputado este partido.'
-- goles_local:       'Número de goles que el equipo local ha marcado en este partido.'
-- goles_visitante:   'Número de goles que el equipo visitante ha marcado en este partido.'