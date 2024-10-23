/* Creacion de las tablas */
CREATE TABLE Asignaturas (
	codigo 		NUMBER PRIMARY KEY,
  	curso 		NUMBER(1),    
  	nombre		VARCHAR(40)    
);

CREATE TABLE Alumnos (
  	nip   		NUMBER PRIMARY KEY,
 	nombre  	VARCHAR(30),
 	apellidos	VARCHAR(30) 
);

CREATE TABLE Matriculas (
  	asignatura 	REFERENCES Asignaturas(codigo),
  	alumno 		REFERENCES Alumnos(nip),
  	CONSTRAINT 	Matriculas_PK PRIMARY KEY (asignatura, alumno)
);

/* Permisos a usuarios */

--GRANT SELECT, INSERT ON Asignaturas TO PUBLIC;
--GRANT SELECT, INSERT, UPDATE, DELETE ON Alumnos TO PUBLIC;
--GRANT SELECT, INSERT, UPDATE, DELETE ON Matriculas TO PUBLIC;



