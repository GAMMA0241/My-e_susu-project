package servlet;

import dao.GroupDao;
import dao.memberDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;

@WebServlet("/memberServlet")
public class memberServlet extends HttpServlet {

    private final memberDao memberDao = new memberDao();
    private final GroupDao  groupDao  = new GroupDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String operation = req.getParameter("operation");
        if (operation == null) operation = "";

        try {
            switch (operation) {
                case "registerForm":
                case "register":
                case "":
                    req.setAttribute("groups", groupDao.getAll());
                    req.getRequestDispatcher("registerMember.jsp").forward(req, resp);
                    break;

                case "updateForm":
                    req.setAttribute("groups", groupDao.getAll());
                    req.getRequestDispatcher("updateMember.jsp").forward(req, resp);
                    break;

                default:
                    resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");
            }
        } catch (SQLException e) {
            throw new ServletException("Member servlet error", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String operation = req.getParameter("operation");
        if (operation == null) operation = "";

        try {
            switch (operation) {
                case "register": {
                    String phone      = trim(req.getParameter("phoneNumber"));
                    String fullName   = trim(req.getParameter("fullName"));
                    String ghanaCard  = trim(req.getParameter("ghanaCardNumber"));
                    String emergency  = trim(req.getParameter("emergencyContact"));
                    String groupIdStr = trim(req.getParameter("groupId"));
                    String momo       = trim(req.getParameter("momoNumber"));
                    String bank       = trim(req.getParameter("bankAccount"));

                    if (phone.isEmpty() || fullName.isEmpty()) {
                        returnWithError(req, resp,
                                "Phone number and full name are required.",
                                phone, fullName, ghanaCard, emergency, groupIdStr, momo, bank);
                        return;
                    }
                    if (groupIdStr.isEmpty()) {
                        returnWithError(req, resp,
                                "Please select a group for this member.",
                                phone, fullName, ghanaCard, emergency, groupIdStr, momo, bank);
                        return;
                    }

                    int groupId = Integer.parseInt(groupIdStr);
                    boolean ok = memberDao.register(groupId, phone, fullName,
                            ghanaCard, emergency,
                            momo.isEmpty() ? null : momo,
                            bank.isEmpty() ? null : bank);
                    String msg = ok
                            ? "Member " + fullName + " registered successfully."
                            : "Phone number already exists in this group.";

                    resp.sendRedirect(req.getContextPath()
                            + "/memberServlet?operation=registerForm&message="
                            + URLEncoder.encode(msg, StandardCharsets.UTF_8));
                    break;
                }

                case "UpdateBiodata": {
                    String phone      = trim(req.getParameter("phoneNumber"));
                    String fullName   = trim(req.getParameter("fullName"));
                    String ghanaCard  = trim(req.getParameter("ghanaCardNumber"));
                    String emergency  = trim(req.getParameter("emergencyContact"));
                    String groupIdStr = trim(req.getParameter("groupId"));

                    if (phone.isEmpty() || groupIdStr.isEmpty()) {
                        resp.sendRedirect(req.getContextPath()
                                + "/memberServlet?operation=updateForm&message="
                                + URLEncoder.encode("Phone and group are required.",
                                StandardCharsets.UTF_8));
                        return;
                    }

                    int groupId = Integer.parseInt(groupIdStr);
                    boolean ok = memberDao.update(groupId, phone, fullName, ghanaCard, emergency);
                    String msg = ok ? "Member updated." : "No changes saved.";

                    resp.sendRedirect(req.getContextPath()
                            + "/memberServlet?operation=updateForm&message="
                            + URLEncoder.encode(msg, StandardCharsets.UTF_8));
                    break;
                }

                default:
                    resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");
            }
        } catch (SQLException e) {
            throw new ServletException("Member servlet error", e);
        }
    }

    private void returnWithError(HttpServletRequest req, HttpServletResponse resp,
                                 String error, String phone, String fullName,
                                 String ghanaCard, String emergency,
                                 String groupId, String momo, String bank)
            throws ServletException, IOException, SQLException {
        req.setAttribute("error",            error);
        req.setAttribute("phoneNumber",      phone);
        req.setAttribute("fullName",         fullName);
        req.setAttribute("ghanaCardNumber",  ghanaCard);
        req.setAttribute("emergencyContact", emergency);
        req.setAttribute("selectedGroup",    groupId);
        req.setAttribute("momoNumber",       momo);
        req.setAttribute("bankAccount",      bank);
        req.setAttribute("groups",           groupDao.getAll());
        req.getRequestDispatcher("registerMember.jsp").forward(req, resp);
    }

    private static String trim(String s) { return s == null ? "" : s.trim(); }
}