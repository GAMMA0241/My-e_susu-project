package dao;

import model.PayoutRow;
import util.database;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class PayoutDao {

    /* *  GROUPS the phone number belongs to

    public Map<Integer, String> getGroupsForPhone(String phoneNumber) throws SQLException {
        Map<Integer, String> groups = new LinkedHashMap<>();
        String sql =
                "SELECT g.id, g.group_name " +
                        "FROM member m " +
                        "JOIN `groups` g ON g.id = m.group_id " +
                        "WHERE m.PhoneNumber = ? " +
                        "ORDER BY g.group_name";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, phoneNumber);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) groups.put(rs.getInt("id"), rs.getString("group_name"));
            }
        }
        return groups;
    } * */

    /**  LIVE COMPUTATION
      groupId == null → all groups
       groupId != null → only that group
     **/
    public List<PayoutRow> computePayouts(Integer groupId) throws SQLException {

        StringBuilder sql = new StringBuilder(
                "SELECT m.FullName       AS Username, m.PhoneNumber  AS PhoneNumber, " +
                        "       m.MaturityDate   AS MaturityDate, " +
                        "       m.group_id       AS GroupId, " +
                        "       g.group_name     AS GroupName, " +
                        "       COALESCE(c.total, 0) AS Contribution, " +
                        "       COALESCE(s.total, 0) AS InterestShare " +
                        "FROM member m " +
                        "JOIN `groups` g ON g.id = m.group_id " +
                        "LEFT JOIN ( " +
                        "    SELECT PhoneNumber, group_id, SUM(amount) AS total " +
                        "    FROM contributions GROUP BY PhoneNumber, group_id " +
                        ") c ON c.PhoneNumber = m.PhoneNumber AND c.group_id = m.group_id " +
                        "LEFT JOIN ( " +
                        "    SELECT PhoneNumber, group_id, SUM(interest_share) AS total " +
                        "    FROM interest_distribution_share GROUP BY PhoneNumber, group_id " +
                        ") s ON s.PhoneNumber = m.PhoneNumber AND s.group_id = m.group_id " +
                        "WHERE m.IsActive = TRUE AND m.LeftEarly = FALSE "
        );

        if (groupId != null) sql.append("AND m.group_id = ? ");

        sql.append("ORDER BY g.group_name, m.FullName");

        List<PayoutRow> rows = new ArrayList<>();

        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            if (groupId != null) ps.setInt(1, groupId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    double contrib  = rs.getDouble("Contribution");
                    double interest = rs.getDouble("InterestShare");

                    PayoutRow row = new PayoutRow();
                    row.setUsername(rs.getString("Username"));
                    row.setPhoneNumber(rs.getString("PhoneNumber"));
                    row.setMaturityDate(rs.getDate("MaturityDate"));
                    row.setGroupId(rs.getInt("GroupId"));
                    row.setGroupName(rs.getString("GroupName"));
                    row.setContribution(round2(contrib));
                    row.setInterestShare(round2(interest));
                    row.setAmountDue(round2(contrib + interest));
                    rows.add(row);
                }
            }
        }
        return rows;
    }

    /*
     *  SNAPSHOT — now writes group_id too
     * */
    public boolean savePayoutSchedule(List<PayoutRow> rows, Integer groupId)
            throws SQLException {

        try (Connection con = database.getConnection()) {
            con.setAutoCommit(false);
            try {
                // Wipe existing rows for this group (or all groups if null)

                String del = (groupId == null)
                        ? "DELETE FROM payout_schedule"
                        : "DELETE FROM payout_schedule WHERE group_id = ?";
                try (PreparedStatement ps = con.prepareStatement(del)) {
                    if (groupId != null) ps.setInt(1, groupId);
                    ps.executeUpdate();
                }

                String insert =
                        "INSERT INTO payout_schedule " +
                                "(PhoneNumber, Username, Contribution, InterestShare, " +
                                " AmountDue, MaturityDate, group_id) " +
                                "VALUES (?, ?, ?, ?, ?, ?, ?)";

                try (PreparedStatement ps = con.prepareStatement(insert)) {
                    for (PayoutRow r : rows) {
                        ps.setString(1, r.getPhoneNumber());
                        ps.setString(2, r.getUsername());
                        ps.setDouble(3, r.getContribution());
                        ps.setDouble(4, r.getInterestShare());
                        ps.setDouble(5, r.getAmountDue());
                        ps.setDate  (6, r.getMaturityDate());
                        ps.setInt   (7, r.getGroupId());
                        ps.addBatch();
                    }
                    ps.executeBatch();
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

    /*
     *  SAVED SNAPSHOT — filterable by group
     * */
    public List<PayoutRow> getSavedSchedule(Integer groupId) throws SQLException {

        StringBuilder sql = new StringBuilder(
                "SELECT p.Username, p.PhoneNumber, p.Contribution, p.InterestShare, " +
                        "       p.AmountDue, p.MaturityDate, p.IsPaid, p.PaidOn, " +
                        "       p.group_id, g.group_name " +
                        "FROM payout_schedule p " +
                        "JOIN `groups` g ON g.id = p.group_id "
        );
        if (groupId != null) sql.append("WHERE p.group_id = ? ");
        sql.append("ORDER BY g.group_name, p.MaturityDate, p.Username");

        List<PayoutRow> rows = new ArrayList<>();
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            if (groupId != null) ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PayoutRow row = new PayoutRow();
                    row.setUsername(rs.getString("Username"));
                    row.setPhoneNumber(rs.getString("PhoneNumber"));
                    row.setContribution(rs.getDouble("Contribution"));
                    row.setInterestShare(rs.getDouble("InterestShare"));
                    row.setAmountDue(rs.getDouble("AmountDue"));
                    row.setMaturityDate(rs.getDate("MaturityDate"));
                    row.setPaid(rs.getBoolean("IsPaid"));
                    row.setPaidOn(rs.getDate("PaidOn"));
                    row.setGroupId(rs.getInt("group_id"));
                    row.setGroupName(rs.getString("group_name"));
                    rows.add(row);
                }
            }
        }
        return rows;
    }

    /*
     *  MARK PAID — scoped by group
     * */
    public boolean markPaid(String phoneNumber, Integer groupId) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "UPDATE payout_schedule SET IsPaid = TRUE, PaidOn = CURDATE() " +
                        "WHERE PhoneNumber = ? AND IsPaid = FALSE "
        );
        if (groupId != null) sql.append("AND group_id = ? ");

        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            ps.setString(1, phoneNumber);
            if (groupId != null) ps.setInt(2, groupId);
            return ps.executeUpdate() > 0;
        }
    }

    /*
     *  INTEREST POOL HELPERS — scoped by group
     * */
    public double getTotalInterestPool(Integer groupId) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COALESCE(SUM(amount), 0) AS total FROM loan_interest "
        );
        if (groupId != null) sql.append("WHERE group_id = ? ");

        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            if (groupId != null) ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getDouble("total");
            }
        }
    }

    private double round2(double v) {
        return Math.round(v * 100.0) / 100.0;
    }
}