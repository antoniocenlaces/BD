load data
 infile './datosAsignaturas.csv'
 into table Asignaturas
 fields terminated by ","
 ( codigo, curso, nombre )