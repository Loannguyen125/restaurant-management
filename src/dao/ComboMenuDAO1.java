package dao;

import model.ComboDetail1;
import model.ComboMenu1;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class ComboMenuDAO1 extends DAO1 {
    public ComboMenuDAO1() throws SQLException {
        super();
    }

    public int addCombo(ComboMenu1 combo, ComboDetail1[] details)
            throws SQLException {
        try (var connection = getConnection()) {
            connection.setAutoCommit(false);
            int comboId;
            try {
                String insertCombo = "INSERT INTO tblComboMenu1 (name, price, description, image) VALUES (?, ?, ?, ?)";
                try (var stmt = connection.prepareStatement(insertCombo, Statement.RETURN_GENERATED_KEYS)) {
                    stmt.setString(1, combo.getName());
                    stmt.setInt(2, combo.getPrice());
                    stmt.setString(3, combo.getDescription().isBlank() ? null : combo.getDescription());
                    stmt.setString(4, combo.getImage());
                    stmt.executeUpdate();
                    try (ResultSet keys = stmt.getGeneratedKeys()) {
                        if (!keys.next()) throw new SQLException("Missing generated combo ID");
                        comboId = keys.getInt(1);
                    }
                }
                try (var stmt = connection.prepareStatement(
                        "INSERT INTO tblComboDetail1 (quantity, tblComboMenu1id, tblDish1id) VALUES (?, ?, ?)")) {
                    for (ComboDetail1 detail : details) {
                        stmt.setInt(1, detail.getQuantity());
                        stmt.setInt(2, comboId);
                        stmt.setInt(3, detail.getDish().getId());
                        stmt.addBatch();
                    }
                    stmt.executeBatch();
                }
            } catch (SQLException | RuntimeException e) {
                try {
                    connection.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }
                throw e;
            }
            connection.commit();
            return comboId;
        }
    }
}
