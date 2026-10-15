package dao;

import model.BankSetup;
import model.Signatory;
import util.database;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PartiesDao {

    /* ============================================================
     *  BANK — returns null if none set for this group
     * ============================================================ */
    public BankSetup getBank(int groupId) throws SQLException {
        String sql = "SELECT * FROM bank_setup WHERE group_id = ?";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                BankSetup b = new BankSetup();
                b.setBankName(rs.getString("bank_name"));
                b.setBankBranch(rs.getString("bank_branch"));
                b.setAccountName(rs.getString("account_name"));
                b.setAccountNumber(rs.getString("account_number"));
                b.setAccountType(rs.getString("account_type"));
                b.setFeeMaintenance(rs.getBigDecimal("fee_maintenance"));
                b.setFeeService(rs.getBigDecimal("fee_service"));
                b.setFeeOther(rs.getBigDecimal("fee_other"));
                return b;
            }
        }
    }

    /* ============================================================
     *  SIGNATORIES — 0, 1, or 2 rows for the group
     * ============================================================ */
    public List<Signatory> getSignatories(int groupId) throws SQLException {
        List<Signatory> list = new ArrayList<>();
        String sql = "SELECT * FROM signatories WHERE group_id = ? ORDER BY slot";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Signatory s = new Signatory();
                    s.setId(rs.getInt("id"));
                    s.setGroupId(rs.getInt("group_id"));
                    s.setSlot(rs.getInt("slot"));
                    s.setFullName(rs.getString("full_name"));
                    s.setPhoneNumber(rs.getString("phone_number"));
                    s.setPosition(rs.getString("position"));
                    list.add(s);
                }
            }
        }
        return list;
    }
}