package dao;

import util.database;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InterestPoolDao {

    /* ============================================================
     *  Return codes
     * ============================================================ */
    public static final int NOTHING_TO_DISTRIBUTE     = -1;
    public static final int FEE_ALREADY_CHARGED_TODAY = -2;
    public static final int FEE_ALREADY_CHARGED       = -3;
    public static final int SHARES_ALREADY_FROZEN     = -4;
    public static final int FEES_NOT_CHARGED_YET      = -5;
    public static final int POOL_ROW_NOT_FOUND        = -6;
    public static final int CANNOT_CANCEL_AFTER_FEES  = -7;

    /* ============================================================
     *  Statuses stored in interest_pool.status
     * ============================================================ */
    public static final String STATUS_PENDING_FEES = "PENDING_FEES";
    public static final String STATUS_FEES_CHARGED = "FEES_CHARGED";
    public static final String STATUS_DISTRIBUTED  = "DISTRIBUTED";

    /* ============================================================
     *  Fee rules
     * ============================================================ */
    private static final BigDecimal DAILY_FEE = new BigDecimal("1.67");
    private static final BigDecimal FEE_CAP   = new BigDecimal("600.00");

    /* ============================================================
     *  PoolRow — DTO for JSP
     * ============================================================ */
    public static class PoolRow {
        public int        id;
        public Date       distributionDate;
        public Date       poolStartDate;
        public BigDecimal interestMoved;
        public BigDecimal feeApplied;
        public BigDecimal feesTotal;
        public BigDecimal netBalance;
        public boolean    feeCapReached;
        public String     notes;
        public int        groupId;
        public String     status;

        public int        getId() { return id; }
        public Date       getDistributionDate() { return distributionDate; }
        public Date       getPoolStartDate() { return poolStartDate; }
        public BigDecimal getInterestMoved() { return interestMoved; }
        public BigDecimal getFeeApplied() { return feeApplied; }
        public BigDecimal getFeesTotal() { return feesTotal; }
        public BigDecimal getNetBalance() { return netBalance; }
        public boolean    isFeeCapReached() { return feeCapReached; }
        public String     getNotes() { return notes; }
        public int        getGroupId() { return groupId; }
        public String     getStatus() { return status; }

        /** Convenience flags for the JSP */
        public boolean isPendingFees()  { return STATUS_PENDING_FEES.equals(status); }
        public boolean isFeesCharged()  { return STATUS_FEES_CHARGED.equals(status); }
        public boolean isDistributed()  { return STATUS_DISTRIBUTED.equals(status); }
    }

    /* ============================================================
     *  PoolShareRow — DTO for the pool detail page
     * ============================================================ */
    public static class PoolShareRow {
        public int        id;
        public int        poolId;
        public String     phoneNumber;
        public String     memberName;
        public BigDecimal contribution;
        public BigDecimal interestShare;
        public Date       frozenOn;
        public int        groupId;

        public int        getId() { return id; }
        public int        getPoolId() { return poolId; }
        public String     getPhoneNumber() { return phoneNumber; }
        public String     getMemberName() { return memberName; }
        public BigDecimal getContribution() { return contribution; }
        public BigDecimal getInterestShare() { return interestShare; }
        public Date       getFrozenOn() { return frozenOn; }
        public int        getGroupId() { return groupId; }
    }

    /* ============================================================
     *  READ — all pool rows for a group (or all groups if null)
     * ============================================================ */
    public List<PoolRow> getAllPoolRows(Integer groupId) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT id, distribution_date, pool_start_date, interest_moved, " +
                        "       fee_applied, net_balance, fees_total, fee_cap_reached, " +
                        "       notes, group_id, status " +
                        "FROM interest_pool "
        );
        if (groupId != null) sql.append("WHERE group_id = ? ");
        sql.append("ORDER BY distribution_date DESC, id DESC");

        List<PoolRow> list = new ArrayList<>();
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            if (groupId != null) ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    /* ============================================================
     *  READ — single pool row
     * ============================================================ */
    public PoolRow getPoolRow(int poolId) throws SQLException {
        String sql =
                "SELECT id, distribution_date, pool_start_date, interest_moved, " +
                        "       fee_applied, net_balance, fees_total, fee_cap_reached, " +
                        "       notes, group_id, status " +
                        "FROM interest_pool WHERE id = ?";
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, poolId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    /* ============================================================
     *  READ — total pool balance (sum of net_balance)
     * ============================================================ */
    public double getTotalPoolBalance(Integer groupId) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COALESCE(SUM(net_balance), 0) AS total FROM interest_pool "
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

    /* ============================================================
     *  READ — total fees charged (cumulative for the group)
     * ============================================================ */
    public double getTotalFeesCharged(Integer groupId) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COALESCE(MAX(fees_total), 0) AS total FROM interest_pool "
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

    /* ============================================================
     *  READ — all frozen shares for a pool row (detail page)
     * ============================================================ */
    public List<PoolShareRow> getSharesForPool(int poolId) throws SQLException {
        String sql =
                "SELECT s.id, s.pool_id, s.PhoneNumber, s.contribution, " +
                        "       s.interest_share, s.frozen_on, s.group_id, " +
                        "       COALESCE(m.FullName, '') AS full_name " +
                        "FROM interest_distribution_share s " +
                        "LEFT JOIN member m ON m.PhoneNumber = s.PhoneNumber " +
                        "WHERE s.pool_id = ? " +
                        "ORDER BY s.interest_share DESC";

        List<PoolShareRow> list = new ArrayList<>();
        try (Connection con = database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, poolId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PoolShareRow r = new PoolShareRow();
                    r.id            = rs.getInt("id");
                    r.poolId        = rs.getInt("pool_id");
                    r.phoneNumber   = rs.getString("PhoneNumber");
                    r.memberName    = rs.getString("full_name");
                    r.contribution  = rs.getBigDecimal("contribution");
                    r.interestShare = rs.getBigDecimal("interest_share");
                    r.frozenOn      = rs.getDate("frozen_on");
                    r.groupId       = rs.getInt("group_id");
                    list.add(r);
                }
            }
        }
        return list;
    }

    /* ============================================================
     *  STEP 1 — Move undistributed interest into the pool
     * ============================================================ */
    public int moveInterestToPool(String note, Integer groupId) throws SQLException {

        try (Connection con = database.getConnection()) {
            con.setAutoCommit(false);
            try {
                // 1. Anything to distribute?
                BigDecimal available = sumUnallocatedInterest(con, groupId);
                if (available.signum() <= 0) {
                    con.rollback();
                    return NOTHING_TO_DISTRIBUTE;
                }

                // 2. Fee already charged today for this group?
                if (feeAlreadyChargedToday(con, groupId)) {
                    con.rollback();
                    return FEE_ALREADY_CHARGED_TODAY;
                }

                // 3. Insert pool row with status = PENDING_FEES
                BigDecimal feeApplied = BigDecimal.ZERO;
                BigDecimal netBalance = available;

                String sql =
                        "INSERT INTO interest_pool " +
                                "(distribution_date, pool_start_date, interest_moved, " +
                                " fee_applied, net_balance, fees_total, fee_cap_reached, " +
                                " notes, group_id, status) " +
                                "VALUES (CURDATE(), CURDATE(), ?, ?, ?, ?, ?, ?, ?, ?)";

                int newId;
                try (PreparedStatement ps = con.prepareStatement(
                        sql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setBigDecimal(1, available);
                    ps.setBigDecimal(2, feeApplied);
                    ps.setBigDecimal(3, netBalance);
                    ps.setBigDecimal(4, getLastFeesTotal(con, groupId));
                    ps.setBoolean   (5, false);
                    ps.setString    (6, note);
                    if (groupId != null) ps.setInt(7, groupId);
                    else                 ps.setNull(7, Types.INTEGER);
                    ps.setString    (8, STATUS_PENDING_FEES);

                    ps.executeUpdate();

                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        rs.next();
                        newId = rs.getInt(1);
                    }
                }

                con.commit();
                return newId;

            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    /* ============================================================
     *  STEP 2 — Charge fees on a pool row
     * ============================================================ */
    public int chargeFees(int poolId) throws SQLException {

        try (Connection con = database.getConnection()) {
            con.setAutoCommit(false);
            try {
                BigDecimal prevTotal, interestMoved;
                String     status;
                Integer    groupId;

                String sel =
                        "SELECT fees_total, interest_moved, status, group_id " +
                                "FROM interest_pool WHERE id = ? FOR UPDATE";
                try (PreparedStatement ps = con.prepareStatement(sel)) {
                    ps.setInt(1, poolId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            con.rollback();
                            return POOL_ROW_NOT_FOUND;
                        }
                        prevTotal     = rs.getBigDecimal("fees_total");
                        interestMoved = rs.getBigDecimal("interest_moved");
                        status        = rs.getString("status");
                        int gid       = rs.getInt("group_id");
                        groupId       = rs.wasNull() ? null : gid;
                    }
                }

                if (STATUS_FEES_CHARGED.equals(status)
                        || STATUS_DISTRIBUTED.equals(status)) {
                    con.rollback();
                    return FEE_ALREADY_CHARGED;
                }

                BigDecimal feeApplied;
                if (prevTotal.compareTo(FEE_CAP) >= 0) {
                    feeApplied = BigDecimal.ZERO;
                } else {
                    BigDecimal remaining = FEE_CAP.subtract(prevTotal);
                    feeApplied = DAILY_FEE.min(remaining);
                }

                BigDecimal newFeesTotal = prevTotal.add(feeApplied)
                        .setScale(2, RoundingMode.HALF_UP);
                BigDecimal netBalance = interestMoved.subtract(feeApplied)
                        .setScale(2, RoundingMode.HALF_UP);
                boolean cap = newFeesTotal.compareTo(FEE_CAP) >= 0;

                String upd =
                        "UPDATE interest_pool SET " +
                                "  fee_applied     = ?, " +
                                "  fees_total      = ?, " +
                                "  net_balance     = ?, " +
                                "  fee_cap_reached = ?, " +
                                "  status          = ? " +
                                "WHERE id = ?";
                try (PreparedStatement ps = con.prepareStatement(upd)) {
                    ps.setBigDecimal(1, feeApplied);
                    ps.setBigDecimal(2, newFeesTotal);
                    ps.setBigDecimal(3, netBalance);
                    ps.setBoolean   (4, cap);
                    ps.setString    (5, STATUS_FEES_CHARGED);
                    ps.setInt       (6, poolId);
                    ps.executeUpdate();
                }

                con.commit();
                return poolId;

            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    /* ============================================================
     *  STEP 3 — Distribute shares to members by contribution
     * ============================================================ */
    public int distributeShares(int poolId) throws SQLException {

        try (Connection con = database.getConnection()) {
            con.setAutoCommit(false);
            try {
                BigDecimal netBalance;
                String     status;
                Integer    groupId;

                String sel =
                        "SELECT net_balance, status, group_id " +
                                "FROM interest_pool WHERE id = ? FOR UPDATE";
                try (PreparedStatement ps = con.prepareStatement(sel)) {
                    ps.setInt(1, poolId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            con.rollback();
                            return POOL_ROW_NOT_FOUND;
                        }
                        netBalance = rs.getBigDecimal("net_balance");
                        status     = rs.getString("status");
                        int gid    = rs.getInt("group_id");
                        groupId    = rs.wasNull() ? null : gid;
                    }
                }

                if (STATUS_PENDING_FEES.equals(status)) {
                    con.rollback();
                    return FEES_NOT_CHARGED_YET;
                }

                if (STATUS_DISTRIBUTED.equals(status)) {
                    con.rollback();
                    return SHARES_ALREADY_FROZEN;
                }

                freezeShares(con, poolId, netBalance, groupId);

                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE interest_pool SET status = ? WHERE id = ?")) {
                    ps.setString(1, STATUS_DISTRIBUTED);
                    ps.setInt   (2, poolId);
                    ps.executeUpdate();
                }

                con.commit();
                return poolId;

            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    /* ============================================================
     *  CANCEL — delete a pool row that is still PENDING_FEES
     *  -----------------------------------------------------------------
     *  Only allowed if:
     *    - status = PENDING_FEES
     *    - no fees charged
     *    - no shares frozen
     *
     *  After cancel, the interest becomes "unallocated" again
     *  so the next call to moveInterestToPool() can pick it up.
     * ============================================================ */
    public int cancelPool(int poolId) throws SQLException {

        try (Connection con = database.getConnection()) {
            con.setAutoCommit(false);
            try {
                // 1. Load status with lock
                String  status;
                Integer groupId;

                String sel = "SELECT status, group_id FROM interest_pool " +
                        "WHERE id = ? FOR UPDATE";
                try (PreparedStatement ps = con.prepareStatement(sel)) {
                    ps.setInt(1, poolId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            con.rollback();
                            return POOL_ROW_NOT_FOUND;
                        }
                        status   = rs.getString("status");
                        int gid  = rs.getInt("group_id");
                        groupId  = rs.wasNull() ? null : gid;
                    }
                }

                // 2. Refuse to cancel if fees already charged or distributed
                if (STATUS_FEES_CHARGED.equals(status)
                        || STATUS_DISTRIBUTED.equals(status)) {
                    con.rollback();
                    return CANNOT_CANCEL_AFTER_FEES;
                }

                // 3. Safety: delete any frozen shares (shouldn't exist for pending)
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM interest_distribution_share WHERE pool_id = ?")) {
                    ps.setInt(1, poolId);
                    ps.executeUpdate();
                }

                // 4. Delete the pool row itself
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM interest_pool WHERE id = ?")) {
                    ps.setInt(1, poolId);
                    ps.executeUpdate();
                }

                con.commit();
                return poolId;

            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    /* ============================================================
     *  accrueDailyFees — applies daily fee on open rows
     *  Only touches rows that haven't reached the cap.
     * ============================================================ */
    public int accrueDailyFees(Integer groupId) throws SQLException {

        try (Connection con = database.getConnection()) {
            con.setAutoCommit(false);
            try {
                if (feeAlreadyChargedToday(con, groupId)) {
                    con.rollback();
                    return 0;
                }

                StringBuilder selSql = new StringBuilder(
                        "SELECT id, fees_total, net_balance " +
                                "FROM interest_pool " +
                                "WHERE fee_cap_reached = FALSE " +
                                "  AND status <> 'PENDING_FEES' "
                );
                if (groupId != null) selSql.append("AND group_id = ? ");
                selSql.append("FOR UPDATE");

                List<int[]>        ids  = new ArrayList<>();
                List<BigDecimal[]> vals = new ArrayList<>();

                try (PreparedStatement ps = con.prepareStatement(selSql.toString())) {
                    if (groupId != null) ps.setInt(1, groupId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            ids.add(new int[]{ rs.getInt("id") });
                            vals.add(new BigDecimal[]{
                                    rs.getBigDecimal("fees_total"),
                                    rs.getBigDecimal("net_balance")
                            });
                        }
                    }
                }

                if (ids.isEmpty()) {
                    con.rollback();
                    return 0;
                }

                int updated = 0;
                String upd =
                        "UPDATE interest_pool SET " +
                                "  fee_applied     = fee_applied + ?, " +
                                "  fees_total      = ?, " +
                                "  net_balance     = ?, " +
                                "  fee_cap_reached = ? " +
                                "WHERE id = ?";

                try (PreparedStatement ps = con.prepareStatement(upd)) {
                    for (int i = 0; i < ids.size(); i++) {
                        int rowId = ids.get(i)[0];
                        BigDecimal prevTotal = vals.get(i)[0];
                        BigDecimal prevNet   = vals.get(i)[1];

                        BigDecimal remaining = FEE_CAP.subtract(prevTotal);
                        BigDecimal fee       = DAILY_FEE.min(remaining);
                        if (fee.signum() <= 0) continue;

                        BigDecimal newTotal = prevTotal.add(fee)
                                .setScale(2, RoundingMode.HALF_UP);
                        BigDecimal newNet = prevNet.subtract(fee)
                                .setScale(2, RoundingMode.HALF_UP);
                        boolean cap = newTotal.compareTo(FEE_CAP) >= 0;

                        ps.setBigDecimal(1, fee);
                        ps.setBigDecimal(2, newTotal);
                        ps.setBigDecimal(3, newNet);
                        ps.setBoolean   (4, cap);
                        ps.setInt       (5, rowId);
                        ps.addBatch();
                        updated++;
                    }
                    ps.executeBatch();
                }

                con.commit();
                return updated;

            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    /* ============================================================
     *  HELPERS
     * ============================================================ */

    private PoolRow map(ResultSet rs) throws SQLException {
        PoolRow r = new PoolRow();
        r.id               = rs.getInt("id");
        r.distributionDate = rs.getDate("distribution_date");
        r.poolStartDate    = rs.getDate("pool_start_date");
        r.interestMoved    = rs.getBigDecimal("interest_moved");
        r.feeApplied       = rs.getBigDecimal("fee_applied");
        r.netBalance       = rs.getBigDecimal("net_balance");
        r.feesTotal        = rs.getBigDecimal("fees_total");
        r.feeCapReached    = rs.getBoolean("fee_cap_reached");
        r.notes            = rs.getString("notes");
        r.groupId          = rs.getInt("group_id");
        r.status           = rs.getString("status");
        return r;
    }

    private boolean feeAlreadyChargedToday(Connection con, Integer groupId)
            throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM interest_pool WHERE distribution_date = CURDATE() "
        );
        if (groupId != null) sql.append("AND group_id = ? ");

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            if (groupId != null) ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1) > 0;
            }
        }
    }

    private BigDecimal sumUnallocatedInterest(Connection con, Integer groupId)
            throws SQLException {

        BigDecimal earned = sum(con,
                "SELECT COALESCE(SUM(amount),0) FROM loan_interest " +
                        (groupId != null ? "WHERE group_id = ?" : ""),
                groupId);

        BigDecimal moved = sum(con,
                "SELECT COALESCE(SUM(interest_moved),0) FROM interest_pool " +
                        (groupId != null ? "WHERE group_id = ?" : ""),
                groupId);

        BigDecimal result = earned.subtract(moved);
        return result.signum() < 0 ? BigDecimal.ZERO : result;
    }

    private BigDecimal getLastFeesTotal(Connection con, Integer groupId)
            throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COALESCE(MAX(fees_total), 0) FROM interest_pool "
        );
        if (groupId != null) sql.append("WHERE group_id = ? ");

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            if (groupId != null) ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                BigDecimal v = rs.getBigDecimal(1);
                return v == null ? BigDecimal.ZERO : v;
            }
        }
    }

    private BigDecimal sum(Connection con, String sql, Integer groupId)
            throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            if (groupId != null) ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                BigDecimal v = rs.getBigDecimal(1);
                return v == null ? BigDecimal.ZERO : v;
            }
        }
    }

    private void freezeShares(Connection con, int poolId,
                              BigDecimal netBalance, Integer groupId)
            throws SQLException {

        if (netBalance == null || netBalance.signum() <= 0) return;

        BigDecimal totalContrib = sum(con,
                "SELECT COALESCE(SUM(amount),0) FROM contributions " +
                        (groupId != null ? "WHERE group_id = ?" : ""),
                groupId);

        if (totalContrib.signum() == 0) return;

        StringBuilder memberSql = new StringBuilder(
                "SELECT m.PhoneNumber, COALESCE(SUM(c.amount),0) AS contrib " +
                        "FROM member m " +
                        "LEFT JOIN contributions c " +
                        "  ON c.PhoneNumber = m.PhoneNumber AND c.group_id = m.group_id " +
                        "WHERE m.IsActive = TRUE AND m.LeftEarly = FALSE "
        );
        if (groupId != null) memberSql.append("AND m.group_id = ? ");
        memberSql.append("GROUP BY m.PhoneNumber");

        try (PreparedStatement ps = con.prepareStatement(memberSql.toString())) {
            if (groupId != null) ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {

                try (PreparedStatement ins = con.prepareStatement(
                        "INSERT INTO interest_distribution_share " +
                                "(pool_id, PhoneNumber, contribution, interest_share, " +
                                " frozen_on, group_id) " +
                                "VALUES (?, ?, ?, ?, CURDATE(), ?)")) {

                    while (rs.next()) {
                        String phone = rs.getString("PhoneNumber");
                        BigDecimal contrib = rs.getBigDecimal("contrib");
                        if (contrib == null) contrib = BigDecimal.ZERO;

                        BigDecimal share = contrib.multiply(netBalance)
                                .divide(totalContrib, 2, RoundingMode.HALF_UP);

                        ins.setInt(1, poolId);
                        ins.setString(2, phone);
                        ins.setBigDecimal(3, contrib);
                        ins.setBigDecimal(4, share);
                        if (groupId != null) ins.setInt(5, groupId);
                        else                 ins.setNull(5, Types.INTEGER);
                        ins.addBatch();
                    }
                    ins.executeBatch();
                }
            }
        }
    }
}