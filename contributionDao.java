package dao;

import model.contribution;
import util.database;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class contributionDao {

    /* ============================================================
     *  A simple DTO for "member + total contribution" per group
     * ============================================================ */
    public static class MemberTotal {
        private String fullName;
        private String phoneNumber;
        private BigDecimal total;

        public MemberTotal(String fullName, String phoneNumber, BigDecimal total) {
            this.fullName    = fullName;
            this.phoneNumber = phoneNumber;
            this.total       = (total == null) ? BigDecimal.ZERO : total;
        }

        public String getFullName()    { return fullName; }
        public String getPhoneNumber() { return phoneNumber; }
        public BigDecimal getTotal()   { return total; }
    }

    /* ============================================================
     *  Existing methods — unchanged
     * ============================================================ */
    public List<contribution> getAllByGroup(int groupId) throws SQLException {
        List<contribution> list = new ArrayList<>();
        String sql = "SELECT * FROM contributions WHERE group_id = ? " +
                "ORDER BY paid_on DESC, id DESC";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    contribution c = new contribution();
                    c.setId(rs.getInt("id"));
                    c.setPhoneNumber(rs.getString("PhoneNumber"));
                    c.setAmount(rs.getBigDecimal("amount"));
                    c.setPaidOn(Date.valueOf(rs.getDate("paid_on").toLocalDate()));
                    list.add(c);
                }
            }
        }
        return list;
    }

    public void add(int groupId, String phone, BigDecimal amount) throws SQLException {
        String sql = "INSERT INTO contributions " +
                "(PhoneNumber, amount, paid_on, group_id) " +
                "VALUES (?, ?, CURDATE(), ?)";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, phone);
            ps.setBigDecimal(2, amount);
            ps.setInt(3, groupId);
            ps.executeUpdate();
        }
    }

    public BigDecimal getTotalByGroup(int groupId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(amount),0) FROM contributions WHERE group_id = ?";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                BigDecimal b = rs.getBigDecimal(1);
                return b == null ? BigDecimal.ZERO : b;
            }
        }
    }

    /* ============================================================
     *  NEW — every member in a group + SUM of their contributions
     *  Members with zero contributions still appear (LEFT JOIN).
     * ============================================================ */
    public List<MemberTotal> getMemberTotalsByGroup(int groupId) throws SQLException {
        List<MemberTotal> list = new ArrayList<>();

        String sql =
                "SELECT m.FullName, m.PhoneNumber, " +
                        "       COALESCE(SUM(c.amount), 0) AS total " +
                        "FROM member m " +
                        "LEFT JOIN contributions c " +
                        "       ON c.PhoneNumber = m.PhoneNumber " +
                        "      AND c.group_id = m.group_id " +
                        "WHERE m.group_id = ? " +
                        "GROUP BY m.id, m.FullName, m.PhoneNumber " +
                        "ORDER BY m.FullName";

        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new MemberTotal(
                            rs.getString("FullName"),
                            rs.getString("PhoneNumber"),
                            rs.getBigDecimal("total")
                    ));
                }
            }
        }
        return list;
    }
}