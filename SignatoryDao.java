package dao;

import model.Signatory;
import util.database;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SignatoryDao {

    public List<Signatory> getByGroup(int groupId) throws SQLException {
        List<Signatory> list = new ArrayList<>();
        String sql = "SELECT * FROM signatories WHERE group_id = ? ORDER BY slot";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Signatory s = new Signatory();
                    s.setId(rs.getInt("id"));
                    s.setFullName(rs.getString("full_name"));
                    s.setPhoneNumber(rs.getString("phone_number"));
                    s.setPosition(rs.getString("position"));
                    list.add(s);
                }
            }
        }
        return list;
    }

    public void saveTwo(int groupId, Signatory s1, Signatory s2) throws SQLException {
        try (Connection con = database.getConnection()) {
            con.setAutoCommit(false);
            try {
                try (PreparedStatement del = con.prepareStatement(
                        "DELETE FROM signatories WHERE group_id = ?")) {
                    del.setInt(1, groupId);
                    del.executeUpdate();
                }
                insert(con, groupId, 1, s1);
                insert(con, groupId, 2, s2);
                con.commit();
            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    private void insert(Connection con, int groupId, int slot, Signatory s) throws SQLException {
        String sql = "INSERT INTO signatories " +
                "(group_id, slot, full_name, phone_number, position) " +
                "VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            ps.setInt(2, slot);
            ps.setString(3, s.getFullName());
            ps.setString(4, s.getPhoneNumber());
            ps.setString(5, s.getPosition());
            ps.executeUpdate();
        }
    }
}