package dao;

import model.member;
import util.database;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class memberDao {



    public member findByPhone(int groupId, String phone) throws SQLException {
        String sql = "SELECT * FROM member WHERE group_id = ? AND PhoneNumber = ?";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            ps.setString(2, phone);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }


    public boolean register(int groupId, String phone, String fullName,
                            String ghanaCard, String emergencyContact,
                            String momoNumber, String bankAccount) throws SQLException {
        String sql = "INSERT INTO member " +
                "(FullName, PhoneNumber, GhanaCardNumber, EmergencyContact, " +
                " momo_number, bank_account, group_id) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setString(3, ghanaCard);
            ps.setString(4, emergencyContact);
            ps.setString(5, momoNumber);
            ps.setString(6, bankAccount);
            ps.setInt   (7, groupId);
            return ps.executeUpdate() == 1;
        } catch (SQLIntegrityConstraintViolationException dup) {
            return false;
        }
    }

    public boolean update(int groupId, String phone, String fullName,
                          String ghanaCard, String emergencyContact) throws SQLException {
        StringBuilder sql = new StringBuilder("UPDATE member SET ");
        List<Object> params = new ArrayList<>();
        boolean first = true;

        if (fullName != null && !fullName.isBlank()) {
            sql.append("FullName = ?"); params.add(fullName); first = false;
        }
        if (ghanaCard != null && !ghanaCard.isBlank()) {
            if (!first) sql.append(", ");
            sql.append("GhanaCardNumber = ?"); params.add(ghanaCard); first = false;
        }
        if (emergencyContact != null && !emergencyContact.isBlank()) {
            if (!first) sql.append(", ");
            sql.append("EmergencyContact = ?"); params.add(emergencyContact);
        }
        if (params.isEmpty()) return false;

        sql.append(" WHERE group_id = ? AND PhoneNumber = ?");
        params.add(groupId);
        params.add(phone);

        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            return ps.executeUpdate() == 1;
        }
    }

    private member map(ResultSet rs) throws SQLException {
        member m = new member();
        m.setId(rs.getInt("id"));
        m.setFullName(rs.getString("FullName"));
        m.setPhoneNumber(rs.getString("PhoneNumber"));
        m.setGhanaCardNumber(rs.getString("GhanaCardNumber"));
        m.setEmergencyContact(rs.getString("EmergencyContact"));

        Date jd = rs.getDate("JoinDate");
        if (jd != null) m.setJoinDate(jd.toLocalDate());

        Date md = rs.getDate("MaturityDate");
        if (md != null) m.setMaturityDate(md.toLocalDate());

        m.setActive(rs.getBoolean("IsActive"));
        m.setLeftEarly(rs.getBoolean("LeftEarly"));

        Date ed = rs.getDate("ExitDate");
        if (ed != null) m.setExitDate(ed.toLocalDate());

        try { m.setGroupId(rs.getInt("group_id")); } catch (SQLException ignored) {}
        try { m.setMomoNumber(rs.getString("momo_number")); } catch (SQLException ignored) {}
        try { m.setBankAccount(rs.getString("bank_account")); } catch (SQLException ignored) {}

        return m;
    }
}