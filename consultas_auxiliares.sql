-- consulta que obtiene los equipos mas goleadores de la liga 1
select nombre, sum(goles) as goles from(
		--goles local
		select nombre, sum(p.goles_local) as goles
			from partido p, equipo e, jornada j
			where p.equipo_equipo = e.equipo
				and p.jornada_jornada = j.jornada
				and j.liga_liga = 1
			group by nombre
		union
		-- goles visita
		select nombre, sum(p.goles_visita) as goles
			from partido p, equipo e, jornada j
			where p.equipo_equipo1 = e.equipo
				and p.jornada_jornada = j.jornada
				and j.liga_liga = 1
			group by nombre
	) as c
	group by nombre
	order by goles desc;

-- consulta de los mas ganadores
select nombre,count(*) as total from (
select *
	from partido p, equipo e
	where p.equipo_equipo = e.equipo
		and p.goles_local>p.goles_visita
union
select *
	from partido p2, equipo e2
	where p2.equipo_equipo1 = e2.equipo
		and p2.goles_visita>p2.goles_local) as c
group by nombre
order by total desc;

-- consulta de los mas perdedores
select nombre,count(*) as total from (
select *
	from partido p, equipo e
	where p.equipo_equipo = e.equipo
		and p.goles_local<p.goles_visita
union
select *
	from partido p2, equipo e2
	where p2.equipo_equipo1 = e2.equipo
		and p2.goles_visita<p2.goles_local) as c
group by nombre
order by total desc;

-- consulta de los mas empatadores
select nombre,count(*) as total from (
select *
	from partido p, equipo e
	where p.equipo_equipo = e.equipo
		and p.goles_local=p.goles_visita
union
select *
	from partido p2, equipo e2
	where p2.equipo_equipo1 = e2.equipo
		and p2.goles_visita=p2.goles_local) as c
group by nombre
order by total desc;
