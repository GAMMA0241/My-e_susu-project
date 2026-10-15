package servlet;

import dao.SignatoryDao;
import model.Signatory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/signatories")
public class SignatoriesServlet extends HttpServlet {

    private final SignatoryDao dao = new SignatoryDao();

    private Integer currentGroup(HttpServletRequest req) {
        return (Integer) req.getSession().getAttribute("currentGroupId");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer gid = currentGroup(req);
        if (gid == null) { resp.sendRedirect(req.getContextPath() + "/index.jsp"); return; }

        try {
            List<Signatory> list = dao.getByGroup(gid);
            if (list.size() >= 1) req.setAttribute("sig1", list.get(0));
            if (list.size() >= 2) req.setAttribute("sig2", list.get(1));
            req.getRequestDispatcher("signatories.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Signatories load error", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer gid = currentGroup(req);
        if (gid == null) { resp.sendRedirect(req.getContextPath() + "/index.jsp"); return; }

        try {
            Signatory s1 = new Signatory();
            s1.setFullName(trim(req.getParameter("name1")));
            s1.setPhoneNumber(trim(req.getParameter("phone1")));
            s1.setPosition(trim(req.getParameter("position1")));

            Signatory s2 = new Signatory();
            s2.setFullName(trim(req.getParameter("name2")));
            s2.setPhoneNumber(trim(req.getParameter("phone2")));
            s2.setPosition(trim(req.getParameter("position2")));

            if (s1.getFullName().isBlank() || s2.getFullName().isBlank()) {
                req.setAttribute("error", "Both signatories must have a name.");
                req.setAttribute("sig1", s1);
                req.setAttribute("sig2", s2);
                req.getRequestDispatcher("signatories.jsp").forward(req, resp);
                return;
            }

            dao.saveTwo(gid, s1, s2);
            resp.sendRedirect(req.getContextPath() + "/signatories?saved=1");
        } catch (SQLException e) {
            throw new ServletException("Signatories save error", e);
        }
    }

    private static String trim(String s) { return s == null ? "" : s.trim(); }
}