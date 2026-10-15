package servlet;

import dao.GroupDao;
import model.Group;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;

@WebServlet("/groups")
public class GroupServlet extends HttpServlet {

    private final GroupDao groupDao = new GroupDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            req.setAttribute("groups", groupDao.getAll());
            req.getRequestDispatcher("groups.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Load groups error", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String operation = req.getParameter("operation");
        if (operation == null) operation = "";

        try {
            switch (operation) {
                case "add": {
                    String name = trim(req.getParameter("groupName"));
                    String loc  = trim(req.getParameter("location"));

                    if (name.isEmpty()) {
                        req.setAttribute("error", "Group name is required.");
                        req.setAttribute("groups", groupDao.getAll());
                        req.getRequestDispatcher("groups.jsp").forward(req, resp);
                        return;
                    }

                    boolean ok = groupDao.add(name, loc);
                    String msg = ok ? "Group added." : "Group name already exists.";
                    resp.sendRedirect(req.getContextPath() + "/groups?message="
                            + URLEncoder.encode(msg, StandardCharsets.UTF_8));
                    break;
                }

                case "switch": {
                    int id = Integer.parseInt(req.getParameter("groupId"));
                    Group g = groupDao.findById(id);
                    if (g != null) {
                        HttpSession session = req.getSession();
                        session.setAttribute("currentGroupId",   g.getId());
                        session.setAttribute("currentGroupName", g.getGroupName());
                        session.setAttribute("allGroups",        groupDao.getAll());
                    }
                    String from = req.getParameter("from");
                    if ("groups".equals(from)) {
                        resp.sendRedirect(req.getContextPath() + "/groups");
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");
                    }
                    break;
                }

                default:
                    resp.sendRedirect(req.getContextPath() + "/groups");
            }
        } catch (SQLException e) {
            throw new ServletException("Group operation error", e);
        }
    }

    private static String trim(String s) { return s == null ? "" : s.trim(); }
}