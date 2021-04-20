use ejerciciomuseo; 
-- Se agregó mediante access el registro (302,Botero), el motor de Mysql reconoce esto y lo carga en la tabla museo
Select * from museo; 
Drop view if exists Vw_access; 
Create view Vw_access as (Select obr_id, obr_costo  from obra ); 
-- Se carga en Access y Excel el registro y se añade la cupla (501, 2000) 
Select * from Vw_access; 
CREATE DATABASE IF NOT EXISTS ejemplo;
USE ejemplo;
Drop table if exists persona;
CREATE TABLE `ejemplo`.`persona` (
`id` int(11) NOT NULL AUTO_INCREMENT,
`nombre` varchar(20) NOT NULL,
`sexo` char(1) NOT NULL DEFAULT 'M',
PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;
INSERT INTO `ejemplo`.`persona` VALUES (1,'Lucas','M'),
(2,'Diego','M'),
(3,'Valentina','F'),
(4,'Marta','F'),
(5,'Alexander','M'),
(6,'Allan','M'),
(7,'Juan Felipe','M');
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '1234';
Select * from persona;
-- Se logra conectar con Netbeans 
Insert into persona values (8,'Valeria','F'); 
Delete from persona where id=4; 
Update persona set nombre = 'Alejandro' where id= 2; 
-- En netbeans se actualizan los datos. 
drop procedure if exists pro_netbeans; 
Delimiter $$ 
create procedure pro_netbeans ( idx int ) 
begin
 Select * from persona where id=idx; 
end 
$$ 
Delimiter ; 


