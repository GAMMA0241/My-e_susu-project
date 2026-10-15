package dao;

import model.WithdrawalRequest;
import util.database;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

public class WithdrawalDao {

    /*
     *  LOOKUP — member info + computed totals for a phone in a group
     */

    public Object[] getMemberSummary(int groupId, String phoneNumber) throws SQLException {

        String sql =
                "SELECT m.FullName, m.JoinDate, m.MaturityDate, " +
                        "       COALESCE(c.total, 0) AS Contribution, " +
                        "       COALESCE(s.total, 0) AS InterestShare " +
                        "FROM member m " +
                        "LEFT JOIN ( " +
                        "    SELECT PhoneNumber, group_id, SUM(amount) AS total " +
                        "    FROM contributions GROUP BY PhoneNumber, group_id " +
                        ") c ON c.PhoneNumber = m.PhoneNumber AND c.group_id = m.group_id " +
                        "LEFT JOIN ( " +
                        "    SELECT PhoneNumber, group_id, SUM(interest_share) AS total " +
                        "    FROM interest_distribution_share GROUP BY PhoneNumber, group_id " +
                        ") s ON s.PhoneNumber = m.PhoneNumber AND s.group_id = m.group_id " +
                        "WHERE m.group_id = ? AND m.PhoneNumber = ?";

        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            ps.setString(2, phoneNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                String     fullName     = rs.getString("FullName");
                Date       joinDate     = rs.getDate("JoinDate");
                Date       maturityDate = rs.getDate("MaturityDate");
                BigDecimal contrib      = rs.getBigDecimal("Contribution");
                BigDecimal interest     = rs.getBigDecimal("InterestShare");

                long months = 0;
                if (joinDate != null) {
                    months = ChronoUnit.MONTHS.between(
                            joinDate.toLocalDate(), LocalDate.now());
                }

                boolean matured = maturityDate != null
                        && !LocalDate.now().isBefore(maturityDate.toLocalDate());

                return new Object[]{
                        contrib == null ? BigDecimal.ZERO : contrib,
                        interest == null ? BigDecimal.ZERO : interest,
                        months,
                        maturityDate,
                        fullName,
                        matured
                };
            }
        }
    }

    /*
     *  COMPUTE — calculate amounts for a request type
     * */

    public WithdrawalRequest compute(
            int groupId, String phoneNumber, String requestType) throws SQLException {

        Object[] s = getMemberSummary(groupId, phoneNumber);
        if (s == null) return null;

        BigDecimal contribution = (BigDecimal) s[0];
        BigDecimal interest     = (BigDecimal) s[1];
        long       months       = (Long)       s[2];

        WithdrawalRequest wr = new WithdrawalRequest();
        wr.setGroupId(groupId);
        wr.setPhoneNumber(phoneNumber);
        wr.setMemberName((String) s[4]);
        wr.setRequestType(requestType);
        wr.setContribution(contribution);
        wr.setInterestShare(interest);

        BigDecimal penalty = BigDecimal.ZERO;
        BigDecimal payable;

        switch (requestType) {
            case "TERMINATION":
                if (months < 6) {
                    penalty = contribution
                            .multiply(new BigDecimal("0.05"))
                            .setScale(2, RoundingMode.HALF_UP);
                }
                payable = contribution.subtract(penalty).add(interest);
                break;

            case "TRANSFER":
                payable = contribution.add(interest);
                break;

            case "MATURITY":
            default:
                payable = contribution.add(interest);
                break;
        }

        wr.setPenalty(penalty);
        wr.setAmountPayable(payable.setScale(2, RoundingMode.HALF_UP));
        wr.setStatus("PENDING");
        return wr;
    }

    /*
     *  SAVE — insert a new request
     * */

    public int save(WithdrawalRequest wr, String createdBy) throws SQLException {
        String sql =
                "INSERT INTO withdrawal_requests " +
                        "(group_id, PhoneNumber, request_type, contribution, interest_share, " +
                        " penalty, amount_payable, target_group_name, target_bank_account, " +
                        " momo_number, status, notes, processed_by) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, wr.getGroupId());
            ps.setString(2, wr.getPhoneNumber());
            ps.setString(3, wr.getRequestType());
            ps.setBigDecimal(4, wr.getContribution());
            ps.setBigDecimal(5, wr.getInterestShare());
            ps.setBigDecimal(6, wr.getPenalty());
            ps.setBigDecimal(7, wr.getAmountPayable());
            ps.setString(8, wr.getTargetGroupName());
            ps.setString(9, wr.getTargetBankAccount());
            ps.setString(10, wr.getMomoNumber());
            ps.setString(11, wr.getStatus());
            ps.setString(12, wr.getNotes());
            ps.setString(13, createdBy);

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    /*
     *  LIST — all requests for a group
     *
     *  IMPROVED: join includes group_id so the same phone
     *            across two groups returns the correct member.
     * */

    public List<WithdrawalRequest> getByGroup(int groupId) throws SQLException {
        String sql =
                "SELECT w.*, m.FullName AS MemberName " +
                        "FROM withdrawal_requests w " +
                        "JOIN member m " +
                        "  ON m.PhoneNumber = w.PhoneNumber " +
                        " AND m.group_id    = w.group_id " +
                        "WHERE w.group_id = ? " +
                        "ORDER BY w.requested_on DESC, w.id DESC";

        List<WithdrawalRequest> list = new ArrayList<>();
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    /*
     *  MARK PAID
     *  - MATURITY: gated by maturity date
     *  - TERMINATION: marks member inactive
     *  - TRANSFER: moves funds to target group
     *
     *  IMPROVED: only works on PENDING requests.
     *  */
    public boolean markPaid(int requestId, String adminUsername) throws SQLException {
        try (Connection con = database.getConnection()) {
            con.setAutoCommit(false);
            try {
                /* ---- 1. Load request (must be PENDING) ---- */
                WithdrawalRequest wr = null;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT * FROM withdrawal_requests WHERE id = ? " +
                                "AND status = 'PENDING' FOR UPDATE")) {
                    ps.setInt(1, requestId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) wr = map(rs);
                    }
                }
                if (wr == null) { con.rollback(); return false; }

                /* ---- 2. Maturity gating ---- */
                if ("MATURITY".equals(wr.getRequestType())) {
                    Date maturityDate = null;
                    try (PreparedStatement ps = con.prepareStatement(
                            "SELECT MaturityDate FROM member " +
                                    "WHERE PhoneNumber = ? AND group_id = ?")) {
                        ps.setString(1, wr.getPhoneNumber());
                        ps.setInt(2, wr.getGroupId());
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) maturityDate = rs.getDate("MaturityDate");
                        }
                    }
                    if (maturityDate != null
                            && LocalDate.now().isBefore(maturityDate.toLocalDate())) {
                        con.rollback();
                        throw new SQLException(
                                "Member has not reached maturity yet (due "
                                        + maturityDate + ").");
                    }
                }

                /* ---- 3. Mark PAID ---- */
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE withdrawal_requests " +
                                "SET status = 'PAID', processed_on = CURDATE(), processed_by = ? " +
                                "WHERE id = ?")) {
                    ps.setString(1, adminUsername);
                    ps.setInt(2, requestId);
                    ps.executeUpdate();
                }

                /* ---- 4. Post-processing per type ---- */
                if ("TERMINATION".equals(wr.getRequestType())) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE member " +
                                    "SET LeftEarly = TRUE, ExitDate = CURDATE(), IsActive = FALSE " +
                                    "WHERE PhoneNumber = ? AND group_id = ?")) {
                        ps.setString(1, wr.getPhoneNumber());
                        ps.setInt(2, wr.getGroupId());
                        ps.executeUpdate();
                    }
                }
                else if ("TRANSFER".equals(wr.getRequestType())) {
                    transferMember(con, wr);
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
     *  TRANSFER INTERNAL
     * */

    private void transferMember(Connection con, WithdrawalRequest wr)
            throws SQLException {

        String targetGroupName = wr.getTargetGroupName();
        if (targetGroupName == null || targetGroupName.isBlank()) {
            throw new SQLException("Transfer failed: no target group specified.");
        }

        /* ---- 1. Look up target group id ---- */
        int targetGroupId = -1;
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT id FROM `groups` WHERE group_name = ?")) {
            ps.setString(1, targetGroupName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) targetGroupId = rs.getInt("id");
            }
        }
        if (targetGroupId == -1) {
            // List valid groups to help the user
            StringBuilder valid = new StringBuilder();
            try (PreparedStatement ps2 = con.prepareStatement(
                    "SELECT group_name FROM `groups` WHERE is_active = TRUE ORDER BY group_name");
                 ResultSet rs2 = ps2.executeQuery()) {
                boolean first = true;
                while (rs2.next()) {
                    if (!first) valid.append(", ");
                    valid.append("'").append(rs2.getString(1)).append("'");
                    first = false;
                }
            }
            throw new SQLException("Transfer failed: target group '"
                    + targetGroupName + "' does not exist. Available groups: " + valid);
        }

        /* ---- 2. Read source member ---- */
        String fullName = null, ghanaCard = null, emergency = null, momo = null, bank = null;
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT FullName, GhanaCardNumber, EmergencyContact, " +
                        "       momo_number, bank_account " +
                        "FROM member WHERE PhoneNumber = ? AND group_id = ?")) {
            ps.setString(1, wr.getPhoneNumber());
            ps.setInt(2, wr.getGroupId());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    fullName  = rs.getString("FullName");
                    ghanaCard = rs.getString("GhanaCardNumber");
                    emergency = rs.getString("EmergencyContact");
                    momo      = rs.getString("momo_number");
                    bank      = rs.getString("bank_account");
                }
            }
        }
        if (fullName == null) {
            throw new SQLException("Transfer failed: source member not found.");
        }

        /* ---- 3. Check target not already present ---- */
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT 1 FROM member WHERE PhoneNumber = ? AND group_id = ?")) {
            ps.setString(1, wr.getPhoneNumber());
            ps.setInt(2, targetGroupId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    throw new SQLException("Transfer failed: member already exists in '"
                            + targetGroupName + "'.");
                }
            }
        }

        /* ---- 4. Insert member into target group ---- */
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO member " +
                        "(FullName, PhoneNumber, GhanaCardNumber, EmergencyContact, " +
                        " momo_number, bank_account, group_id) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?)")) {
            ps.setString(1, fullName);
            ps.setString(2, wr.getPhoneNumber());
            ps.setString(3, ghanaCard);
            ps.setString(4, emergency);
            ps.setString(5, momo);
            ps.setString(6, bank);
            ps.setInt   (7, targetGroupId);
            ps.executeUpdate();
        }

        /* ---- 5. Record transferred amount as a contribution ---- */
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO contributions " +
                        "(PhoneNumber, amount, paid_on, group_id) " +
                        "VALUES (?, ?, CURDATE(), ?)")) {
            ps.setString(1, wr.getPhoneNumber());
            ps.setBigDecimal(2, wr.getAmountPayable());
            ps.setInt(3, targetGroupId);
            ps.executeUpdate();
        }

        /* ---- 6. Mark source member inactive ---- */
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE member " +
                        "SET IsActive = FALSE, LeftEarly = FALSE, ExitDate = CURDATE() " +
                        "WHERE PhoneNumber = ? AND group_id = ?")) {
            ps.setString(1, wr.getPhoneNumber());
            ps.setInt(2, wr.getGroupId());
            ps.executeUpdate();
        }
    }

    /*
     *  REJECT — cancel a PENDING request
     * */
    public boolean reject(int requestId, String adminUsername, String reason)
            throws SQLException {
        String sql =
                "UPDATE withdrawal_requests " +
                        "SET status = 'CANCELLED', " +
                        "    processed_on = CURDATE(), " +
                        "    processed_by = ?, " +
                        "    notes = CONCAT(COALESCE(notes,''), " +
                        "                   CASE WHEN COALESCE(notes,'') = '' THEN '' ELSE ' | ' END, " +
                        "                   'Rejected: ', ?) " +
                        "WHERE id = ? AND status = 'PENDING'";

        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, adminUsername);
            ps.setString(2, reason == null || reason.isBlank() ? "no reason given" : reason);
            ps.setInt   (3, requestId);
            return ps.executeUpdate() > 0;
        }
    }

    /*
     *  MAPPER
     * */
    private WithdrawalRequest map(ResultSet rs) throws SQLException {
        WithdrawalRequest w = new WithdrawalRequest();
        w.setId(rs.getInt("id"));
        w.setGroupId(rs.getInt("group_id"));
        w.setPhoneNumber(rs.getString("PhoneNumber"));
        w.setRequestType(rs.getString("request_type"));
        w.setContribution(rs.getBigDecimal("contribution"));
        w.setInterestShare(rs.getBigDecimal("interest_share"));
        w.setPenalty(rs.getBigDecimal("penalty"));
        w.setAmountPayable(rs.getBigDecimal("amount_payable"));
        w.setTargetGroupName(rs.getString("target_group_name"));
        w.setTargetBankAccount(rs.getString("target_bank_account"));
        w.setMomoNumber(rs.getString("momo_number"));
        w.setStatus(rs.getString("status"));
        w.setRequestedOn(rs.getTimestamp("requested_on"));
        w.setProcessedOn(rs.getDate("processed_on"));
        w.setProcessedBy(rs.getString("processed_by"));
        w.setNotes(rs.getString("notes"));
        try { w.setMemberName(rs.getString("MemberName")); } catch (SQLException ignored)
        {}
        return w;
    }
}