package dao;

import model.BankSetup;
import util.database;

import java.math.BigDecimal;
import java.sql.*;

public class BankSetupDao {

    public BankSetup load(int groupId) throws SQLException {
        String sql = "SELECT * FROM bank_setup WHERE group_id = ?";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                BankSetup s = new BankSetup();
                if (rs.next()) {
                    s.setBankName(rs.getString("bank_name"));
                    s.setBankBranch(rs.getString("bank_branch"));
                    s.setAccountName(rs.getString("account_name"));
                    s.setAccountNumber(rs.getString("account_number"));
                    s.setAccountType(rs.getString("account_type"));
                    s.setFeeMaintenance(safe(rs.getBigDecimal("fee_maintenance")));
                    s.setFeeService(safe(rs.getBigDecimal("fee_service")));
                    s.setFeeOther(safe(rs.getBigDecimal("fee_other")));
                }
                return s;
            }
        }
    }

    public void save(int groupId, BankSetup s) throws SQLException {
        String update = "UPDATE bank_setup SET " +
                "bank_name = ?, bank_branch = ?, " +
                "account_name = ?, account_number = ?, account_type = ?, " +
                "fee_maintenance = ?, fee_service = ?, fee_other = ? " +
                "WHERE group_id = ?";

        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(update)) {
            ps.setString(1, s.getBankName());
            ps.setString(2, s.getBankBranch());
            ps.setString(3, s.getAccountName());
            ps.setString(4, s.getAccountNumber());
            ps.setString(5, s.getAccountType());
            ps.setBigDecimal(6, safe(s.getFeeMaintenance()));
            ps.setBigDecimal(7, safe(s.getFeeService()));
            ps.setBigDecimal(8, safe(s.getFeeOther()));
            ps.setInt(9, groupId);

            int rows = ps.executeUpdate();
            if (rows == 0) {
                String insert = "INSERT INTO bank_setup " +
                        "(group_id, bank_name, bank_branch, account_name, account_number, account_type, " +
                        " fee_maintenance, fee_service, fee_other) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps2 = con.prepareStatement(insert)) {
                    ps2.setInt(1, groupId);
                    ps2.setString(2, s.getBankName());
                    ps2.setString(3, s.getBankBranch());
                    ps2.setString(4, s.getAccountName());
                    ps2.setString(5, s.getAccountNumber());
                    ps2.setString(6, s.getAccountType());
                    ps2.setBigDecimal(7, safe(s.getFeeMaintenance()));
                    ps2.setBigDecimal(8, safe(s.getFeeService()));
                    ps2.setBigDecimal(9, safe(s.getFeeOther()));
                    ps2.executeUpdate();
                }
            }
        }
    }

    private static BigDecimal safe(BigDecimal b) {
        return b == null ? BigDecimal.ZERO : b;
    }
}