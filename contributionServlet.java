package servlet;

import dao.contributionDao;
import dao.GroupDao;
import dao.memberDao;
import model.Group;
import model.member;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/contributionServlet")
public class contributionServlet extends HttpServlet {

    private final contributionDao contributionDao = new contributionDao();
    private final memberDao       memberDao       = new memberDao();
    private final GroupDao        groupDao        = new GroupDao();

    /* ============================================================
     *  GET — form, or members-and-totals view
     * ============================================================ */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String operation = req.getParameter("operation");
        if (operation == null) operation = "";

        try {
            switch (operation) {

                case "viewMembersAndTotal":
                    loadMembersAndTotals(req, resp);
                    break;

                case "contribute":
                case "":
                default:
                    loadContributionForm(req, resp);
                    break;
            }
        } catch (SQLException e) {
            throw new ServletException("Contribution servlet error", e);
        }
    }

    /* ============================================================
     *  POST — record a contribution
     * ============================================================ */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String phone    = trim(req.getParameter("PhoneNumber"));
        String amtStr   = trim(req.getParameter("amount"));
        String groupStr = trim(req.getParameter("groupId"));

        if (phone.isEmpty()) {
            returnWithError(req, resp, "Phone number is required.",
                    phone, amtStr, groupStr);
            return;
        }
        if (groupStr.isEmpty()) {
            returnWithError(req, resp, "Please choose a group.",
                    phone, amtStr, groupStr);
            return;
        }

        BigDecimal amount;
        try {
            amount = new BigDecimal(amtStr);
            if (amount.signum() <= 0) throw new NumberFormatException();
        } catch (Exception e) {
            returnWithError(req, resp, "Amount must be a positive number.",
                    phone, amtStr, groupStr);
            return;
        }

        int groupId;
        try {
            groupId = Integer.parseInt(groupStr);
        } catch (NumberFormatException e) {
            returnWithError(req, resp, "Invalid group.",
                    phone, amtStr, groupStr);
            return;
        }

        try {
            // Confirm the member exists IN THAT GROUP
            member m = memberDao.findByPhone(groupId, phone);
            if (m == null) {
                returnWithError(req, resp,
                        "No member found with phone " + phone + " in the selected group.",
                        phone, amtStr, groupStr);
                return;
            }

            // Save contribution under the chosen group
            contributionDao.add(groupId, m.getPhoneNumber(), amount);

            // Keep session's current group in sync with the choice
            HttpSession session = req.getSession();
            session.setAttribute("currentGroupId",   groupId);
            session.setAttribute("currentGroupName", groupDao.findName(groupId));
            session.setAttribute("allGroups",        groupDao.getAll());

            resp.sendRedirect(req.getContextPath()
                    + "/contributionServlet?success=Contribution+recorded+for+"
                    + URLEncoder.encode(m.getFullName(), StandardCharsets.UTF_8));

        } catch (SQLException e) {
            throw new ServletException("Contribution error", e);
        }
    }

    /* ============================================================
     *  Helpers
     * ============================================================ */
    private void loadContributionForm(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {

        List<Group> groups = groupDao.getAll();
        req.setAttribute("groups", groups);

        Integer currentGid = (Integer) req.getSession().getAttribute("currentGroupId");
        req.setAttribute("selectedGroupId", currentGid);

        req.getRequestDispatcher("contribution.jsp").forward(req, resp);
    }

    private void loadMembersAndTotals(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {

        List<Group> allGroups = groupDao.getAll();
        req.setAttribute("groups", allGroups);

        Map<Integer, List<contributionDao.MemberTotal>> membersByGroup = new LinkedHashMap<>();
        BigDecimal grandTotal = BigDecimal.ZERO;

        for (Group g : allGroups) {
            List<contributionDao.MemberTotal> members =
                    contributionDao.getMemberTotalsByGroup(g.getId());
            membersByGroup.put(g.getId(), members);

            for (contributionDao.MemberTotal mt : members) {
                grandTotal = grandTotal.add(mt.getTotal());
            }
        }

        req.setAttribute("membersByGroup", membersByGroup);
        req.setAttribute("grandTotal",     grandTotal);

        req.getRequestDispatcher("membersAndTotals.jsp").forward(req, resp);
    }

    private void returnWithError(HttpServletRequest req, HttpServletResponse resp,
                                 String error, String phone, String amount, String groupId)
            throws ServletException, IOException {
        try {
            req.setAttribute("error",           error);
            req.setAttribute("phoneNumber",     phone);
            req.setAttribute("amount",          amount);
            req.setAttribute("selectedGroupId", groupId);
            req.setAttribute("groups",          groupDao.getAll());
            req.getRequestDispatcher("contribution.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Load groups error", e);
        }
    }

    private static String trim(String s) { return s == null ? "" : s.trim(); }
}