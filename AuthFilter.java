package filters;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebFilter(urlPatterns = {
        "/dashboard.jsp",
        "/loan_fund.jsp",
        "/add_fund.jsp",
        "/loanApplication.jsp",
        "/repayment.jsp",
        "/registerMember.jsp",
        "/updateMember.jsp",
        "/contribution.jsp",
        "/statement.jsp",
        "/statementFilter.jsp",
        "/payoutSchedule.jsp",
        "/interestPool.jsp",
        "/groups.jsp",
        "/bankSetup.jsp",
        "/signatories.jsp",
        "/membersAndTotals.jsp",
        "/withdrawal.jsp",
        "/withdrawalForm.jsp",
        "/withdrawalsList.jsp",
        "/loanServlet",
        "/loanFundServlet",
        "/memberServlet",
        "/contributionServlet",
        "/statementServlet",
        "/payoutServlet",
        "/groups",
        "/bankSetup",
        "/signatories",
        "/parties",
        "/withdrawalServlet"
})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  request  = (HttpServletRequest)  req;
        HttpServletResponse response = (HttpServletResponse) res;

        HttpSession session = request.getSession(false);
        boolean loggedIn = (session != null && session.getAttribute("userId") != null);

        if (loggedIn) {
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            response.setHeader("Pragma", "no-cache");
            response.setDateHeader("Expires", 0);
            chain.doFilter(req, res);
        } else {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        }
    }
}