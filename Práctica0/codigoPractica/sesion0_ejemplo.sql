
SELECT * FROM Asignaturas;

/* Lista identificador y "apellidos, nombre" de cada alumnos */
SELECT nip, apellidos || ', ' || nombre apellidos_nombre FROM Alumnos;

/*  Lista el nombre de cada alumno y las asignaturas de las que esta matriculado */
SELECT al.nombre || ' estudia ' || asi.nombre Estudia
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


