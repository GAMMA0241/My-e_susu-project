package dao;

import model.Loan;
import util.database;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class LoanDao {

    private static final BigDecimal DEFAULT_INTEREST_RATE = new BigDecimal("0.10");

    public static class UnknownMemberException extends SQLException {
        private final String phone;
        public UnknownMemberException(String phone) {
            super("No member found with phone number '" + phone + "'.");
            this.phone = phone;
        }
        public String getPhone() { return phone; }
    }

    public BigDecimal getInterestRate() throws SQLException {
        String sql = "SELECT value FROM settings WHERE key_name = 'loan_interest_rate'";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                BigDecimal v = rs.getBigDecimal("value");
                return v != null ? v : DEFAULT_INTEREST_RATE;
            }
        }
        return DEFAULT_INTEREST_RATE;
    }

    public boolean issueLoan(int groupId, String phone,
                             BigDecimal principal, int months) throws SQLException {

        if (months < 1 || months > 6) return false;
        if (principal == null || principal.signum() <= 0) return false;

        BigDecimal rate = getInterestRate();
        BigDecimal interestAmt = principal.multiply(rate)
                .setScale(2, RoundingMode.HALF_UP);

        LocalDate issued = LocalDate.now();
        LocalDate due    = issued.plusMonths(months);

        try (Connection con = database.getConnection()) {
            con.setAutoCommit(false);
            try {
                if (!memberExists(con, groupId, phone)) {
                    con.rollback();
                    throw new UnknownMemberException(phone);
                }

                BigDecimal balance = computeFundBalance(con, groupId);
                if (balance.compareTo(principal) < 0) {
                    con.rollback();
                    return false;
                }

                String loanSQL =
                        "INSERT INTO loans " +
                                "(PhoneNumber, principal, interest_rate, interest_amount, " +
                                " issued_on, due_date, group_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = con.prepareStatement(loanSQL)) {
                    ps.setString(1, phone);
                    ps.setBigDecimal(2, principal);
                    ps.setBigDecimal(3, rate);
                    ps.setBigDecimal(4, interestAmt);
                    ps.setDate(5, Date.valueOf(issued));
                    ps.setDate(6, Date.valueOf(due));
                    ps.setInt(7, groupId);
                    ps.executeUpdate();
                }

                insertFundRow(con, groupId, "LOAN_OUT",
                        principal, phone, "Loan issued to " + phone);

                con.commit();
                return true;
            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    public boolean repayLoan(int groupId, int loanId) throws SQLException {
        try (Connection con = database.getConnection()) {
            con.setAutoCommit(false);
            try {
                Loan loan = null;
                String sel = "SELECT * FROM loans WHERE id = ? AND group_id = ? " +
                        "AND is_repaid = FALSE FOR UPDATE";
                try (PreparedStatement ps = con.prepareStatement(sel)) {
                    ps.setInt(1, loanId);
                    ps.setInt(2, groupId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            loan = new Loan();
                            loan.setId(rs.getInt("id"));
                            loan.setPhoneNumber(rs.getString("PhoneNumber"));
                            loan.setPrincipal(rs.getBigDecimal("principal"));
                            loan.setInterestAmount(rs.getBigDecimal("interest_amount"));
                        }
                    }
                }
                if (loan == null) { con.rollback(); return false; }

                String upd = "UPDATE loans SET is_repaid = TRUE, " +
                        "amount_repaid = principal + interest_amount, " +
                        "repaid_on = CURDATE() WHERE id = ?";
                try (PreparedStatement ps = con.prepareStatement(upd)) {
                    ps.setInt(1, loanId);
                    ps.executeUpdate();
                }

                insertFundRow(con, groupId, "REPAYMENT",
                        loan.getPrincipal(), loan.getPhoneNumber(),
                        "Repayment by " + loan.getPhoneNumber());

                String intSQL = "INSERT INTO loan_interest " +
                        "(PhoneNumber, loan_id, amount, earned_on, group_id) " +
                        "VALUES (?, ?, ?, CURDATE(), ?)";
                try (PreparedStatement ps = con.prepareStatement(intSQL)) {
                    ps.setString(1, loan.getPhoneNumber());
                    ps.setInt(2, loan.getId());
                    ps.setBigDecimal(3, loan.getInterestAmount());
                    ps.setInt(4, groupId);
                    ps.executeUpdate();
                }

                con.commit();
                return true;
            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    public List<Loan> getOutstandingLoans(int groupId) throws SQLException {
        List<Loan> list = new ArrayList<>();
        String sql =
                "SELECT l.*, g.group_name " +
                        "FROM loans l " +
                        "JOIN `groups` g ON g.id = l.group_id " +
                        "WHERE l.is_repaid = FALSE AND l.group_id = ? " +
                        "ORDER BY l.due_date ASC, l.id ASC";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    private boolean memberExists(Connection con, int groupId, String phone) throws SQLException {
        if (phone == null || phone.isBlank()) return false;
        String sql = "SELECT 1 FROM member WHERE group_id = ? AND PhoneNumber = ? LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            ps.setString(2, phone.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private void insertFundRow(Connection con, int groupId,
                               String type, BigDecimal amount,
                               String phoneNumber, String note) throws SQLException {
        String sql = "INSERT INTO loan_fund " +
                "(transaction_type, amount, PhoneNumber, notes, group_id) " +
                "VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, type);
            ps.setBigDecimal(2, amount);
            if (phoneNumber == null || phoneNumber.isEmpty())
                ps.setNull(3, Types.VARCHAR);
            else
                ps.setString(3, phoneNumber);
            ps.setString(4, note);
            ps.setInt(5, groupId);
            ps.executeUpdate();
        }
    }

    private BigDecimal computeFundBalance(Connection con, int groupId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(CASE " +
                "  WHEN transaction_type IN ('ALLOCATION','REPAYMENT') THEN amount " +
                "  WHEN transaction_type = 'LOAN_OUT' THEN -amount " +
                "  ELSE 0 END), 0) " +
                "FROM loan_fund WHERE group_id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                BigDecimal b = rs.getBigDecimal(1);
                return b != null ? b : BigDecimal.ZERO;
            }
        }
    }

    private Loan mapRow(ResultSet rs) throws SQLException {
        Loan l = new Loan();
        l.setId(rs.getInt("id"));
        l.setPhoneNumber(rs.getString("PhoneNumber"));
        l.setPrincipal(rs.getBigDecimal("principal"));
        l.setInterestRate(rs.getBigDecimal("interest_rate"));
        l.setInterestAmount(rs.getBigDecimal("interest_amount"));

        Date issued = rs.getDate("issued_on");
        l.setIssuedOn(issued == null ? null : issued.toLocalDate());

        Date due = rs.getDate("due_date");
        l.setDueDate(due == null ? null : due.toLocalDate());

        BigDecimal repaid = rs.getBigDecimal("amount_repaid");
        l.setAmountRepaid(repaid == null ? BigDecimal.ZERO : repaid);
        l.setRepaid(rs.getBoolean("is_repaid"));

        Date repaidOn = rs.getDate("repaid_on");
        l.setRepaidOn(repaidOn == null ? null : repaidOn.toLocalDate());

        try {
            l.setGroupId(rs.getInt("group_id"));
            l.setGroupName(rs.getString("group_name"));
        } catch (SQLException ignored) { /* columns may not exist on some queries */ }

        return l;
    }
}