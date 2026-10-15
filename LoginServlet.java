package servlet;

import dao.GroupDao;
import dao.UserDAO;
import model.Group;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO  userDAO  = new UserDAO();
    private final GroupDao groupDao = new GroupDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || password == null
                || username.isBlank() || password.isBlank()) {
            forward(req, resp, "Please enter username and password.", username);
            return;
        }

        User user = userDAO.findByUsername(username.trim());

        if (user == null || !userDAO.checkPassword(password, user.getPasswordHash())) {
            forward(req, resp, "Invalid username or password.", username);
            return;
        }

        HttpSession oldSession = req.getSession(false);
        if (oldSession != null) oldSession.invalidate();

        HttpSession session = req.getSession(true);
        session.setAttribute("userId",   user.getId());
        session.setAttribute("username", user.getUsername());
        session.setAttribute("fullName", user.getFullName());
        session.setMaxInactiveInterval(30 * 60);

        // Load groups and set the default current group
        try {
            List<Group> groups = groupDao.getAll();
            session.setAttribute("allGroups", groups);

            if (!groups.isEmpty()) {
                session.setAttribute("currentGroupId",   groups.get(0).getId());
                session.setAttribute("currentGroupName", groups.get(0).getGroupName());
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        resp.sendRedirect(req.getContextPath() + "/dashboard.jsp?login=success");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/index.jsp");
    }

    private void forward(HttpServletRequest req, HttpServletResponse resp,
                         String error, String username)
            throws ServletException, IOException {
        req.setAttribute("error", error);
        req.setAttribute("username", username);
        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }
}