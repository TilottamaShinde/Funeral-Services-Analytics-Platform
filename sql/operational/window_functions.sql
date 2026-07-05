select * from
(
	select 	f.funeral_home_id,
			fh.name as funeral_home,
            sum(f.cost) as revenue,
            ROW_NUMBER() OVER(ORDER BY SUM(f.cost) DESC) AS rn
	FROM funerals f JOIN funeral_homes fh
    ON f.funeral_home_id = fh.funeral_home_id
    GROUP BY f.funeral_home_id
)x
where rn <= 3;