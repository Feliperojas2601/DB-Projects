use municipios;
-- Taller 1 
-- c) 
 -- show columns from comunitat;
-- show columns from municipi;
--  d) 
 -- select * from comunitat;
-- select * from municipi;
-- e) 
-- select nom from comunitat where nom like '%Castilla%' and nom not like '%Mancha%'; esta consulta selecciona la tabla comunitat y busca en los strings de nom, palabras que tengan la palabra castilla, pero que no tenga la palabra mancha
--  f1) 
-- select nom from  municipi where lower (nom) like '%x%' and length(nom)>20;
 --  f2) 
 -- select nom from  municipi where (lower (nom) like '%a%' and lower (nom) not like '%e%' and lower (nom) not like '%i%' and lower (nom) not like '%o%' and lower (nom) not like '%u%') or (lower (nom) like '%e%' and lower (nom) not like '%a%' and lower (nom) not like '%i%' and lower (nom) not like '%o%' and lower (nom) not like '%u%') or (lower (nom) like '%i%' and lower (nom) not like '%a%' and lower (nom) not like '%e%' and lower (nom) not like '%o%' and lower (nom) not like '%u%') or (lower (nom) like '%o%' and lower (nom) not like '%e%' and lower (nom) not like '%i%' and lower (nom) not like '%a%' and lower (nom) not like '%u%') or (lower (nom) like '%u%' and lower (nom) not like '%e%' and lower (nom) not like '%i%' and lower (nom) not like '%o%' and lower (nom) not like '%a%')
 --  6-3) a) 
  -- select  (poblacio2003/superficie)as densidad, nom  from municipi order by densidad DESC LIMIT 5
-- 6.3) b) 
 -- select superficie,nom from municipi where superficie < (select 1/10 * avg(superficie) from municipi) order by superficie
-- 6.3) c) 
-- select nom, poblacio1991, poblacio2001 from municipi where poblacio2001>10*poblacio1991 and poblacio1991 !=0
-- 6.4) a) 
 -- select  sum(superficie),comunitat.nom from ( municipi join comunitat on (municipi.ca_id= comunitat.ca_id)) group by comunitat.nom order by comunitat.nom 
-- 6.4) b) 
-- select abs(sum(poblacio2001-poblacio1991)) as variacion,comunitat.nom  from municipi join comunitat on (municipi.ca_id= comunitat.ca_id) group by comunitat.nom order by comunitat.nom
-- 6.4) c) 
--  select sum(superficie) as superficie_total, comunitat.nom from municipi join comunitat on (municipi.ca_id= comunitat.ca_id and comunitat.nom='Galicia')
-- Taller 2
-- 2) a ) 
-- Select comunitat.nom as comu_muni_300000mas from comunitat where comunitat.ca_id In ( Select ca_id from municipi where poblacio2003 > 300000 )
-- 2) b) 
-- Select comunitat.nom as super1000_3000 from comunitat where comunitat.ca_id In ( Select ca_id from municipi where 1000<=superficie<=3000)
-- 2) c) 
-- Select comunitat.nom as com_xmun_nom from comunitat where comunitat.ca_id In ( Select ca_id from municipi where lower(municipi.nom) like '%x')
-- 2) d)
 -- Select distinct comunitat.nom as com_xnum_nom from comunitat join municipi using (ca_id) where lower(municipi.nom) like '%x'
-- 3) a) 
-- Select comunitat.nom, count(municipi.ca_id) from comunitat join municipi using (ca_id) group by comunitat.nom having count(municipi.ca_id)>1000
-- 3) b) 
-- Select comunitat.nom, avg(superficie) as promedio_superficie from comunitat join municipi using (ca_id) group by comunitat.nom having 500<= count(m_id) <=1000 
-- 3) c) 
-- Select comunitat.nom, (municipi.poblacio2003/superficie) as densidad from comunitat join municipi using (ca_id) group by comunitat.nom having densidad>1000
-- 4) a) 
 -- Drop table if exists comunitat2;
-- create table comunitat2
-- (
-- 	ca_id integer(2),
-- 	nom varchar(50)
-- );
-- show columns from comunitat2;
-- Insert into comunitat2 (ca_id,nom) 
-- (
-- select ca_id,nom from comunitat
-- );
 -- drop table if exists municipi2; 
 -- create table municipi2
 -- (
-- 	m_id integer(4) primary key,
-- 	nom varchar(70),
 -- 	poblacio2003 integer(7),
 -- 	poblacio2001 integer(7),
 -- 	poblacio1996 integer(7),
 -- 	poblacio1991 integer(7),
 -- 	superficie integer,
 -- 	ca_id integer(2)	
 -- );
 -- Insert into municipi2 (m_id,nom,poblacio2003,poblacio2001,poblacio1996,poblacio1991,superficie,ca_id) 
 -- (
 -- select m_id,nom,poblacio2003,poblacio2001,poblacio1996,poblacio1991,superficie,ca_id from municipi
 -- ); 
-- update municipi2 set poblacio1991=0 where lower(municipi2.nom) like 'a%';
-- update municipi2 set superficie= superficie/2 where poblacio2003>1000;
-- select * from municipi2;
-- drop table if exists municipi_cat; 
--  create table municipi_cat
  -- (
 -- 	m_id integer(4) primary key,
 -- 	nom varchar(70),
 --  	poblacio2003 integer(7),
 --   	poblacio2001 integer(7),
 -- 	poblacio1996 integer(7),
 -- 	poblacio1991 integer(7),
 -- 	superficie integer,
 -- 	ca_id integer(2)	
  -- );
  -- Insert into municipi_cat (m_id,nom,poblacio2003,poblacio2001,poblacio1996,poblacio1991,superficie,ca_id) 
  -- (
  -- select m_id,municipi.nom,poblacio2003,poblacio2001,poblacio1996,poblacio1991,superficie,ca_id from municipi join comunitat using (ca_id) where comunitat.nom='Catalunya'
  -- ); 
 -- select * from municipi_cat; 
 -- 5) 
 -- Delete from municipi2 where m_id= ROUND(1+ Rand()*8000);
--  Delete from municipi2 where poblacio2003=0;
-- 6) 
 -- alter table comunitat2 add poblacion int; 
-- alter table comunitat2 add superficie int; 
-- select * from comunitat2;
-- update comunitat2 set poblacion = (select sum(poblacio2003) from municipi where comunitat2.ca_id=municipi.ca_id group by municipi.ca_id);
 -- update comunitat2 set superficie = (select sum(superficie) from municipi where comunitat2.ca_id=municipi.ca_id group by municipi.ca_id);