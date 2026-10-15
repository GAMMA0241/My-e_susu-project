package servlet;

import dao.GroupDao;
import dao.InterestPoolDao;
import dao.LoanDao;
import dao.LoanFundDao;
import model.Group;
import model.Loan;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/loanServlet")
public class LoanServlet extends HttpServlet {

    private final LoanDao         loanDao         = new LoanDao();
    private final LoanFundDao     loanFundDao     = new LoanFundDao();
    private final GroupDao        groupDao        = new GroupDao();
    private final InterestPoolDao interestPoolDao = new InterestPoolDao();

    /* ============================================================
     *  Determine which group the current request is for.
     * ============================================================ */
    private Integer resolveGroup(HttpServletRequest req) throws SQLException {
        String raw = req.getParameter("groupId");
        Integer gid = null;

        if (raw != null && !raw.isBlank()) {
            try { gid = Integer.parseInt(raw.trim()); }
            catch (NumberFormatException ignored) { }
        }

        if (gid == null) {
            gid = (Integer) req.getSession().getAttribute("currentGroupId");
        }

        if (gid != null) {
            req.getSession().setAttribute("currentGroupId", gid);
            req.getSession().setAttribute("currentGroupName", groupDao.findName(gid));
        }
        return gid;
    }

    /* ============================================================
     *  GET
     * ============================================================ */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            Integer gid = resolveGroup(request);
            if (gid == null) {
                response.sendRedirect(request.getContextPath() + "/index.jsp");
                return;
            }

            String operation = request.getParameter("operation");
            if (operation == null) operation = "";

            List<Group> groups = groupDao.getAll();
            request.setAttribute("groups", groups);
            request.setAttribute("selectedGroupId", gid);

            switch (operation) {
                case "viewFund":
                    request.setAttribute("balance",            loanFundDao.getBalance(gid));
                    request.setAttribute("poolBalance",        loanFundDao.getPoolBalance(gid));
                    request.setAttribute("totalContributions", loanFundDao.getTotalContributions(gid));
                    request.setAttribute("totalAllocated",     loanFundDao.getTotalAllocated(gid));
                    request.setAttribute("entries",            loanFundDao.getAllEntries(gid));
                    request.getRequestDispatcher("loan_fund.jsp").forward(request, response);
                    break;

                case "newFundEntry":
                    request.getRequestDispatcher("add_fund.jsp").forward(request, response);
                    break;

                case "newLoan":
                    request.setAttribute("fundBalance",  loanFundDao.getBalance(gid));
                    request.setAttribute("interestRate", loanDao.getInterestRate());
                    request.getRequestDispatcher("loanApplication.jsp").forward(request, response);
                    break;

                case "repayForm":
                    request.setAttribute("outstandingLoans", loanDao.getOutstandingLoans(gid));
                    request.getRequestDispatcher("repayment.jsp").forward(request, response);
                    break;

                case "outstandingLoansJson":
                    writeOutstandingLoansJson(response, gid);
                    break;

                default:
                    response.sendRedirect("index.jsp");
            }
        } catch (SQLException e) {
            throw new ServletException("Loan servlet error", e);
        }
    }

    /* ============================================================
     *  POST
     * ============================================================ */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            Integer gid = resolveGroup(request);
            if (gid == null) {
                response.sendRedirect(request.getContextPath() + "/index.jsp");
                return;
            }

            String operation = request.getParameter("operation");
            if (operation == null) operation = "";

            switch (operation) {

                /* -------------------- ALLOCATE -------------------- */
                case "allocate": {
                    String amtStr = request.getParameter("amount");
                    String note   = request.getParameter("note");

                    BigDecimal amount;
                    try {
                        amount = new BigDecimal(amtStr.trim());
                        if (amount.signum() <= 0) throw new NumberFormatException();
                    } catch (Exception e) {
                        redirect(response,
                                "loanServlet?operation=newFundEntry&groupId=" + gid,
                                "Amount must be a positive number.");
                        return;
                    }

                    boolean ok;
                    try {
                        ok = loanFundDao.allocate(gid, amount, note);
                    } catch (SQLException e) {
                        redirect(response,
                                "loanServlet?operation=viewFund&groupId=" + gid,
                                "Allocation failed: " + e.getMessage());
                        return;
                    }

                    String msg = ok
                            ? "GHS " + amount.setScale(2, RoundingMode.HALF_UP)
                              + " moved into the loan fund."
                            : "Allocation failed. Group may not exist, "
                              + "or the amount exceeds unallocated contributions.";
                    redirect(response,
                            "loanServlet?operation=viewFund&groupId=" + gid, msg);
                    break;
                }

                /* -------------------- ISSUE LOAN -------------------- */
                case "issue": {
                    String phone     = request.getParameter("PhoneNumber");
                    String prinStr   = request.getParameter("principal");
                    String monthsStr = request.getParameter("months");

                    BigDecimal principal;
                    int months;
                    try {
                        principal = new BigDecimal(prinStr.trim());
                        months    = Integer.parseInt(monthsStr);
                        if (principal.signum() <= 0 || months < 1 || months > 6)
                            throw new NumberFormatException();
                    } catch (Exception e) {
                        redirect(response,
                                "loanServlet?operation=newLoan&groupId=" + gid,
                                "Invalid amount or duration.");
                        return;
                    }

                    if (phone == null || phone.trim().isEmpty()) {
                        redirect(response,
                                "loanServlet?operation=newLoan&groupId=" + gid,
                                "Phone number is required.");
                        return;
                    }

                    String cleanPhone = phone.trim();

                    boolean ok;
                    try {
                        ok = loanDao.issueLoan(gid, cleanPhone, principal, months);
                    } catch (LoanDao.UnknownMemberException e) {
                        redirect(response,
                                "loanServlet?operation=newLoan&groupId=" + gid,
                                "No member found with phone number "
                                        + cleanPhone + ". Check the number and try again.");
                        return;
                    } catch (SQLException e) {
                        redirect(response,
                                "loanServlet?operation=newLoan&groupId=" + gid,
                                "Loan could not be issued: " + e.getMessage());
                        return;
                    }

                    String msg = ok
                            ? "Loan issued successfully. GHS "
                              + principal.setScale(2, RoundingMode.HALF_UP)
                              + " deducted from the fund."
                            : "Loan failed. Fund balance is not enough.";
                    redirect(response,
                            "loanServlet?operation=viewFund&groupId=" + gid, msg);
                    break;
                }

                /* -------------------- REPAY -------------------- */
                case "repay": {
                    String idStr = request.getParameter("loanId");
                    int loanId;
                    try { loanId = Integer.parseInt(idStr); }
                    catch (Exception e) {
                        redirect(response,
                                "loanServlet?operation=repayForm&groupId=" + gid,
                                "Invalid loan selected.");
                        return;
                    }

                    boolean ok;
                    try {
                        ok = loanDao.repayLoan(gid, loanId);
                    } catch (SQLException e) {
                        redirect(response,
                                "loanServlet?operation=repayForm&groupId=" + gid,
                                "Repayment failed: " + e.getMessage());
                        return;
                    }

                    String msg = ok
                            ? "Loan repaid. Principal returned to the fund."
                            : "Repayment failed.";
                    redirect(response,
                            "loanServlet?operation=viewFund&groupId=" + gid, msg);
                    break;
                }

                /* -------------------- STEP 1: MOVE INTEREST TO POOL -------------------- */
                case "distributeInterest": {
                    String note = request.getParameter("note");
                    if (note == null) note = "";

                    int rc;
                    try {
                        rc = interestPoolDao.moveInterestToPool(note, gid);
                    } catch (SQLException e) {
                        redirect(response,
                                "loanServlet?operation=viewFund&groupId=" + gid,
                                "Distribution failed: " + e.getMessage());
                        return;
                    }

                    String msg;
                    if (rc == InterestPoolDao.FEE_ALREADY_CHARGED_TODAY) {
                        msg = "A pool entry already exists for today. Wait until tomorrow.";
                    } else if (rc == InterestPoolDao.NOTHING_TO_DISTRIBUTE) {
                        msg = "Nothing to distribute yet for this group.";
                    } else if (rc > 0) {
                        msg = "✅ Interest moved to pool (#" + rc
                                + "). Go to Interest Pool page to charge fees and distribute.";
                    } else {
                        msg = "Distribution failed.";
                    }
                    redirect(response,
                            "loanServlet?operation=viewFund&groupId=" + gid, msg);
                    break;
                }

                default:
                    response.sendRedirect("index.jsp");
            }
        } catch (SQLException e) {
            throw new ServletException("Loan servlet error", e);
        }
    }

    /* ============================================================
     *  JSON endpoint
     * ============================================================ */
    private void writeOutstandingLoansJson(HttpServletResponse response, int gid)
            throws IOException, SQLException {
        List<Loan> loans = loanDao.getOutstandingLoans(gid);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < loans.size(); i++) {
            Loan l = loans.get(i);
            if (i > 0) sb.append(",");
            sb.append("{\"id\":").append(l.getId()).append(",")
                    .append("\"phone\":\"").append(escapeJson(l.getPhoneNumber())).append("\",")
                    .append("\"principal\":").append(jsonNum(l.getPrincipal())).append(",")
                    .append("\"interest\":").append(jsonNum(l.getInterestAmount())).append(",")
                    .append("\"issuedOn\":\"")
                    .append(l.getIssuedOn() != null ? l.getIssuedOn() : "").append("\",")
                    .append("\"dueDate\":\"")
                    .append(l.getDueDate() != null ? l.getDueDate() : "").append("\"}");
        }
        sb.append("]");
        response.getWriter().write(sb.toString());
    }

    private String jsonNum(BigDecimal b) {
        return (b == null ? "0" : b.toPlainString());
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    private void redirect(HttpServletResponse response, String baseUrl, String message)
            throws IOException {
        String sep = baseUrl.contains("?") ? "&" : "?";
        response.sendRedirect(baseUrl + sep + "message=" + encode(message));
    }

    private String encode(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}