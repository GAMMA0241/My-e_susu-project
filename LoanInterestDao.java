package dao;

import util.database;
import java.sql.*;

public class LoanInterestDao {

    /** The total interest pool — this is what the payout distributes. */
    public double getTotalInterestPool() throws SQLException {
        String sql = "SELECT COALESCE(SUM(amount), 0) AS total FROM loan_interest";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            return rs.getDouble("total");
        }
    }
}