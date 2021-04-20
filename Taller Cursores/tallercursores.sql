use taller_cursores; 
drop table if exists AUTOR; 
drop table if exists LIBRO; 
create table AUTOR (	id_autor   int primary key, 
                        nombre	    varchar (30)       null,
                        apellido    varchar (15)       null );
 
create table LIBRO (	id_libro   int primary key, 
                        titulo	    varchar (35)       null,
                        tipo        varchar (15)       null, 
						precio      decimal (10, 2)    null, 
                        total_ventas decimal (10, 2)   null, 
						fecha_publicacion datetime     null,
			            id_autor    int);

 insert AUTOR values (1, 'Gabriel', 'Garcia Marquez');
 insert AUTOR values (2, 'Luis', 'Perez Gomez');
 insert AUTOR values (3, 'Maria', 'Vega Montes');
 insert AUTOR values (4, 'Elsa', 'Sandoval Ruiz');

 insert LIBRO values (1, 'La Hojarazca', 'literatura', 180, 1800, '2004-02-14', 1);
 insert LIBRO values (2, 'El viaje', 'literatura',  200, 600, '2004-03-18', 3);
 insert LIBRO values (3, 'Cocina Italiana', 'cocina', 100, 500, '2000-08-20', 2);
 insert LIBRO values (4, 'Cocina Colombiana','cocina', 140, 0, '2001-04-06', 2 );
 insert LIBRO values (5, 'La Empresa','negocios', 120, 240, '2001-04-06', 4 );
 insert LIBRO values (6, 'Como hacer Mercadeo','negocios', 150, 1500, '2001-04-06', 4);
 insert LIBRO values (7, 'Cronica de una muerte anunciada', 'literatura', 150, 450, '2004-02-14', 1);
 insert LIBRO values (8, 'Cien anos de soledad', 'literatura', 90, 900, '2004-02-14', 1); 
 -- 1) 
DELIMITER $$; 
  create procedure proc_create_cursor()
    begin
       declare done INT DEFAULT 0;
       declare titulo_r varchar(40);
       declare precio_r decimal(10,2);
       declare libros_precios cursor
	   for select titulo, precio from libro order by titulo;
       declare continue handler for sqlstate '02000' set done = 1;
     
      OPEN libros_precios; 
      REPEAT
         fetch libros_precios into titulo_r,precio_r;
         if not done then
           select titulo_r,precio_r;
           end if;
       until done END REPEAT;
	  close libros_precios;
	end$$;
-- a) El anterior cursor apunta a los registros de la consulta generada y los guarda en nuevas variables
-- d) cambiar el cursor para que recupere 3 registros 
DELIMITER $$; 
  create procedure proc_create_cursor1()
    begin
       declare done INT DEFAULT 0;
       declare titulo_r varchar(40);
       declare precio_r decimal(10,2);
       declare tipo_r varchar(40);
       declare libros_precios1 cursor
	   for select titulo, precio, tipo from libro order by titulo;
       declare continue handler for sqlstate '02000' set done = 1;
     
      OPEN libros_precios1; 
      REPEAT
         fetch libros_precios1 into titulo_r,precio_r,tipo_r;
         if not done then
           select titulo_r,precio_r,tipo_r;
           end if;
       until done END REPEAT;
	  close libros_precios1;
	end$$;
-- 2) 
Drop procedure if exists pro_cursor2; 
Drop table if exists abc; 
create table abc (titulo  varchar (50), precio  decimal(10,2));
DELIMITER $$
Create procedure pro_cursor2 ()
BEGIN
declare done INT DEFAULT 0;
declare titulo_r  varchar (50);
declare precio_r  decimal (10,2);
declare libro_autor cursor 
for select titulo, precio from LIBRO where id_autor = 1;
declare continue handler for sqlstate '02000' set done = 1;
open libro_autor;
repeat
fetch libro_autor into titulo_r, precio_r;
if not done then
 insert into abc values (titulo_r,precio_r);
 end if; 
 until done end repeat;
close libro_autor;
end$$ 
-- El anterior cursor apunta a el titulo y precio de la tabla libro, los guarda en nuevas variables e inserta estas en la tabla abc
call pro_cursor2();
select * from abc; 
-- 3) 
Drop procedure if exists pro_cursor3;
Select titulo,precio from LIBRO;
DELIMITER $$
create procedure pro_cursor3()
BEGIN 
declare done INT DEFAULT 0;
declare titulo_r varchar(50);
declare precio_r decimal(10,2); 
declare actualizar_precio cursor 
for select titulo,precio from libro where precio > 120; 
declare continue handler for sqlstate '02000' set done = 1;
open actualizar_precio;
repeat 
fetch actualizar_precio into titulo_r,precio_r; 
if not done then 
update LIBRO set precio=precio_r*0.8 where titulo=titulo_r; 
end if; 
until done end repeat; 
close actualizar_precio; 
END$$
call pro_cursor3(); 
select titulo,precio from LIBRO; 
-- 4) 
use ejerciciomuseo; 
drop procedure if exists pro_cursor4 ; 
select obr_nombre,obr_costo from obra; 
DELIMITER $$
create procedure pro_cursor4()
BEGIN 
declare done INT DEFAULT 0;
declare nombre_r char(50);
declare costo_r int; 
declare promedio double; 
declare actualizar_costo cursor
for select obr_nombre,obr_costo from obra;
declare continue handler for sqlstate '02000' set done = 1;
open actualizar_costo;
repeat 
fetch actualizar_costo into nombre_r,costo_r; 
if not done then 
if (costo_r<(select avg(obr_costo) from obra)) then 
update obra set obr_costo= costo_r + (costo_r * 0.5) where obr_nombre= nombre_r ; 
else if (costo_r>(select avg(obr_costo) from obra)) then
update obra set obr_costo = costo_r*0.75 where obr_nombre= nombre_r; 
end if; 
end if; 
end if; 
until done end repeat; 
close actualizar_costo;
END $$ 
call pro_cursor4(); 
select obr_nombre, obr_costo from obra; 
-- 5) 
use taller_cursores; 
drop procedure if exists pro_cursor5; 
DELIMITER $$
create procedure pro_cursor5(nombre_autor Varchar(50))  
BEGIN 
declare done INT DEFAULT 0; 
declare titulo_r varchar(50);
declare ventas_r decimal(10,2); 
declare mensaje_ventas cursor 
for select titulo,total_ventas from LIBRO natural join (select id_autor from AUTOR where nombre_autor= nombre) as id;
declare continue handler for sqlstate '02000' set done = 1;
open mensaje_ventas;
repeat 
fetch mensaje_ventas into titulo_r,ventas_r; 
if not done then 

if (ventas_r=0) then 
select titulo_r,'No ha tenido ventas',ventas_r; 
else if (0<ventas_r<500) then 
select titulo_r,'Ha tenido pocas ventas',ventas_r; 
else if (500<=ventas_r<=1000) then 
select titulo_r,'las ventas han sido regulares',ventas_r;   
else if (ventas_r>1000) then
select titulo_r,'ha tenido buenas ventas',ventas_r; 
end if; 
end if; 
end if; 
end if; 
end if; 
until done end repeat; 
close mensaje_ventas;
END $$
call pro_cursor5('Gabriel');
call pro_cursor5('Luis'); 