INSERT INTO VINCULAR (obra_1, obra_2, vinculo)
SELECT O1.id_obra, O2.id_obra, M.link
FROM DATOSDB.DATOSPELICULAS M, OBRA O1, OBRA O2
WHERE --M.link = 'remake of' OR M.link = -- Completar .... AND
    link <> 'version of' AND link IS NOT NULL 
    AND O1.titulo = M.title AND O1.año_estreno = M.production_year
    AND O2.titulo = M.titlelink -- AND O2.año_estreno = M.production_year
    AND O1.tipo = 'P' AND M.kind = 'movie';