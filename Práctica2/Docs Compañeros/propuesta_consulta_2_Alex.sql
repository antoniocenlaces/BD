--CONSULTA 2:Obtener la saga de películas más larga (en número de películas), listando los títulos de las películas que la componen (incluyendo precuelas y secuelas)
WITH PeliculasPorSaga AS (
    SELECT obra_1 AS id_saga, COUNT(obra_2) AS cantidad_peliculas
    FROM VINCULAR
    GROUP BY obra_1
),
SagaMasLarga AS (
    SELECT id_saga
    FROM PeliculasPorSaga
    WHERE cantidad_peliculas = (SELECT MAX(cantidad_peliculas) FROM PeliculasPorSaga)
),
PeliculasSagaMax AS (
    SELECT DISTINCT obra_2 AS id_pelicula
    FROM VINCULAR
    WHERE obra_1 IN (SELECT id_saga FROM SagaMasLarga)
)
SELECT DISTINCT titulo
FROM OBRA
WHERE id_obra IN (SELECT id_pelicula FROM PeliculasSagaMax)
   OR id_obra IN (SELECT id_saga FROM SagaMasLarga);
   
   
SELECT v.obra_1 AS id_saga, o.titulo, COUNT(v.obra_2) AS cantidad_peliculas
    FROM VINCULAR v, OBRA o
    where v.obra_1 = o.ID_OBRA
    GROUP BY v.obra_1, o.titulo;

    
    
