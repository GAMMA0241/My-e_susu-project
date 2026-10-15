package dao;

import model.statement;
import util.database;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class StatementDao {

    /* *  GROUP LOOKUP — find all groups the phone belongs toReturns a map groupId → groupName.* */
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
                while (rs.next()) {
                    groups.put(
                            rs.getInt("id"),
                            rs.getString("group_name")
                    );
                }
            }
        }
        return groups;
    }

    /*
     *  STATEMENT — filtered contributions for a phone number.
     *  - groupId == null → all groups combined
     *  - groupId != null → only that group
     *  - fromDate / toDate optional
     *  */
    public List<statement> getStatement(String phoneNumber,Integer groupId, LocalDate fromDate, LocalDate toDate) throws SQLException {

        StringBuilder sql = new StringBuilder(
                "SELECT c.id, c.PhoneNumber, c.amount, c.paid_on, " +
                        "       c.group_id, g.group_name " +
                        "FROM contributions c " +
                        "JOIN `groups` g ON g.id = c.group_id " +
                        "WHERE c.PhoneNumber = ? "
        );

        if (groupId != null) sql.append("AND c.group_id = ? ");
        if (fromDate != null) sql.append("AND c.paid_on >= ? ");
        if (toDate   != null) sql.append("AND c.paid_on <= ? ");
        sql.append("ORDER BY c.paid_on DESC, c.id DESC");

        List<statement> list = new ArrayList<>();

        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int idx = 1;
            ps.setString(idx++, phoneNumber);
            if (groupId  != null) ps.setInt(idx++, groupId);
            if (fromDate != null) ps.setDate(idx++, Date.valueOf(fromDate));
            if (toDate   != null) ps.setDate(idx++, Date.valueOf(toDate));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    statement row = new statement();
                    row.setId(rs.getInt("id"));
                    row.setPhoneNumber(rs.getString("PhoneNumber"));
                    row.setAmount(rs.getBigDecimal("amount"));

                    Date paidOn = rs.getDate("paid_on");
                    row.setPaidOn(paidOn == null ? null : paidOn);

                    row.setGroupId(rs.getInt("group_id"));
                    row.setGroupName(rs.getString("group_name"));

                    list.add(row);
                }
            }
        }
        return list;
    }

    /* *  TOTAL — total contribution for a phone in a group
     *  (null groupId → all groups) * */

    public BigDecimal getTotalContribution(String phoneNumber, Integer groupId)
            throws SQLException {

        StringBuilder sql = new StringBuilder(
                "SELECT COALESCE(SUM(amount), 0) AS TotalContribution " +
                        "FROM contributions " +
                        "WHERE PhoneNumber = ? "
        );
        if (groupId != null) sql.append("AND group_id = ? ");

        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            ps.setString(1, phoneNumber);
            if (groupId != null) ps.setInt(2, groupId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal total = rs.getBigDecimal("TotalContribution");
                    return total != null ? total : BigDecimal.ZERO;
                }
            }
        }
        return BigDecimal.ZERO;
    }
}