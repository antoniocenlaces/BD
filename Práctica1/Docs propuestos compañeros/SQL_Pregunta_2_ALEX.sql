SELECT T0.EQUIPO, T0.TEMPORADA, T0.DIVISION,
       T1.EQUIPO, T1.TEMPORADA, T1.DIVISION,
       T2.EQUIPO, T2.TEMPORADA, T2.DIVISION
FROM PARTICIPAR T0,
     PARTICIPAR T1,
     PARTICIPAR T2
WHERE T0.TEMPORADA>'20042005' AND --Establecer Temporada inicio
      --Condiciones de los join
      T0.EQUIPO=T1.EQUIPO AND 
      T0.EQUIPO=T2.EQUIPO AND
      --Temporada 0 en segunda división
      T0.DIVISION='2' AND
      --Temporada 1 en primera división
      (TO_NUMBER(SUBSTR(T1.TEMPORADA,1,4)))=(TO_NUMBER(SUBSTR(T0.TEMPORADA,1,4))+1) AND
      T1.DIVISION='1' AND
      --Temporada 2 en segunda división
      (TO_NUMBER(SUBSTR(T2.TEMPORADA,1,4)))=(TO_NUMBER(SUBSTR(T0.TEMPORADA,1,4))+2) AND
      T2.DIVISION='2';