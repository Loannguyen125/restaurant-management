package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DAO1 {
    private Connection con;

    public DAO1() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Missing MySQL Connector/J", e);
        }
        con = DriverManager.getConnection(
                System.getenv().getOrDefault("RMS_DB_URL", "jdbc:mysql://127.0.0.1:3306/restaurant_management"),
                System.getenv().getOrDefault("RMS_DB_USER", "rms_app"),
                System.getenv("RMS_DB_PASSWORD"));
    }

    protected Connection getConnection() {
        return con;
    }
}
