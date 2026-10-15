package dao;

import model.Group;
import util.database;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GroupDao {

    public List<Group> getAll() throws SQLException {
        List<Group> list = new ArrayList<>();
        String sql = "SELECT * FROM `groups` WHERE is_active = TRUE ORDER BY group_name";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public Group findById(int id) throws SQLException {
        String sql = "SELECT * FROM `groups` WHERE id = ?";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public String findName(int id) throws SQLException {
        Group g = findById(id);
        return g == null ? "Unknown Group" : g.getGroupName();
    }

    public boolean add(String name, String location) throws SQLException {
        String sql = "INSERT INTO `groups` (group_name, location) VALUES (?, ?)";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, location);
            return ps.executeUpdate() == 1;
        } catch (SQLIntegrityConstraintViolationException dup) {
            return false;
        }
    }

    public boolean deactivate(int id) throws SQLException {
        String sql = "UPDATE `groups` SET is_active = FALSE WHERE id = ?";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() == 1;
        }
    }

    private Group map(ResultSet rs) throws SQLException {
        Group g = new Group();
        g.setId(rs.getInt("id"));
        g.setGroupName(rs.getString("group_name"));
        g.setLocation(rs.getString("location"));
        g.setActive(rs.getBoolean("is_active"));
        return g;
    }
}