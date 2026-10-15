package dao;

import model.FundEntry;
import util.database;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LoanFundDao {

    public BigDecimal getBalance(int groupId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(CASE " +
                "  WHEN transaction_type IN ('ALLOCATION','REPAYMENT') THEN amount " +
                "  WHEN transaction_type = 'LOAN_OUT' THEN -amount " +
                "  ELSE 0 END), 0) " +
                "FROM loan_fund WHERE group_id = ?";
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

    public BigDecimal getPoolBalance(int groupId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(amount),0) FROM loan_interest WHERE group_id = ?";
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

    public BigDecimal getTotalContributions(int groupId) throws SQLException {
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

    public BigDecimal getTotalAllocated(int groupId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(amount),0) FROM loan_fund " +
                "WHERE group_id = ? AND transaction_type = 'ALLOCATION'";
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

    public List<FundEntry> getAllEntries(int groupId) throws SQLException {
        List<FundEntry> list = new ArrayList<>();
        String sql = "SELECT * FROM loan_fund WHERE group_id = ? " +
                "ORDER BY created_on DESC, id DESC";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    FundEntry e = new FundEntry();
                    e.setId(rs.getInt("id"));
                    e.setTransactionType(rs.getString("transaction_type"));
                    e.setAmount(rs.getBigDecimal("amount"));
                    e.setPhoneNumber(rs.getString("PhoneNumber"));
                    e.setNote(rs.getString("notes"));
                    e.setCreatedOn(rs.getDate("created_on").toLocalDate());
                    list.add(e);
                }
            }
        }
        return list;
    }

    public boolean allocate(int groupId, BigDecimal amount, String note) throws SQLException {
        if (amount == null || amount.signum() <= 0) return false;

        // 1. Make sure the group actually exists (prevents FK violation)
        if (!groupExists(groupId)) {
            System.err.println("allocate: group " + groupId + " does not exist in `groups`");
            return false;
        }

        // 2. Check that there is enough *unallocated* pool to move into the fund.
        //    Contributions - already allocated = what's left to allocate.
        BigDecimal contributions = getTotalContributions(groupId);
        BigDecimal allocated     = getTotalAllocated(groupId);
        BigDecimal available     = contributions.subtract(allocated);
        if (available.compareTo(amount) < 0) {
            System.err.println("allocate: group " + groupId +
                    " available=" + available + " requested=" + amount);
            return false;
        }

        String sql = "INSERT INTO loan_fund " +
                "(transaction_type, amount, notes, created_on, group_id) " +
                "VALUES ('ALLOCATION', ?, ?, CURDATE(), ?)";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setBigDecimal(1, amount);
            ps.setString(2, note);
            ps.setInt(3, groupId);
            return ps.executeUpdate() == 1;
        } catch (SQLIntegrityConstraintViolationException fk) {
            System.err.println("allocate: FK violation for group " + groupId + ": " + fk.getMessage());
            return false;
        }
    }

    private boolean groupExists(int groupId) throws SQLException {
        String sql = "SELECT 1 FROM `groups` WHERE id = ?";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}