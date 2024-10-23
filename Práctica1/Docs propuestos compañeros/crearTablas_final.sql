CREATE TABLE estadio (
    nombre VARCHAR(255) PRIMARY KEY,
    fecha_fundacion DATE,
    aforo INT
);

CREATE TABLE equipo (
    nombre_oficial VARCHAR(255) PRIMARY KEY,
    nombre_historico VARCHAR(255),
    nombre_corto VARCHAR(255),
    otros_nombres VARCHAR(255),
    fecha_fundacion DATE,
    ciudad VARCHAR(255),
    mi_estadio VARCHAR(255),
    FOREIGN KEY (mi_estadio) REFERENCES estadio(nombre)
);
drop table participar;
CREATE TABLE participar (
    equipo VARCHAR(255),
    division VARCHAR(255),
    temporada VARCHAR(255),
    CONSTRAINT participar_pk PRIMARY KEY ( temporada, equipo ),
    FOREIGN KEY (equipo) REFERENCES equipo(nombre_oficial),
    FOREIGN KEY (temporada, division) REFERENCES temporada_division(temporada,den_oficial)
    
);

CREATE TABLE temporada_division (
    temporada VARCHAR(255),
    den_oficial VARCHAR(255),
    numero_jornadas INT,
    numero_partidos INT,
    PRIMARY KEY (temporada, den_oficial)
);

CREATE TABLE partido (
    id INT PRIMARY KEY,
    division VARCHAR(255),
    temporada VARCHAR(255),
    goles_local INT,
    equipo_local VARCHAR(255),
    goles_visitante INT,
    equipo_visitante VARCHAR(255),
    numero_jornada INT,
    FOREIGN KEY (temporada, division) REFERENCES temporada_division(temporada,den_oficial),
    FOREIGN KEY (equipo_local) REFERENCES equipo(nombre_oficial),
    FOREIGN KEY (equipo_visitante) REFERENCES equipo(nombre_oficial)
);
