SELECT
    fh.name,
    COUNT(*) AS total_funerals
FROM funerals f
JOIN funeral_homes fh
    ON f.funeral_home_id = fh.funeral_home_id
GROUP BY fh.name;