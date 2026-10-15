package servlet;

import dao.GroupDao;
import dao.PartiesDao;
import model.BankSetup;
import model.Signatory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/parties")
public class PartiesServlet extends HttpServlet {

    private final PartiesDao partiesDao = new PartiesDao();
    private final GroupDao   groupDao   = new GroupDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer gid = (Integer) req.getSession().getAttribute("currentGroupId");
        if (gid == null) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        try {
            BankSetup bank = partiesDao.getBank(gid);
            List<Signatory> sigs = partiesDao.getSignatories(gid);

            req.setAttribute("groupBank",   bank);
            req.setAttribute("signatories", sigs);
            req.setAttribute("groups",      groupDao.getAll());
            req.setAttribute("selectedGroupId", gid);

            req.getRequestDispatcher("parties.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Parties load error", e);
        }
    }
}