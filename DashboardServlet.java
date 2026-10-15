package servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String operation = request.getParameter("operation");

        if (operation == null || operation.isEmpty()) {
            response.sendRedirect("index.jsp");
            return;
        }

        switch (operation) {
            //case "viewMembersAndTotal":
                //request.getRequestDispatcher("all_contribution_total.jsp").forward(request, response);
              //  break;

           // case "StatementServlet":
                // Forward to your StatementServlet
            //    request.getRequestDispatcher("StatementServlet").forward(request, response);
               // break;

            case "schedulePayout":
                request.getRequestDispatcher("schedulePayout.jsp").forward(request, response);
                break;

            case "viewPayouts":
                request.getRequestDispatcher("viewPayouts.jsp").forward(request, response);
                break;

            default:
                response.sendRedirect("dashboard.jsp");
        }
    }
}
