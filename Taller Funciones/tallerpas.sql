Use tallerpas; 
DROP TABLE IF EXISTS T; 
DROP VIEW IF EXISTS V_T; 
CREATE TABLE T (cantidad INT, precio INT);
INSERT INTO T VALUES(3, 50);
INSERT INTO T VALUES(2, 100);
INSERT INTO T VALUES(5, 80);
SELECT * FROM T;
CREATE VIEW V_T AS SELECT cantidad, precio, cantidad*precio AS valor
FROM T;
SELECT * FROM V_T;
-- 1.1) 
DROP PROCEDURE IF EXISTS  proc_VER_T; 
DELIMITER $$
CREATE PROCEDURE proc_VER_T()
BEGIN
select * from V_T;
END $$
DELIMITER ; 
-- El PA anterior selecciona toda la información en la vista V_T 
-- 1.2) 
CALL proc_VER_T();
-- 1.3 )
drop user if exists 'tallerpas'@'localhost'; 
create user 'tallerpas'@'localhost' identified by '1234';
Grant all on tallerpas.* to 'tallerpas'@'localhost'; 
flush privileges; 
-- Al salir de la base de datos e ingresar con el perfil tallerpas se ejecuta el procedimiento proc_VER_T() mostrando la información de la vista
-- 2.1) 
drop procedure if exists simpleproc; 
DELIMITER $$
CREATE PROCEDURE simpleproc (OUT param1 INT)
BEGIN
SELECT COUNT(*) INTO param1 FROM T;
END;
$$
DELIMITER ;
-- El anterior procedimiento cuenta el núemro de datos en la tabla T y almacena este dato en la variable  param1. Param1 es una parametro de salida OUT que pasa al procedimiento el valor al final de la ejecución
-- 2.2) 
call simpleproc(@total); 
select @total; 
-- La variable @total es de sesión y puede ser utilizada por fuera del procedimiento (Select @total), al llamar el procedimiento este no ejecuta la selección pues no se selecciona la infroamción de la variable param1; 
-- 2.3)  
drop procedure if exists simpleproc1; 
DELIMITER $$
Create procedure simpleproc1 () 
begin 
declare param2 int default 0;
SELECT COUNT(*) INTO param2 FROM T; 
select param2; 
end 
$$
DELIMITER ;
call simpleproc1(); 
-- 3) 
use ejerciciomuseo; 
drop view if exists vw_museo; 
create view vw_museo as ( Select obr_id,obr_nombre, mus_id, mus_nombre from obra join presentacion on (pre_obr_id=obr_id) join museo on (pre_mus_id=mus_id)); 
select * from vw_museo; 
drop procedure if exists museoproc; 
DELIMITER $$
Create procedure museoproc (in obr_nombrex varchar (45), out num_premus int) 
begin 
Select mus_id, mus_nombre, count(obr_id) as numeropresentaciones  from vw_museo where obr_nombrex= obr_nombre group by mus_id; 
set num_premus= found_rows();
end 
$$
DELIMITER ;
call museoproc('Mona lisa', @numpre); 
select @numpre;
-- 4) 
Use tallerpas; 
drop table if exists ventas; 
CREATE TABLE ventas ( stor_id char(4),
ord_num varchar(20),
fecha date );
drop procedure if exists proc_insert_ventas;
DELIMITER $$
CREATE PROCEDURE proc_insert_ventas ( IN stor_id char(4), IN ord_num
varchar(20), IN fecha date )
BEGIN
IF fecha is null THEN
set fecha = curdate();
END IF;
INSERT ventas values (stor_id, ord_num, fecha);
END;
$$
DELIMITER ; 
-- 4.1) 
-- El anterior procedimiento ingresa en la tabla ventas el valor utilizado al momento de llamar el procedimiento almacenado. 
-- 4.2) 
CALL proc_insert_ventas ('v1', 'v111', '2015-08-03' );
-- Se ingresa en la tabla ventas la tupla ('v1', 'v111', '2015-08-03' ); 
select * from ventas; 
delete from ventas; 
-- 4.3) 
-- CALL proc_insert_ventas ('v2', 'v112'); 
-- No se puede ingresar la tupla ('v2', 'v112') pues falta el parametro de fecha en esta tupla. 
-- 4.4) 
CALL proc_insert_ventas ('v3','v113', null); 
select * from ventas; 
delete from ventas; 
-- Se ingresa la tupla en la tabla ventas  ('v3','v113', null); y el valor null es reemplazado por la función curdate() que toma la fecha actual en la que se realiza el procedimiento 
-- 5.1) 
Drop table if exists libro; 
create  table libro ( 
ISBN int, 
precio double, 
titulo varchar(45), 
tema varchar(45)); 
-- 5.2 )
insert into libro values (100009723, 60000, 'Las estrellas de la vía lactea','Astronomía'); 
insert into libro values (100009724, 150000, 'Meteoritos','Astronomía'); 
insert into libro values (100004561, 80000, 'Fisica Cuantica','Fisica'); 
insert into libro values (100004562, 190000, 'Mecanica de Newton','Fisica'); 
insert into libro values (900006761, 30000, 'Normalización','Bases de Datos'); 
insert into libro values (900006762, 225000, 'SQL','Bases de Datos'); 
insert into libro values (800005841, 135500, 'Java','Computación'); 
insert into libro values (800005842, 48000, 'C++','Computación'); 
 -- 5.3) 
SELECT * FROM libro;
set @rows = found_rows();
select @rows;
-- 5.4) 
drop procedure if exists pro_libro1; 
DELIMITER $$
CREATE PROCEDURE pro_libro1 (temax varchar (45))
BEGIN
if temax='Astronomía' then 
update libro set precio = precio + precio*0.05 where tema= temax;
end if;
if temax='Fisica' then 
update libro set precio = precio + precio*0.08 where tema= temax;
end if;
if temax='Bases de Datos' then 
update libro set precio = precio + precio*0.12 where tema= temax;
end if;
if temax='Computación' then 
update libro set precio = precio + precio*0.08 where tema= temax;
end if;
END;
$$
DELIMITER ; 
-- 5.5)
-- call pro_libro1 ('Astronomia'); 
-- select * from libro;
-- 6-1) 
drop procedure if exists pro_libro2; 
DELIMITER $$
CREATE PROCEDURE pro_libro2 (porcentaje int, precio_lim double)
BEGIN

declare preciomax int default 0; 
select max(precio) into preciomax from libro; 
IF (precio_lim > preciomax) then 
select 'El precio límite ingresado es mayor al precio de todos libros, no se puede realizar el procedimiento';
end if;
update libro set precio= precio - precio * (porcentaje/100) where precio >= precio_lim; 
END
$$
DELIMITER ; 
-- call pro_libro2 (2,200000); 
select * from libro;
--  6.2) 
drop procedure if exists pro_libro3; 
DELIMITER $$
CREATE PROCEDURE pro_libro3 (porcentaje int, ISBNx int, precio_lim double)
BEGIN
declare preciox double default 0; 
select precio into preciox from libro where ISBN=ISBNx; 
if (precio_lim > preciox) then 
select 'El precio límite ingresado es mayor al precio de todos libros, no se puede realizar el procedimiento';
end if; 
update libro set precio = precio - precio * (porcentaje/100) where ISBN=ISBNx and precio >= precio_lim; 
select precio into precio_lim from libro where ISBN=ISBNx;
select CONCAT ('Titulo:', (Select titulo from libro where ISBN= ISBNx) ,' Precio nuevo: ', precio_lim) as ejercicio;
END
$$
DELIMITER ; 
call pro_libro3 (1,100009723,2);
-- 6.3 ) 
drop procedure if exists pro_libro4; 
DELIMITER $$
CREATE PROCEDURE pro_libro4 (temax varchar(45))
BEGIN
Select tema,max(precio) as libropreciomayor from libro where tema= temax; 
END
$$
DELIMITER ; 
 drop procedure if exists pro_libro5; 
DELIMITER $$
CREATE PROCEDURE pro_libro5 (temax varchar(45))
BEGIN
Select tema,count(ISBN) as numlibros from libro where tema=temax group by tema;
END
$$
DELIMITER ; 
 drop procedure if exists pro_libro6; 
DELIMITER $$
CREATE PROCEDURE pro_libro6 (temax varchar(45))
BEGIN
Select tema,avg(precio) as promedio from libro where temax=tema group by tema;
END
$$
DELIMITER ; 
 drop procedure if exists pro_libro7; 
DELIMITER $$
 CREATE PROCEDURE pro_libro7 (temax varchar(45))
BEGIN
Select tema, POW(((sum(POW(precio,2))/count(precio))- POW(avg(precio),2)), 1/2) as desviacion from libro where temax=tema group by tema; 
END
$$
DELIMITER ; 
-- 6.4) 
drop procedure if exists pro_libro8; 
DELIMITER $$
 CREATE PROCEDURE pro_libro8 (temax varchar(45))
BEGIN
Select tema,max(precio),count(ISBN),avg(precio), POW(((sum(POW(precio,2))/count(ISBN))- POW(avg(precio),2)), 1/2) as desviacion from libro where temax=tema group by tema; 
END
$$
DELIMITER ; 
call pro_libro8 ('Astronomía');
-- 8) 
drop procedure if exists pro_libro9; 
DELIMITER $$
CREATE PROCEDURE pro_libro9 (promedio double)
BEGIN
if promedio <= 250000 then 
update libro set precio = precio +10000; 
call pro_libro9((select avg(precio) from libro));
end if;
select precio from libro; 
select avg(precio) from libro;
END
$$
DELIMITER ; 
 -- call pro_libro9((select avg(precio) from libro)); 
-- 9) 
drop procedure if exists pro_libro10; 
DELIMITER $$
CREATE PROCEDURE pro_libro10 (promedio double, maximo double)
BEGIN
if promedio >= 150000 and maximo >= 80000 then 
update libro set precio = precio/2; 
call pro_libro10((select avg(precio) from libro),(select max(precio) from libro));
end if;
select precio from libro; 
END
$$
DELIMITER ; 
 call pro_libro10((select avg(precio) from libro),(select max(precio) from libro)); 
-- 10.1) 
drop procedure if exists pro_libro11; 
DELIMITER $$
CREATE PROCEDURE pro_libro11 ( precio_lim double )
BEGIN
select precio_lim,count(ISBN) as numlibromayores FROM libro where precio >= precio_lim;
END
$$
DELIMITER ; 
 call pro_libro11( 140000); 
-- 10.2) 
use ejerciciomuseo; 
drop procedure if exists pro_museo2; 
DELIMITER $$
CREATE PROCEDURE pro_museo2 ( exp_nom varchar(45) )
BEGIN
Select exp_nombre, count(obr_id) as numobras from obra join exposicion on (obr_exp_id=exp_id) where exp_nombre=exp_nom group by exp_nombre; 
END
$$
DELIMITER ; 
call pro_museo2 ('Da Vinci');
-- 10.3) 
drop procedure if exists pro_museo3; 
DELIMITER $$
CREATE PROCEDURE pro_museo3 ( mus_nom varchar(45) )
BEGIN
Select mus_nombre, obr_nombre, count(obr_nombre) as numpresentaciones from museo join presentacion on (pre_mus_id=mus_id) join obra on (pre_obr_id=obr_id)  where mus_nombre=mus_nom group by obr_nombre; 
END
$$
DELIMITER ; 
call pro_museo3 ('Louvre');