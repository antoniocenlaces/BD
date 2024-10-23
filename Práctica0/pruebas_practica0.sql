select user from dual;
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

/* Poblado de las asignaturas */

INSERT INTO Asignaturas(codigo, curso, nombre) VALUES (1, 1, 'Introduccion a los computadores');
INSERT INTO Asignaturas(codigo, curso, nombre) VALUES (2, 1, 'Programacion I');
INSERT INTO Asignaturas(codigo, curso, nombre) VALUES (3, 2, 'Sistemas operativos');
INSERT INTO Asignaturas(codigo, curso, nombre) VALUES (4, 2, 'Bases de datos');
INSERT INTO Asignaturas(codigo, curso, nombre) VALUES (5, 3, 'Ingenieria del software');
INSERT INTO Asignaturas(codigo, curso, nombre) VALUES (6, 3, 'Inteligencia artificial');
INSERT INTO Asignaturas(codigo, curso, nombre) VALUES (7, 4, 'Algoritmia para problemas dificiles');
INSERT INTO Asignaturas(codigo, curso, nombre) VALUES (8, 4, 'Seguridad informatica');

/* Poblado de los alumnos */

INSERT INTO Alumnos(nip, nombre, apellidos) VALUES (1, 'Gabriel', 'Bosqued Prat');
INSERT INTO Alumnos(nip, nombre, apellidos) VALUES (2, 'Carla', 'Barranco Diez');
INSERT INTO Alumnos(nip, nombre, apellidos) VALUES (3, 'Jorge', 'Benhamou Cebolla');
INSERT INTO Alumnos(nip, nombre, apellidos) VALUES (4, 'Cristina', 'Hernandez Ayudan');
INSERT INTO Alumnos(nip, nombre, apellidos) VALUES (5, 'Marco', 'Aparicio Franco');
INSERT INTO Alumnos(nip, nombre, apellidos) VALUES (6, 'Ines', 'Bayona Arino');
INSERT INTO Alumnos(nip, nombre, apellidos) VALUES (7, 'Hector', 'Aguila Gil');
INSERT INTO Alumnos(nip, nombre, apellidos) VALUES (8, 'Ruben', 'Murillo Borras');

/* Poblado de las matriculas */

INSERT INTO Matriculas(asignatura, alumno) VALUES (1, 1);
INSERT INTO Matriculas(asignatura, alumno) VALUES (2, 1);
INSERT INTO Matriculas(asignatura, alumno) VALUES (3, 1);
INSERT INTO Matriculas(asignatura, alumno) VALUES (4, 1);
INSERT INTO Matriculas(asignatura, alumno) VALUES (1, 2);
INSERT INTO Matriculas(asignatura, alumno) VALUES (2, 2);
INSERT INTO Matriculas(asignatura, alumno) VALUES (3, 2);
INSERT INTO Matriculas(asignatura, alumno) VALUES (4, 2);
INSERT INTO Matriculas(asignatura, alumno) VALUES (1, 3);
INSERT INTO Matriculas(asignatura, alumno) VALUES (3, 3);
INSERT INTO Matriculas(asignatura, alumno) VALUES (4, 3);
INSERT INTO Matriculas(asignatura, alumno) VALUES (1, 4);
INSERT INTO Matriculas(asignatura, alumno) VALUES (3, 4);
INSERT INTO Matriculas(asignatura, alumno) VALUES (4, 4);
INSERT INTO Matriculas(asignatura, alumno) VALUES (3, 5);
INSERT INTO Matriculas(asignatura, alumno) VALUES (4, 5);
INSERT INTO Matriculas(asignatura, alumno) VALUES (3, 6);
INSERT INTO Matriculas(asignatura, alumno) VALUES (4, 6);
INSERT INTO Matriculas(asignatura, alumno) VALUES (4, 7);
commit;
select * from Asignaturas;

/* Lista identificador y "apellidos, nombre" de cada alumnos */
SELECT nip, apellidos || ', ' || nombre as apellidos_nombre FROM Alumnos;

/*  Lista el nombre de cada alumno y las asignaturas de las que esta matriculado */
SELECT al.nip, al.nombre || ' estudia ' || asi.nombre as Estudia
	FROM Matriculas m, Asignaturas asi, Alumnos al
	WHERE m.asignatura = asi.codigo AND m.alumno = al.nip;

/* Inserta un nuevo alumno (utiliza un nombre y apellidos diferentes) */
INSERT INTO Alumnos(nip, nombre, apellidos) VALUES (9, 'Javier', 'Mena Velilla');

/* Obtiene el identificador del alumno */
SELECT nip FROM 
	Alumnos WHERE nombre = 'Javier' AND apellidos = 'Mena Velilla';

/* Nos aseguramos que todos ven ese idenificador */
COMMIT;

/* Matriculalo */

INSERT INTO Matriculas(asignatura, alumno) VALUES (3, 9);
COMMIT;

INSERT INTO Matriculas(asignatura, alumno) VALUES (5, 9);
COMMIT;

SELECT al.nombre || ' estudia ' || asi.nombre Estudia
	FROM Matriculas m, Asignaturas asi, Alumnos al
	WHERE m.asignatura = asi.codigo AND m.alumno = al.nip AND al.nip = 9;

/* Hay un cambio de matricula */
UPDATE Matriculas SET asignatura = 4 
	WHERE asignatura = 5 AND alumno = 9;
COMMIT;

SELECT al.nombre || ' estudia ' || asi.nombre Estudia
	FROM Matriculas m, Asignaturas asi, Alumnos al
	WHERE m.asignatura = asi.codigo AND m.alumno = al.nip AND al.nip = 9;

/* Toda la informacion sobre el el alumno */
DELETE FROM Matriculas WHERE alumno = 9;
COMMIT;

DELETE FROM Alumnos WHERE nip = 9;
COMMIT;

/* Borrado de las tablas */
DROP TABLE Matriculas;

DROP TABLE Asignaturas;

DROP TABLE Alumnos;