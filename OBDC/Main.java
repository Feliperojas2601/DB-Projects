
import java.sql.*;
public class Main {
private static Connection conexion;
private static String bd="ejemplo";
private static String user="root";
private static String password="1234";
private static String host="localhost";
private static String server="jdbc:mysql://"+host+"/"+bd+"?useUnicode=true&useJDBCCompliantTimezoneShift=true& useLegacyDatetimeCode=false&serverTimezone=UTC";
public static void main(String[] args) {
//conectar
try {
Class.forName("com.mysql.jdbc.Driver");
conexion = DriverManager.getConnection(server,user,password);
System.out.println("ConexiÃ3n a base de datos "+server+" ... OK");
} catch (ClassNotFoundException ex) {
System.out.println("Error cargando el Driver MySQL JDBC ... FAIL");
} catch (SQLException ex) {
System.out.println("Imposible realizar conexion con "+server+" ... FAIL");
}
//realizar consulta
try {
// Preparamos la consulta
Statement s = conexion.createStatement();
ResultSet rs = s.executeQuery ("select * from persona");
// Recorremos el resultado, mientras haya registros para leer, y escribimos el resultado en pantalla.

while (rs.next())
{
System.out.println(
"ID: " +rs.getInt (1) +
"\tNombre: " + rs.getString (2)+
"\tSexo: " + rs.getString("sexo")
);
}
} catch (SQLException ex) {
System.out.println("Imposible realizar consulta ... FAIL");
}
//realizar update
try {
// Preparamos la actualización del registro con id = 5
PreparedStatement actualizar = conexion.prepareStatement("UPDATE persona SET nombre=?, SET sexo=? WHERE id = 5");
actualizar.setString(1, "Carlos Andres");
actualizar.setString(2, "M");
int retorno = actualizar.executeUpdate();
} catch (SQLException ex) {
System.out.println("Imposible realizar actualizacion ... FAIL");
}
//desconectar
try {
conexion.close();
System.out.println("Cerrar conexion con "+server+" ... OK");
} catch (SQLException ex) {
System.out.println("Imposible cerrar conexion ... FAIL");
}
}
}
