-- *****************************************************************************************}
-- Consulta no. 4
-- vista de equipos descendidos por liga
-- drop view if exists descenso;
create view descenso as
select l.liga, e.nombre
	from liga as l, equipo as e
	where e.nombre in(
		select distinct e1.nombre
			from equipo as e1, partido as p, jornada as j
			where p.equipo_equipo = e1.equipo
			and p.jornada_jornada = j.jornada
			and j.liga_liga = l.liga
	)
	and e.nombre not in(
		select distinct e1.nombre
			from equipo as e1, partido as p, jornada as j
			where p.equipo_equipo = e1.equipo
			and p.jornada_jornada = j.jornada
			and j.liga_liga = l.liga + 1
	);

	-- select * from descenso order by liga;


-- *************************************************************************************************
-- Consulta no. 7
-- Responder ¿Cuál ha sido la victoria más abultada de los últimos 18 años? Partido, equipos y marcador.


-- duda.. tiene que ser el partido que se halla ganado con mas goles o que mas goles se hallan anotado?
select fecha, e1.nombre as equipo_local, goles_local, e2.nombre as equipo_visitante, goles_visita from partido as p, equipo e1, equipo e2
	where not exists (
		select * from partido as p1
		where abs(p1.goles_local-p1.goles_visita)>abs(p.goles_local-p.goles_visita)
	)
	and p.equipo_equipo = e1.equipo
	and p.equipo_equipo1 = e2.equipo;


	-- *************************************************************************************************
	-- consulta no. 8
	-- Realizar un stored procedure que la temporada (id o año) y que devuelva el historial de los equipos que han ocupado el primer puesto de la liga de inicio a fin de temporada, con fechas y puntos.
	-- drop procedure if exists Primeros;
  create procedure Primeros @Temporada int
  as
	select l.liga, jx.numero as jornada, e.nombre
		from liga as l, jornada as jx, equipo as e
		where jx.liga_liga = l.liga
			and l.liga = @Temporada
			and e.nombre = (
				select top 1 gan2.nombre from (
				select sum (ganados*3) as ganados , gan.nombre from  (
				select count (equipo) as ganados, nombre from (Select e.equipo, e.nombre  from  partido as p, jornada as j , equipo e
				 where j.liga_liga =  @Temporada
				 AND j.numero <= jx.numero
				 AND p.jornada_jornada = j.jornada
				 AND ((p.equipo_equipo = e.equipo
				 AND p.goles_local > p.goles_visita)
				 OR (p.equipo_equipo1 = e.equipo
				 AND p.goles_local < p.goles_visita))) as tab
				 group by nombre
				 ) as gan
				 group by nombre
				 union
				select sum (ganados) as ganados, gan.nombre from  (
				select count (equipo) as ganados, nombre from (Select e.equipo, e.nombre  from  partido as p, jornada as j , equipo e
				 where j.liga_liga =  @Temporada
				 AND j.numero <= jx.numero
				 AND p.jornada_jornada = j.jornada
				 AND ((p.equipo_equipo = e.equipo
				 AND p.goles_local = p.goles_visita)
				 OR (p.equipo_equipo1 = e.equipo
				 AND p.goles_local = p.goles_visita))) as tab
				 group by nombre
				 ) as gan
				  group by nombre
				 union
				select sum (ganados*0) as ganados, gan.nombre from  (
				select count (equipo) as ganados, nombre from (Select e.equipo, e.nombre  from  partido as p, jornada as j , equipo e
				 where j.liga_liga =  @Temporada
				 AND j.numero <= jx.numero
				 AND p.jornada_jornada = j.jornada
				 AND ((p.equipo_equipo = e.equipo
				 AND p.goles_local < p.goles_visita)
				 OR (p.equipo_equipo1 = e.equipo
				 AND p.goles_local > p.goles_visita))) as tab
				 group by nombre
				 ) as gan
				  group by nombre
				  ) as gan2
				  group by nombre
				  order by sum (ganados) desc
			)order by jornada

-- *************************************************************************************************
-- consulta no. 9
-- Realizar un stored procedure que la temporada (id o año) y que devuelva el historial de los equipos que han ocupado el último puesto de la liga de inicio a fin de temporada, con fechas y puntos.

-- drop procedure if exists Primeros;
  create procedure Ultimos @Temporada int
  as
	select l.liga, jx.numero as jornada, e.nombre
		from liga as l, jornada as jx, equipo as e
		where jx.liga_liga = l.liga
			and l.liga = @Temporada
			and e.nombre = (
				select top 1 gan2.nombre from (
				select sum (ganados*3) as ganados , gan.nombre from  (
				select count (equipo) as ganados, nombre from (Select e.equipo, e.nombre  from  partido as p, jornada as j , equipo e
				 where j.liga_liga =  @Temporada
				 AND j.numero <= jx.numero
				 AND p.jornada_jornada = j.jornada
				 AND ((p.equipo_equipo = e.equipo
				 AND p.goles_local > p.goles_visita)
				 OR (p.equipo_equipo1 = e.equipo
				 AND p.goles_local < p.goles_visita))) as tab
				 group by nombre
				 ) as gan
				 group by nombre
				 union
				select sum (ganados) as ganados, gan.nombre from  (
				select count (equipo) as ganados, nombre from (Select e.equipo, e.nombre  from  partido as p, jornada as j , equipo e
				 where j.liga_liga =  @Temporada
				 AND j.numero <= jx.numero
				 AND p.jornada_jornada = j.jornada
				 AND ((p.equipo_equipo = e.equipo
				 AND p.goles_local = p.goles_visita)
				 OR (p.equipo_equipo1 = e.equipo
				 AND p.goles_local = p.goles_visita))) as tab
				 group by nombre
				 ) as gan
				  group by nombre
				 union
				select sum (ganados*0) as ganados, gan.nombre from  (
				select count (equipo) as ganados, nombre from (Select e.equipo, e.nombre  from  partido as p, jornada as j , equipo e
				 where j.liga_liga =  @Temporada
				 AND j.numero <= jx.numero
				 AND p.jornada_jornada = j.jornada
				 AND ((p.equipo_equipo = e.equipo
				 AND p.goles_local < p.goles_visita)
				 OR (p.equipo_equipo1 = e.equipo
				 AND p.goles_local > p.goles_visita))) as tab
				 group by nombre
				 ) as gan
				  group by nombre 
				  ) as gan2
				  group by nombre
				  order by sum (ganados) asc
			)order by jornada

-- *************************************************************************************************
-- consulta no. 10
-- Consulta que muestre al jugador con mejor promedio de goles de todas las temporadas.
select top 1 jugador, nombre, avg(goles) as promedio_goles
from jugador
group by jugador,nombre
order by promedio_goles desc;

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
