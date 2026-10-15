package servlet;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/signup")
public class SignupServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String confirm  = req.getParameter("confirm");
        String fullName = req.getParameter("fullName");

        // --- validation ---
        if (username == null || username.isBlank()
                || password == null || password.isBlank()) {
            forward(req, resp, "Username and password are required.", username, fullName);
            return;
        }
        if (password.length() < 6) {
            forward(req, resp, "Password must be at least 6 characters.", username, fullName);
            return;
        }
        if (!password.equals(confirm)) {
            forward(req, resp, "Passwords do not match.", username, fullName);
            return;
        }

        // --- store in DB (password hashed inside DAO) ---
        boolean ok = userDAO.register(username.trim(), password, fullName);

        if (!ok) {
            forward(req, resp, "Username already taken. Try another.", username, fullName);
            return;
        }

        // --- success → redirect to login page ---
        resp.sendRedirect(req.getContextPath() + "/index.jsp?registered=1");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/signup.jsp");
    }

    private void forward(HttpServletRequest req, HttpServletResponse resp,
                         String error, String username, String fullName)
            throws ServletException, IOException {
        req.setAttribute("error", error);
        req.setAttribute("username", username);
        req.setAttribute("fullName", fullName);
        req.getRequestDispatcher("/signup.jsp").forward(req, resp);
    }
}