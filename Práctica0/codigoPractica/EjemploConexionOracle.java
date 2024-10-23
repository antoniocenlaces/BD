import java.io.FileReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.Properties;

/**
 * Clase de ejemplo de conexión y realización de consultas a una base de datos Oracle
 */
public class EjemploConexionOracle {
	/**
	 * Método principal del programa de ejemplo.
	 */
	public static void main(String args[]) throws Exception{
		Class.forName("oracle.jdbc.driver.OracleDriver").newInstance();
		Properties prop = new Properties();
		prop.load(new FileReader("Oracle.properties"));
		Connection connection = DriverManager.getConnection(
				"jdbc:oracle:thin:@" + prop.getProperty("host") + ":" + prop.getProperty("port") +":" + prop.getProperty("sid"), 
				prop.getProperty("user"), prop.getProperty("password"));
		connection.setAutoCommit(true);		
		executeSentence(connection, "CREATE TABLE Materia ("+"codigo NUMBER PRIMARY KEY, "+"curso NUMBER(1), "+ "nombre VARCHAR(40))");
		executeSentence(connection, "INSERT INTO Materia(codigo, curso, nombre) VALUES (9, 4, 'Vision por computador')" );
		executeSentence(connection, "INSERT INTO Materia(codigo, curso, nombre) VALUES (10, 4, 'Metodologias agiles')" );
		executeQuery(connection, "SELECT curso, nombre from Materia");
		executeSentence(connection, "DROP TABLE Materia");
		connection.close();
	}
	
	/**
	 * Metodo para ejecutar una sentencia SQL que no sea una pregunta, es decir,
	 * que no devuelva una tabla como resultado.
	 */
	public static void executeSentence(Connection connection, String sql) throws Exception{
		System.out.println("---------------------------------------------------------------------------------------");
		System.out.println(sql);
		int resultado = connection.createStatement().executeUpdate(sql);
		System.out.println("Operación ejecutada con resultado: "+resultado);
	}
	
	/**
	 * Metodo para realizar una pregunta SQL a la BD (una sentencia SELECT)
	 */
	public static void executeQuery(Connection connection, String sql) throws Exception{
		System.out.println("---------------------------------------------------------------------------------------");
		System.out.println(sql);
		System.out.println("---------------------------------------------------------------------------------------");
		// Formulamos la pregunta y obtenemos el resultado
		ResultSet rs = connection.createStatement().executeQuery(sql);
		
		// Creamos la cabecera de la tabla de resultados
		ResultSetMetaData rsmd = rs.getMetaData();
		for (int i = 1; i <= rsmd.getColumnCount(); i++) {
			System.out.print(" " + rsmd.getColumnLabel(i) + "\t | ");
		}
		System.out.println();
		
		// Creamos las filas de la tabla con la informacion de la tuplas obtenidas
		System.out.println("---------------------------------------------------------------------------------------");
		while (rs.next()) {// Por cada tupla
			for (int j = 1; j <= rsmd.getColumnCount(); j++) {
				System.out.print(" " + rs.getString(j) + "\t | ");
			}
			System.out.println();
		}		
	}

	
	
	
}