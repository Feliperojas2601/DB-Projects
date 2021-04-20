Use tallerpas; 
DROP TABLE IF EXISTS T; 
DROP VIEW IF EXISTS V_T; 
SET SQL_SAFE_UPDATES = 0;
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
-- 7.1)
Drop table if exists ejercicio7; 
create table ejercicio7 (
nombre varchar(45) primary key, 
precio double, 
cantidad int); 
Insert into ejercicio7 values ('Papas Girasol', 1000, 10); 
insert into ejercicio7 values ('Mani salado crucks', 700, 5); 
Insert into ejercicio7 values ('Gomitas lululu', 200, 0); 
-- 7.2)
drop procedure if exists pro_despacho; 
DELIMITER $$ 
create procedure pro_despacho (nombrex varchar(45), cantidadx int) 
BEGIN 
Declare contador int default 0; 
Select cantidad-cantidadx into contador from ejercicio7 where nombrex=nombre; 
If (contador < 0) then 
select cantidad as distribuido from ejercicio7 where nombrex=nombre; 
update ejercicio7 set cantidad=0 where nombrex=nombre;
end if;
if (contador>=0) then 
select cantidadx as distribuido;
update ejercicio7 set cantidad= cantidad-cantidadx where nombrex=nombre;
end if;
END 
$$
DELIMITER; 
Call pro_despacho ('Papas Girasol',5);
Call pro_despacho ('Mani salado crucks', 7);  
Call pro_despacho ('Gomitas lululu',6);
Select * from ejercicio7; 
-- 8) -- Usando Ciclos 
drop procedure if exists pro_libro9a; 
DELIMITER $$
CREATE PROCEDURE pro_libro9a ()
BEGIN
while (select avg(precio) from libro) <= 250000 do
update libro set precio = precio +10000; 
end while; 
select precio from libro; 
select avg(precio) from libro;
END
$$
DELIMITER ; 
SET SQL_SAFE_UPDATES = 0;
call pro_libro9a(); 
-- Usando Recursividad
drop procedure if exists pro_libro9b; 
DELIMITER $$
CREATE PROCEDURE pro_libro9b (promedio double)
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
  call pro_libro9b((select avg(precio) from libro)); 
-- 9) 
-- Usando ciclos 
drop procedure if exists pro_libro10a; 
DELIMITER $$
CREATE PROCEDURE pro_libro10a ()
BEGIN
Declare promedio double default 0; 
Declare maximo double default 0; 
select avg(precio) into promedio from libro; 
select max(precio) into maximo from libro; 
while promedio >= 150000 and maximo >= 80000 do 
update libro set precio = precio/2; 
select avg(precio) into promedio from libro; 
select max(precio) into maximo from libro; 
end while;
select precio from libro; 
END
$$
DELIMITER ; 
 call pro_libro10a(); 
-- Usando recursividad
drop procedure if exists pro_libro10b; 
DELIMITER $$
CREATE PROCEDURE pro_libro10b (promedio double, maximo double)
BEGIN
if promedio >= 150000 and maximo >= 80000 then 
update libro set precio = precio/2; 
call pro_libro10b((select avg(precio) from libro),(select max(precio) from libro));
end if;
select precio from libro; 
END
$$
DELIMITER ; 
 call pro_libro10b((select avg(precio) from libro),(select max(precio) from libro)); 
-- 10.1) 
drop function if exists f_libro1; 
DELIMITER $$
CREATE function f_libro1 (precio_lim double) returns int
BEGIN
declare numlibromayores int default 0; 
select count(*) into numlibromayores FROM libro where (precio >= precio_lim);
return numlibromayores; 
END $$
DELIMITER ; 
SET @var = f_libro1(140000); 
select @var; 
-- 10.2) 
use ejerciciomuseo; 
drop function if exists f_museo2; 
DELIMITER $$
CREATE function f_museo2 ( exp_nom varchar(45) ) returns int 
BEGIN
Declare numobras int default 0; 
Select count(obr_id) as numobras from obra join exposicion on (obr_exp_id=exp_id) where exp_nombre=exp_nom group by exp_nombre; 
return numobras; 
END
$$
DELIMITER ; 
set @var1=f_museo2 ('Da Vinci');
select @var1; 
-- 10.3) 
drop function if exists f_museo3; 
DELIMITER $$
CREATE function f_museo3 ( mus_nom varchar(45) ) returns int
BEGIN
Declare numpresentaciones int default 0; 
Select  count(obr_nombre) as numpresentaciones from museo join presentacion on (pre_mus_id=mus_id) join obra on (pre_obr_id=obr_id)  where mus_nombre=mus_nom group by obr_nombre; 
return numpresentaciones; 
END
$$
DELIMITER ; 
set @var2=f_museo3 ('Louvre');
select @var2; 
-- Taller Triggers 
drop table if exists ABC1; 
drop table if exists ABC2; 
create table ABC1 (
a int primary key,
b varchar (15)
);
create table ABC2 ( x int auto_increment primary key ,
a int,
b varchar (15),
cuenta varchar (50),
database1 varchar (15),
fecha date,
operacion varchar (15) check ( operacion in
('Adicion', 'Actualizacion','Borrado') ),
tabla varchar (15)
);
Drop view if exists V_ABC2;
create view V_ABC2 as
SELECT a, b FROM ABC2 WHERE cuenta = user() and database1 =database() with check option;
INSERT ABC1 values (1, 'Maria Lopez');
INSERT ABC1 values (2, 'Alvaro Perez');
select * from ABC1;
select * from ABC2;
select * from V_ABC2;
-- 1.1 ) Los Select enseñan toda la infroamción de las dos tablas y la vista, la única tabla co información es ABC1 y almacena una tupla de identificador y un nombre
Drop trigger if exists TR_ABC1; 
DELIMITER $$
CREATE TRIGGER TR_ABC1 BEFORE INSERT on ABC1
FOR EACH ROW BEGIN
SET @aa = NEW.a;
SET @bb = NEW.b;
INSERT INTO ABC2 (a, b, cuenta, database1, fecha, operacion, tabla) values 
(@aa, @bb, user(), database(), CURDATE(), 'Adicion', 'ABC1');
END;
 $$
DELIMITER ; 
-- 1.2) El anterior trigger ingresa datos en la tabla ABC2 antes de ingresar datos en la tabla ABC1, guarda el identificador y el nombre de la tabla ABC1 junto a infromación adicional de registro ne la tabla ABC2 
insert ABC1 values ( 3 , 'Luis Gomez');
select * from ABC1; 
select * from ABC2;
select * from V_ABC2;
-- 1.3) Se ingresan los datos de Luis en ABC1, y se crea la primera tupla en ABC2 con la infromación de la cuenta root, base de datos, fecha, operación y tabla. La vista enseña los id y nombres de la tabla ABC2 
insert ABC1 values (4, "Pedro Mora");
insert ABC1 values (5, "Maria Acosta");
insert ABC1 values (6, "Sandra Perez");
insert ABC1 values (7, "Jose Rueda");
select * from ABC1;
select * from ABC2;
select * from V_ABC2;
-- 1.4) Se ingresan las 4 tuplas en ABC1 y los registros con la infromación completa en ABC2, la vista selecciona los id y nombres que se tienen registrados en ABC2
-- 1.5) La tabla ABC1 guarda nombres y lo identifica con un  entero, la Tabla ABC2 gracias al trigger guarda la infromación de la tabla ABC1 e información de las inserciones como la base de datos, la cuenta, fecha, etc. La vista de la tabla ABC2 recupera os identificadores y nombres de las inserciones que se realizan en ABC1. 
-- 2 
 use ejerciciomuseo; 
Drop table if exists Historial;
Create table Historial (
fecha date, 
nom_obr varchar(45), 
accion varchar(45) check (accion in ('Adicion', 'Borrado')) 
);
Drop trigger if exists TR_MUS1; 
DELIMITER $$
CREATE TRIGGER TR_MUS1 AFTER INSERT on obra
FOR EACH ROW BEGIN
SET @nom = new.obr_nombre; 
Insert into Historial (fecha, nom_obr, accion) values ( curdate(), @nom, 'Adicion');
END; 
$$
DELIMITER ;
Drop trigger if exists TR_MUS2; 
DELIMITER $$
CREATE TRIGGER TR_MUS2 after Delete on obra
FOR EACH ROW BEGIN
SET @nom = old.obr_nombre; 
Insert into Historial (fecha, nom_obr, accion) values ( curdate(), @nom, 'Borrado');
END; 
$$
DELIMITER ;
INSERT into obra values (3, 'La pintura', 'pintura', 400, 1003);
Select * from Historial; 
Delete from presentacion where pre_obr_id=1;
Delete from obra where obr_id=1;
Select *from Historial; 
-- 3) 
Drop table if exists Historial2;
Create table Historial2 (
fecha date, 
nom_id int, 
cuenta varchar(45),
precioviejo double, 
porcentaje double
);
Drop trigger if exists TR_MUS3; 
DELIMITER $$
CREATE TRIGGER TR_MUS3 AFTER update on obra
FOR EACH ROW BEGIN
SET @id = new.obr_id; 
set @precio = old.obr_costo; 
set @porcentaje = (abs(new.obr_costo - old.obr_costo)/old.obr_costo) * 100; 
Insert into Historial2 (fecha, nom_id, cuenta, precioviejo, porcentaje) values (curdate(), @id, user(), @precio, @porcentaje);
END; 
$$
DELIMITER ;
Drop trigger if exists TR_MUS4; 
DELIMITER $$
CREATE TRIGGER TR_MUS4 AFTER insert on obra
FOR EACH ROW BEGIN
SET @id = new.obr_id; 
set @precio = new.obr_costo; 
set @porcentaje = 0;
Insert into Historial2 (fecha, nom_id, cuenta, precioviejo, porcentaje) values (curdate(), @id, user(), @precio, @porcentaje);
END; 
$$
DELIMITER ;
Drop trigger if exists TR_MUS5; 
DELIMITER $$
CREATE TRIGGER TR_MUS5 AFTER delete on obra
FOR EACH ROW BEGIN
SET @id = old.obr_id; 
set @precio = old.obr_costo; 
set @porcentaje = 0;
Insert into Historial2 (fecha, nom_id, cuenta, precioviejo, porcentaje) values (curdate(), @id, user(), @precio, @porcentaje);
END; 
$$
DELIMITER ;
select * from obra; 
Update obra set obr_costo=0 where obr_id = 111; 
Update obra set obr_costo= obr_costo/2 where obr_id= 112;
Insert into obra values (12, 'La pintura2', 'pintura', 400, 1003);
select * from Historial2;
-- 4) No se puede retornar una variable en u n trigger, aquí un intebti de solución al problema
Drop table if exists mensaje; 
create table mensaje (mensaje varchar(45));
Drop trigger if exists TR_MUS6; 
DELIMITER $$
Create trigger TR_MUS6 BEFORE DELETE ON obra
FOR EACH ROW BEGIN 
Set @nom = old.obr_nombre; 
Insert into mensaje (mensaje) values (concat('Borrando obra: ',@nom));
END; 
$$ 
DELIMITER ; 
Delete from obra where obr_id=12; 
Select mensaje from mensaje; 
