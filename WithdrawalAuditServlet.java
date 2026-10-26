package servlet;

import util.database;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import net.sf.jasperreports.engine.*;
import net.sf.jasperreports.engine.export.HtmlExporter;
import net.sf.jasperreports.export.SimpleExporterInput;
import net.sf.jasperreports.export.SimpleHtmlExporterOutput;

import java.io.*;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.Date;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/withdrawalAudit")
public class WithdrawalAuditServlet extends HttpServlet {

    private Integer currentGroup(HttpServletRequest req) {
        return (Integer) req.getSession().getAttribute("currentGroupId");
    }

    private String currentUser(HttpServletRequest req) {
        Object u = req.getSession().getAttribute("username");
        return u == null ? "system" : u.toString();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer gid = currentGroup(req);
        if (gid == null) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        /* Read form inputs */
        String fromStr = trim(req.getParameter("fromDate"));
        String toStr   = trim(req.getParameter("toDate"));
        String status  = trim(req.getParameter("status"));
        String format  = trim(req.getParameter("format"));
        if (format.isEmpty()) format = "pdf";

        /*  Validate  */
        Date fromDate = null, toDate = null;
        try {
            if (!fromStr.isEmpty()) fromDate = Date.valueOf(fromStr);
            if (!toStr.isEmpty())   toDate   = Date.valueOf(toStr);
        } catch (IllegalArgumentException e) {
            redirect(req, resp, "InvalidDateRange", fromStr, toStr, status, format);
            return;
        }
        if (fromDate != null && toDate != null && fromDate.after(toDate)) {
            redirect(req, resp, "InvalidDateRange", fromStr, toStr, status, format);
            return;
        }

        /*  Load .jasper  */
        InputStream jasperStream = getClass().getClassLoader()
                .getResourceAsStream("reports/withdrawal_statement.jasper");
        if (jasperStream == null) {
            throw new ServletException(
                    "Report template not found: reports/withdrawal_statement.jasper. "
                            + "Compile withdrawal_statement.jrxml in Jaspersoft Studio and copy "
                            + "the .jasper into src/main/resources/reports/.");
        }

        /*  Bind parameters  */
        Map<String, Object> params = new HashMap<>();
        params.put("groupId",  gid);
        params.put("fromDate", fromDate);
        params.put("toDate",   toDate);
        params.put("status",   status.isEmpty() ? null : status);

        /*  Fill and export  */
        try (Connection con = database.getConnection();
             InputStream in = jasperStream) {

            JasperPrint print = JasperFillManager.fillReport(in, params, con);

            if ("html".equalsIgnoreCase(format)) {
                exportHtml(print, resp);
            } else {
                exportPdf(print, resp);
            }

        } catch (JRException | java.sql.SQLException e) {
            throw new ServletException("Report generation failed: " + e.getMessage(), e);
        }
    }

    private void exportPdf(JasperPrint print, HttpServletResponse resp)
            throws IOException, JRException {
        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition",
                "inline; filename=\"withdrawal_audit.pdf\"");
        try (OutputStream out = resp.getOutputStream()) {
            JasperExportManager.exportReportToPdfStream(print, out);
            out.flush();
        }
    }

    private void exportHtml(JasperPrint print, HttpServletResponse resp)
            throws IOException, JRException {
        resp.setContentType("text/html;charset=UTF-8");
        HtmlExporter exporter = new HtmlExporter();
        exporter.setExporterInput(new SimpleExporterInput(print));
        exporter.setExporterOutput(new SimpleHtmlExporterOutput(resp.getWriter()));
        exporter.exportReport();
    }

    private void redirect(HttpServletRequest req, HttpServletResponse resp,
                          String error, String from, String to, String status,
                          String format) throws IOException {
        StringBuilder url = new StringBuilder(req.getContextPath())
                .append("/withdrawalAuditFilter.jsp")
                .append("?error=").append(encode(error));
        if (!from.isEmpty())   url.append("&fromDate=").append(encode(from));
        if (!to.isEmpty())     url.append("&toDate=").append(encode(to));
        if (!status.isEmpty()) url.append("&status=").append(encode(status));
        if (!format.isEmpty()) url.append("&format=").append(encode(format));
        resp.sendRedirect(url.toString());
    }

    private static String trim(String s) { return s == null ? "" : s.trim(); }
    private static String encode(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}