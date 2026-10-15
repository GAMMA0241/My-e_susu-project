package servlet;

import dao.StatementDao;
import model.statement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;

@WebServlet("/statementServlet")
public class StatementServlet extends HttpServlet {

    private final StatementDao statementDao = new StatementDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String operation = request.getParameter("operation");
        if (operation == null) operation = "";

        switch (operation) {

            case "loadGroups":
                handleLoadGroups(request, response);
                break;

            case "generate":
                handleGenerate(request, response);
                break;

            case "filter":
            default:
                request.getRequestDispatcher("filter.jsp")
                        .forward(request, response);
        }
    }

    /* *  LOAD GROUPS — user typed a phone, show matching groups * */

    private void handleLoadGroups(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String phoneNumber = trimOrNull(request.getParameter("phoneNumber"));

        if (phoneNumber == null) {
            request.setAttribute("error", "Phone number is required.");
            request.getRequestDispatcher("filter.jsp").forward(request, response);
            return;
        }

        try {
            Map<Integer, String> groups = statementDao.getGroupsForPhone(phoneNumber);

            if (groups.isEmpty()) {request.setAttribute("error",
                        "No member found with phone number " + phoneNumber + ".");
                request.setAttribute("phoneNumber", phoneNumber);
                request.getRequestDispatcher("filter.jsp").forward(request, response);
                return;
            }

            request.setAttribute("phoneNumber", phoneNumber);
            request.setAttribute("memberGroups", groups);
            request.getRequestDispatcher("filter.jsp").forward(request, response);

        } catch (SQLException e) {
            log("Load groups failed for phone=" + phoneNumber, e);
            request.setAttribute("error", "Could not load groups. Please try again.");
            request.getRequestDispatcher("filter.jsp").forward(request, response);
        }
    }

    /* *  GENERATE — filter contributions and show the statement * */

    private void handleGenerate(HttpServletRequest request,
                                HttpServletResponse response)
            throws ServletException, IOException {

        String phoneNumber = trimOrNull(request.getParameter("phoneNumber"));
        String fromDateRaw = trimOrNull(request.getParameter("fromDate"));
        String toDateRaw   = trimOrNull(request.getParameter("toDate"));
        String groupIdRaw  = trimOrNull(request.getParameter("groupId"));

        if (phoneNumber == null) {
            request.setAttribute("error", "Phone number is required.");
            request.getRequestDispatcher("filter.jsp").forward(request, response);
            return;
        }

        // Parse dates
        LocalDate fromDate;
        LocalDate toDate;
        try {
            fromDate = parseDateOrNull(fromDateRaw);
            toDate   = parseDateOrNull(toDateRaw);
        } catch (DateTimeParseException e) {
            request.setAttribute("error",
                    "Invalid date format. Please use YYYY-MM-DD.");
            request.setAttribute("phoneNumber", phoneNumber);
            request.setAttribute("fromDate", fromDateRaw);
            request.setAttribute("toDate", toDateRaw);
            request.setAttribute("selectedGroupId", groupIdRaw);
            safeLoadGroups(request, phoneNumber);
            request.getRequestDispatcher("filter.jsp").forward(request, response);
            return;
        }

        if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
            request.setAttribute("error", "'From' date cannot be after 'To' date.");
            request.setAttribute("phoneNumber", phoneNumber);
            request.setAttribute("fromDate", fromDateRaw);
            request.setAttribute("toDate", toDateRaw);
            request.setAttribute("selectedGroupId", groupIdRaw);
            safeLoadGroups(request, phoneNumber);
            request.getRequestDispatcher("filter.jsp").forward(request, response);
            return;
        }

        // Parse group choice — null means "all groups"
        Integer groupId = null;
        if (groupIdRaw != null) {
            try { groupId = Integer.parseInt(groupIdRaw); }
            catch (NumberFormatException ignored) { /* treat as all */ }
        }

        try {
            List<statement> rows = statementDao.getStatement(
                    phoneNumber, groupId, fromDate, toDate);

            BigDecimal total = BigDecimal.ZERO;
            for (statement s : rows) {
                if (s.getAmount() != null) total = total.add(s.getAmount());
            }

            request.setAttribute("rows",         rows);
            request.setAttribute("total",        total);
            request.setAttribute("phoneNumber",  phoneNumber);
            request.setAttribute("fromDate",     fromDate);
            request.setAttribute("toDate",       toDate);
            request.setAttribute("selectedGroupId", groupId);
            request.setAttribute("memberGroups", statementDao.getGroupsForPhone(phoneNumber));

            request.getRequestDispatcher("statement.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            log("Statement query failed for phone=" + phoneNumber, e);
            request.setAttribute("error", "Could not load statement. Please try again.");
            request.setAttribute("phoneNumber", phoneNumber);
            safeLoadGroups(request, phoneNumber);
            request.getRequestDispatcher("filter.jsp").forward(request, response);
        }
    }

    /*  *  HELPERS * */

    private void safeLoadGroups(HttpServletRequest request, String phoneNumber) {
        try {
            request.setAttribute("memberGroups",
                    statementDao.getGroupsForPhone(phoneNumber));
        } catch (SQLException ignored) { }
    }

    private String trimOrNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private LocalDate parseDateOrNull(String raw) {
        if (raw == null) return null;
        return LocalDate.parse(raw);
    }
}