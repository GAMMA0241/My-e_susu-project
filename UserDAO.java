package dao;

import model.User;
import util.database;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.sql.*;

public class UserDAO {

    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();


    public boolean register(String username, String plainPassword, String fullName) {
        String sql = "INSERT INTO users (username, password_hash, full_name) VALUES (?, ?, ?)";

        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String hash = encoder.encode(plainPassword);
            ps.setString(1, username);
            ps.setString(2, hash);
            ps.setString(3, fullName);

            return ps.executeUpdate() == 1;

        } catch (SQLIntegrityConstraintViolationException dup) {
            // username already exists (UNIQUE constraint)
            return false;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }


    public User findByUsername(String username) {
        String sql = "SELECT id, username, password_hash, full_name FROM users WHERE username = ?";

        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setId(rs.getLong("id"));
                    u.setUsername(rs.getString("username"));
                    u.setPasswordHash(rs.getString("password_hash"));
                    u.setFullName(rs.getString("full_name"));
                    return u;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }


    public boolean checkPassword(String plainPassword, String storedHash) {
        return encoder.matches(plainPassword, storedHash);
    }
}