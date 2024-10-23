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
