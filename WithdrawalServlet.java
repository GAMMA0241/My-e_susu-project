package servlet;

import dao.GroupDao;
import dao.WithdrawalDao;
import model.Group;
import model.WithdrawalRequest;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@WebServlet("/withdrawalServlet")
public class WithdrawalServlet extends HttpServlet {

    private final WithdrawalDao withdrawalDao = new WithdrawalDao();
    private final GroupDao      groupDao      = new GroupDao();

    private Integer currentGroup(HttpServletRequest req) {
        return (Integer) req.getSession().getAttribute("currentGroupId");
    }

    private String currentUser(HttpServletRequest req) {
        Object u = req.getSession().getAttribute("username");
        return u == null ? "system" : u.toString();
    }


    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer gid = currentGroup(req);
        if (gid == null) { resp.sendRedirect(req.getContextPath() + "/index.jsp"); return; }

        String operation = req.getParameter("operation");
        if (operation == null) operation = "";

        try {
            switch (operation) {

                case "lookup":
                    handleLookup(req, resp, gid);
                    break;

                case "list":
                    List<WithdrawalRequest> list = withdrawalDao.getByGroup(gid);
                    req.setAttribute("requests",        list);
                    req.setAttribute("selectedGroupId", gid);
                    req.setAttribute("groups",          groupDao.getAll());
                    req.getRequestDispatcher("withdrawalsList.jsp").forward(req, resp);
                    break;

                case "":
                case "start":
                default:
                    req.setAttribute("groups",          groupDao.getAll());
                    req.setAttribute("selectedGroupId", gid);
                    req.getRequestDispatcher("withdrawal.jsp").forward(req, resp);
                    break;
            }
        } catch (SQLException e) {
            throw new ServletException("Withdrawal servlet error", e);
        }
    }

    /*
     *  POST
     * */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer gid = currentGroup(req);
        if (gid == null) { resp.sendRedirect(req.getContextPath() + "/index.jsp"); return; }

        String operation = req.getParameter("operation");
        if (operation == null) operation = "";

        try {
            switch (operation) {

                case "submit":
                    handleSubmit(req, resp, gid);
                    break;

                /* ---------- MARK PAID ---------- */
                case "markPaid": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    String msg;
                    try {
                        boolean ok = withdrawalDao.markPaid(id, currentUser(req));
                        msg = ok ? "Request marked as PAID."
                                : "Mark-paid failed — request may already be processed.";
                    } catch (SQLException e) {
                        msg = "Mark-paid failed: " + e.getMessage();
                    }
                    resp.sendRedirect(req.getContextPath()
                            + "/withdrawalServlet?operation=list&message=" + encode(msg));
                    break;
                }

                /* ---------- REJECT / CANCEL ---------- */
                case "reject": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    String reason = trim(req.getParameter("reason"));

                    String msg;
                    try {
                        boolean ok = withdrawalDao.reject(id, currentUser(req), reason);
                        msg = ok ? "Request rejected / cancelled."
                                : "Reject failed — request may already be processed.";
                    } catch (SQLException e) {
                        msg = "Reject failed: " + e.getMessage();
                    }
                    resp.sendRedirect(req.getContextPath()
                            + "/withdrawalServlet?operation=list&message=" + encode(msg));
                    break;
                }

                default:
                    resp.sendRedirect(req.getContextPath() + "/withdrawalServlet");
            }
        } catch (SQLException e) {
            throw new ServletException("Withdrawal servlet error", e);
        }
    }

    /*
     *  HANDLERS
     *  */
    private void handleLookup(HttpServletRequest req, HttpServletResponse resp, int gid)
            throws ServletException, IOException, SQLException {

        String phone = trim(req.getParameter("phoneNumber"));
        if (phone.isEmpty()) {
            req.setAttribute("error", "Phone number is required.");
            req.getRequestDispatcher("withdrawal.jsp").forward(req, resp);
            return;
        }

        Object[] summary = withdrawalDao.getMemberSummary(gid, phone);
        if (summary == null) {
            req.setAttribute("error",
                    "No member found with phone " + phone + " in this group.");
            req.getRequestDispatcher("withdrawal.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("phoneNumber",   phone);
        req.setAttribute("memberName",    summary[4]);
        req.setAttribute("contribution",  summary[0]);
        req.setAttribute("interestShare", summary[1]);
        req.setAttribute("monthsInGroup", summary[2]);
        req.setAttribute("maturityDate",  summary[3]);
        req.setAttribute("matured",       summary[5]);
        req.setAttribute("groups",        groupDao.getAll());
        req.setAttribute("selectedGroupId", gid);

        // Groups available for TRANSFER (exclude the current group)
        try {
            List<Group> all = groupDao.getAll();
            List<Group> targets = new ArrayList<>();
            for (Group g : all) {
                if (g.getId() != gid) targets.add(g);
            }
            req.setAttribute("availableGroups", targets);
        } catch (SQLException e) {
            req.setAttribute("availableGroups", Collections.emptyList());
        }

        req.getRequestDispatcher("withdrawalForm.jsp").forward(req, resp);
    }

    private void handleSubmit(HttpServletRequest req, HttpServletResponse resp, int gid)
            throws ServletException, IOException, SQLException {

        String phone       = trim(req.getParameter("phoneNumber"));
        String type        = trim(req.getParameter("requestType"));
        String momo        = trim(req.getParameter("momoNumber"));
        String targetGroup = trim(req.getParameter("targetGroupName"));
        String bankAccount = trim(req.getParameter("targetBankAccount"));
        String notes       = trim(req.getParameter("notes"));

        if (phone.isEmpty() || type.isEmpty()) {
            redirectBack(resp, gid, "Phone and request type are required.");
            return;
        }

        WithdrawalRequest computed = withdrawalDao.compute(gid, phone, type);
        if (computed == null) {
            redirectBack(resp, gid, "Member not found for phone " + phone);
            return;
        }

        // validation per type
        if (("TERMINATION".equals(type) || "MATURITY".equals(type)) && momo.isEmpty()) {
            redirectBack(resp, gid, "MoMo number is required.");
            return;
        }
        if ("TRANSFER".equals(type)
                && (targetGroup.isEmpty() || bankAccount.isEmpty())) {
            redirectBack(resp, gid,
                    "Target group name and bank account are required for transfer.");
            return;
        }

        computed.setMomoNumber(momo.isEmpty() ? null : momo);
        computed.setTargetGroupName(targetGroup.isEmpty() ? null : targetGroup);
        computed.setTargetBankAccount(bankAccount.isEmpty() ? null : bankAccount);
        computed.setNotes(notes.isEmpty() ? null : notes);

        int newId = withdrawalDao.save(computed, currentUser(req));

        resp.sendRedirect(req.getContextPath()
                + "/withdrawalServlet?operation=list&message="
                + encode("Request #" + newId + " submitted ("
                + type + "). Amount: GHS " + computed.getAmountPayable()));
    }


    private void redirectBack(HttpServletResponse resp, int gid, String message)
            throws IOException {
        String ctx = getServletContext().getContextPath();
        resp.sendRedirect(resp.encodeRedirectURL(
                ctx + "/withdrawalServlet?message=" + encode(message)));
    }

    private static String trim(String s) { return s == null ? "" : s.trim(); }

    private String encode(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}