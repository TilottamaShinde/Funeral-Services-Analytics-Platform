SELECT
    fh.name,
    AVG(cf.satisfaction_score) AS avg_satisfaction
FROM customer_feedback cf
JOIN funerals f
    ON cf.funeral_id = f.funeral_id
JOIN funeral_homes fh
    ON f.funeral_home_id = fh.funeral_home_id
GROUP BY fh.name;