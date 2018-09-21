-- *************************************************************************************************
-- consulta no. 11
-- Consulta que muestre, cuántos goles se anotaron en cada temporada, que equipo
-- anoto más, que equipo anoto menos.

select goleadores.liga, goles, goleadores.mas_anotador, goleadores.menos_anotador
from (
--obtener mas goleador y menos goleador
select li.liga, e1.nombre as mas_anotador, e2.nombre as menos_anotador
from equipo as e1, equipo as e2, liga as li
where e1.nombre in (
		--obtener el equipo mas goleador de la temporada
		select top 1 nombre from(
			--goles local
			select nombre, sum(px1.goles_local) as goles
				from partido px1, equipo ex1, jornada jx1
				where px1.equipo_equipo = ex1.equipo
					and px1.jornada_jornada = jx1.jornada
					and jx1.liga_liga = li.liga
				group by nombre
			union
			-- goles visita
			select nombre, sum(px1.goles_visita) as goles
				from partido px1, equipo ex1, jornada jx1
				where px1.equipo_equipo1 = ex1.equipo
					and px1.jornada_jornada = jx1.jornada
					and jx1.liga_liga = li.liga
				group by nombre
		) as c
		group by nombre
		order by sum(goles) desc
	)
	and e2.nombre in (
		--obtener el equipo menos goleador de la temporada
		select top 1 nombre from(
			--goles local
			select nombre, sum(px1.goles_local) as goles
				from partido px1, equipo ex1, jornada jx1
				where px1.equipo_equipo = ex1.equipo
					and px1.jornada_jornada = jx1.jornada
					and jx1.liga_liga = li.liga
				group by nombre
			union
			-- goles visita
			select nombre, sum(px1.goles_visita) as goles
				from partido px1, equipo ex1, jornada jx1
				where px1.equipo_equipo1 = ex1.equipo
					and px1.jornada_jornada = jx1.jornada
					and jx1.liga_liga = li.liga
				group by nombre
		) as c
		group by nombre
		order by sum(goles) asc
	)
) as goleadores,
-- goles por liga

(
select j.liga_liga as liga, sum(p.goles_local+p.goles_visita) as goles
from partido as p, jornada as j
where p.jornada_jornada = j.jornada
group by j.liga_liga
) as goles
where goles.liga = goleadores.liga
order by goleadores.liga;





-- *************************************************************************************************
-- consulta no. 12
-- Consulta que muestre, al quipo con más victorias, más derrotas y más empates de
-- los últimos 18 años.

select e1.nombre as mas_victorias, e2.nombre as mas_derrotas, e3.nombre as mas_empates
	from equipo as e1, equipo as e2, equipo as e3
	where
	e1.nombre in (
		-- consulta de los mas ganadores
		select TOP 1 nombre from (
		select *
			from partido p, equipo e
			where p.equipo_equipo = e.equipo
				and p.goles_local>p.goles_visita
        and YEAR(p.fecha)>=YEAR(GETDATE())-18
		union
		select *
			from partido p2, equipo e2
			where p2.equipo_equipo1 = e2.equipo
				and p2.goles_visita>p2.goles_local
        and YEAR(p2.fecha)>=YEAR(GETDATE())-18
      ) as c
		group by nombre
		order by count(*) desc
	)
	and e2.nombre in (
		-- consulta de los mas perdedores
		select top 1 nombre from (
		select *
			from partido p, equipo e
			where p.equipo_equipo = e.equipo
				and p.goles_local<p.goles_visita
        and YEAR(p.fecha)>=YEAR(GETDATE())-18
		union
		select *
			from partido p2, equipo e2
			where p2.equipo_equipo1 = e2.equipo
      and YEAR(p2.fecha)>=YEAR(GETDATE())-18
    ) as c
		group by nombre
		order by count(*) desc
	)
	and e3.nombre in (
		-- consulta de los mas empatadores
		select top 1 nombre from (
		select *
			from partido p, equipo e
			where p.equipo_equipo = e.equipo
				and p.goles_local=p.goles_visita
        and YEAR(p.fecha)>=YEAR(GETDATE())-18
		union
		select *
			from partido p2, equipo e2
			where p2.equipo_equipo1 = e2.equipo
      and YEAR(p2.fecha)>=YEAR(GETDATE())-18
    ) as c
		group by nombre
		order by count(*) desc
	);


-- *************************************************************************************************
-- consulta no. 13
-- Crear una vista que muestre todas las “manitas” (marcadores de cinco goles a cero)
-- de los últimos 18 años

-- drop view if exists manitas;
create view manitas as
select	pa.fecha as fecha,
		e1.nombre as equipo_local,
		pa.goles_local as goles_local,
		e2.nombre as equipo_visita,
		pa.goles_visita as goles_visita

	from partido as pa, equipo as e1, equipo as e2
	where pa.equipo_equipo = e1.equipo
		and pa.equipo_equipo1 = e2.equipo
		and ((pa.goles_local=5 and pa.goles_visita=0)or(pa.goles_local=0 and pa.goles_visita=5))
		and YEAR(pa.fecha)>=YEAR(GETDATE())-18;
