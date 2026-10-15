package servlet;

import dao.BankSetupDao;
import model.BankSetup;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

@WebServlet("/bankSetup")
public class BankSetupServlet extends HttpServlet {

    private final BankSetupDao dao = new BankSetupDao();

    private Integer currentGroup(HttpServletRequest req) {
        return (Integer) req.getSession().getAttribute("currentGroupId");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer gid = currentGroup(req);
        if (gid == null) { resp.sendRedirect(req.getContextPath() + "/index.jsp"); return; }

        try {
            req.setAttribute("setup", dao.load(gid));
            req.getRequestDispatcher("bankSetup.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Bank setup load error", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer gid = currentGroup(req);
        if (gid == null) { resp.sendRedirect(req.getContextPath() + "/index.jsp"); return; }

        try {
            BankSetup s = new BankSetup();
            s.setBankName(trim(req.getParameter("bankName")));
            s.setBankBranch(trim(req.getParameter("bankBranch")));
            s.setAccountName(trim(req.getParameter("accountName")));
            s.setAccountNumber(trim(req.getParameter("accountNumber")));
            s.setAccountType(trim(req.getParameter("accountType")));
            s.setFeeMaintenance(parseDecimal(req.getParameter("feeMaintenance")));
            s.setFeeService(parseDecimal(req.getParameter("feeService")));
            s.setFeeOther(parseDecimal(req.getParameter("feeOther")));

            dao.save(gid, s);
            resp.sendRedirect(req.getContextPath() + "/bankSetup?saved=1");
        } catch (SQLException e) {
            throw new ServletException("Bank setup save error", e);
        }
    }

    private static String trim(String s) { return s == null ? "" : s.trim(); }

    private static BigDecimal parseDecimal(String s) {
        if (s == null || s.isBlank()) return BigDecimal.ZERO;
        try { return new BigDecimal(s.trim()); }
        catch (NumberFormatException e) { return BigDecimal.ZERO; }
    }
}