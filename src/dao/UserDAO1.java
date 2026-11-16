package dao;

import model.ManagementStaff1;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class UserDAO1 extends DAO1 {
    public UserDAO1() throws SQLException {
        super();
    }

    public ManagementStaff1 login(String username, String password) throws SQLException, GeneralSecurityException {
        String sql = "SELECT u.*, s.position FROM tblUser1 u JOIN tblStaff1 s ON s.tblUser1id = u.id "
                + "WHERE u.username = ? AND s.position = 'MANAGER'";
        try (var connection = getConnection(); var stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, username);
            try (var rows = stmt.executeQuery()) {
                if (!rows.next()) return null;
                String[] encoded = rows.getString("password").split(":");
                byte[] salt = Base64.getDecoder().decode(encoded[0]);
                byte[] expected = Base64.getDecoder().decode(encoded[1]);
                PBEKeySpec key = new PBEKeySpec(password.toCharArray(), salt, 210_000, 256);
                try {
                    byte[] actual = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(key).getEncoded();
                    if (!MessageDigest.isEqual(expected, actual)) return null;
                } finally {
                    key.clearPassword();
                }
                return new ManagementStaff1(rows.getInt("id"), rows.getString("username"), rows.getString("fullname"),
                        rows.getObject("dateOfBirth", LocalDate.class), rows.getString("phone"),
                        rows.getString("email"), rows.getString("position"));
            }
        }
    }
}
