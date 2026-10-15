package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class database {

    private static final String URL =
            "jdbc:mysql://localhost:3306/myproject?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";

    private static final String USER = "root";
    private static final String PASSWORD = "0245@chief#me";

    // Method to get a connection
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
