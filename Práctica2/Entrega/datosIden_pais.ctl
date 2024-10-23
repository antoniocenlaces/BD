load data
 infile './IDEN_PAIS.csv'
 into table IDEN_PAIS
 fields terminated by ";"
 ( NACIMIENTO, PAIS )