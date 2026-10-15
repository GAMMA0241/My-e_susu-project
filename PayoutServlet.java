package servlet;

import dao.GroupDao;
import dao.PayoutDao;
import dao.InterestPoolDao;
import model.PayoutRow;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/payoutServlet")
public class PayoutServlet extends HttpServlet {

    private final PayoutDao      payoutDao = new PayoutDao();
    private final GroupDao       groupDao  = new GroupDao();
    private final InterestPoolDao poolDao  = new InterestPoolDao();  // ← shared instance

    private Integer currentGroup(HttpServletRequest req) {
        return (Integer) req.getSession().getAttribute("currentGroupId");
    }

    private Integer parseGroupParam(HttpServletRequest req) {
        String raw = req.getParameter("groupId");
        if (raw == null || raw.isBlank()) return null;
        try { return Integer.parseInt(raw); }
        catch (NumberFormatException e) { return null; }
    }

    /* ============================================================
     *  GET
     * ============================================================ */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String operation = request.getParameter("operation");
        if (operation == null) operation = "";

        try {
            switch (operation) {

                case "viewPayouts":
                default: {
                    Integer groupId = parseGroupParam(request);
                    if (groupId == null) groupId = currentGroup(request);

                    List<PayoutRow> rows = payoutDao.computePayouts(groupId);

                    double totalContrib = 0, totalPayout = 0;
                    for (PayoutRow r : rows) {
                        totalContrib += r.getContribution();
                        totalPayout  += r.getAmountDue();
                    }

                    request.setAttribute("payouts",        rows);
                    request.setAttribute("totalInterest",  payoutDao.getTotalInterestPool(groupId));
                    request.setAttribute("totalContrib",   totalContrib);
                    request.setAttribute("totalPayout",    totalPayout);
                    request.setAttribute("selectedGroupId", groupId);
                    request.setAttribute("groups",         groupDao.getAll());

                    request.getRequestDispatcher("viewPayouts.jsp")
                            .forward(request, response);
                    break;
                }

                case "savedSchedule": {
                    Integer groupId = parseGroupParam(request);
                    if (groupId == null) groupId = currentGroup(request);

                    List<PayoutRow> rows = payoutDao.getSavedSchedule(groupId);
                    request.setAttribute("payouts",        rows);
                    request.setAttribute("selectedGroupId", groupId);
                    request.setAttribute("groups",         groupDao.getAll());

                    request.getRequestDispatcher("viewPayouts.jsp")
                            .forward(request, response);
                    break;
                }

                case "viewInterestPool": {
                    Integer groupId = parseGroupParam(request);
                    if (groupId == null) groupId = currentGroup(request);

                    request.setAttribute("poolRows",         poolDao.getAllPoolRows(groupId));
                    request.setAttribute("totalPoolBalance", poolDao.getTotalPoolBalance(groupId));
                    request.setAttribute("totalFeesCharged", poolDao.getTotalFeesCharged(groupId));
                    request.setAttribute("selectedGroupId",  groupId);
                    request.setAttribute("groups",           groupDao.getAll());

                    request.getRequestDispatcher("interest_pool.jsp")
                            .forward(request, response);
                    break;
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Payout servlet error", e);
        }
    }

    /* ============================================================
     *  POST
     * ============================================================ */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String operation = request.getParameter("operation");
        if (operation == null) operation = "";

        try {
            switch (operation) {

                /* ---------- SAVE SNAPSHOT ---------- */
                case "saveSchedule": {
                    Integer groupId = parseGroupParam(request);
                    if (groupId == null) groupId = currentGroup(request);

                    List<PayoutRow> rows = payoutDao.computePayouts(groupId);
                    boolean ok = payoutDao.savePayoutSchedule(rows, groupId);
                    String msg = ok
                            ? "Payout schedule saved."
                            : "Failed to save payout schedule.";
                    response.sendRedirect(request.getContextPath()
                            + "/payoutServlet?operation=savedSchedule&groupId="
                            + (groupId == null ? "" : groupId)
                            + "&message=" + encode(msg));
                    break;
                }

                /* ---------- MARK A PAYOUT AS PAID ---------- */
                case "markPaid": {
                    String phone = request.getParameter("PhoneNumber");
                    Integer groupId = parseGroupParam(request);
                    if (groupId == null) groupId = currentGroup(request);

                    boolean ok = payoutDao.markPaid(phone, groupId);
                    String msg = ok ? "Payout marked as paid." : "Mark-paid failed.";
                    response.sendRedirect(request.getContextPath()
                            + "/payoutServlet?operation=savedSchedule&groupId="
                            + (groupId == null ? "" : groupId)
                            + "&message=" + encode(msg));
                    break;
                }

                /* ---------- STEP 1: MOVE INTEREST TO POOL ---------- */
                case "distributeInterest": {
                    Integer groupId = parseGroupParam(request);
                    if (groupId == null) groupId = currentGroup(request);

                    int rc;
                    try {
                        rc = poolDao.moveInterestToPool("Manual distribution", groupId);
                    } catch (SQLException e) {
                        redirectPool(request, response, groupId,
                                "Distribution failed: " + e.getMessage());
                        return;
                    }

                    String msg;
                    if (rc == InterestPoolDao.FEE_ALREADY_CHARGED_TODAY) {
                        msg = "A pool entry already exists for today. Wait until tomorrow.";
                    } else if (rc == InterestPoolDao.NOTHING_TO_DISTRIBUTE) {
                        msg = "Nothing to distribute — no new interest since last run.";
                    } else if (rc > 0) {
                        msg = "✅ Interest moved to pool (row #" + rc
                                + "). Now click Charge Fees.";
                    } else {
                        msg = "Distribution failed.";
                    }
                    redirectPool(request, response, groupId, msg);
                    break;
                }

                /* ---------- STEP 2: CHARGE FEES ON A POOL ROW ---------- */
                case "chargeFees": {
                    Integer groupId = parseGroupParam(request);
                    if (groupId == null) groupId = currentGroup(request);

                    int poolId;
                    try {
                        poolId = Integer.parseInt(request.getParameter("poolId"));
                    } catch (Exception e) {
                        redirectPool(request, response, groupId,
                                "Invalid pool row selected.");
                        return;
                    }

                    int rc;
                    try {
                        rc = poolDao.chargeFees(poolId);
                    } catch (SQLException e) {
                        redirectPool(request, response, groupId,
                                "Fee charge failed: " + e.getMessage());
                        return;
                    }

                    String msg;
                    if (rc == InterestPoolDao.POOL_ROW_NOT_FOUND) {
                        msg = "❌ Pool row not found.";
                    } else if (rc == InterestPoolDao.FEE_ALREADY_CHARGED) {
                        msg = "⚠️ Fees already charged on this row.";
                    } else if (rc > 0) {
                        msg = "✅ Fees charged on pool row #" + rc
                                + ". Now click Distribute.";
                    } else {
                        msg = "Fee charge failed.";
                    }
                    redirectPool(request, response, groupId, msg);
                    break;
                }

                /* ---------- STEP 3: DISTRIBUTE SHARES TO MEMBERS ---------- */
                case "distributeShares": {
                    Integer groupId = parseGroupParam(request);
                    if (groupId == null) groupId = currentGroup(request);

                    int poolId;
                    try {
                        poolId = Integer.parseInt(request.getParameter("poolId"));
                    } catch (Exception e) {
                        redirectPool(request, response, groupId,
                                "Invalid pool row selected.");
                        return;
                    }

                    int rc;
                    try {
                        rc = poolDao.distributeShares(poolId);
                    } catch (SQLException e) {
                        redirectPool(request, response, groupId,
                                "Distribution failed: " + e.getMessage());
                        return;
                    }

                    String msg;
                    if (rc == InterestPoolDao.POOL_ROW_NOT_FOUND) {
                        msg = "❌ Pool row not found.";
                    } else if (rc == InterestPoolDao.FEES_NOT_CHARGED_YET) {
                        msg = "⚠️ You must charge fees first!";
                    } else if (rc == InterestPoolDao.SHARES_ALREADY_FROZEN) {
                        msg = "⚠️ Shares already distributed on this row.";
                    } else if (rc > 0) {
                        msg = "✅ Shares distributed to members (pool row #" + rc + ").";
                    } else {
                        msg = "Distribution failed.";
                    }
                    redirectPool(request, response, groupId, msg);
                    break;
                }

                /* ---------- ACCRUE ONE DAY OF FEES ---------- */
                case "accrueFees": {
                    Integer groupId = parseGroupParam(request);
                    if (groupId == null) groupId = currentGroup(request);

                    int n;
                    try {
                        n = poolDao.accrueDailyFees(groupId);
                    } catch (SQLException e) {
                        redirectPool(request, response, groupId,
                                "Fee accrual failed: " + e.getMessage());
                        return;
                    }

                    String msg;
                    if (n == 0) {
                        msg = "No fees accrued. Either the fee for this group was already "
                                + "charged today, or there are no open pools.";
                    } else {
                        msg = "Accrued one day of fees across " + n + " open pool(s).";
                    }
                    redirectPool(request, response, groupId, msg);
                    break;
                }

                default:
                    response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
            }
        } catch (SQLException e) {
            throw new ServletException("Payout servlet error", e);
        }
    }

    /* ============================================================
     *  Helpers
     * ============================================================ */
    private void redirectPool(HttpServletRequest req, HttpServletResponse resp,
                              Integer groupId, String message) throws IOException {
        resp.sendRedirect(req.getContextPath()
                + "/payoutServlet?operation=viewInterestPool&groupId="
                + (groupId == null ? "" : groupId)
                + "&message=" + encode(message));
    }

    private String encode(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}