package servlet;

import util.database;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.JasperExportManager;
import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.export.HtmlExporter;
import net.sf.jasperreports.engine.export.ooxml.JRXlsxExporter;
import net.sf.jasperreports.export.SimpleExporterInput;
import net.sf.jasperreports.export.SimpleHtmlExporterOutput;
import net.sf.jasperreports.export.SimpleOutputStreamExporterOutput;
import net.sf.jasperreports.j2ee.servlets.ImageServlet;
import net.sf.jasperreports.web.util.WebHtmlResourceHandler;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.Connection;
import java.util.HashMap;
import java.util.Map;

/**
 * Servlet for the "Fund Composition" report.
 *
 * URL:    /fundComposition?groupId=123&format=pdf|html|xlsx|download
 * Input:  groupId from request (falls back to session's currentGroupId)
 * Output: PDF (default), HTML, or XLSX
 *
 * Report template (compiled .jasper) must be on the classpath at:
 *     reports/group_fund_composition.jasper
 */
@WebServlet("/fundComposition")
public class FundCompositionServlet extends HttpServlet {

    private static final String REPORT_PATH = "reports/group_fund_composition.jasper";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        /* 1. Resolve groupId */
        Integer gid = null;
        String gidParam = req.getParameter("groupId");

        if (gidParam != null && !gidParam.trim().isEmpty()) {
            try {
                gid = Integer.parseInt(gidParam.trim());
            } catch (NumberFormatException e) {
                resp.sendRedirect(req.getContextPath()
                        + "/fundCompositionFilter.jsp?error=InvalidGroupId");
                return;
            }
        } else {
            Object sessionGid = req.getSession().getAttribute("currentGroupId");
            if (sessionGid instanceof Integer) {
                gid = (Integer) sessionGid;
            }
        }

        if (gid == null) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        /* 2. Format */
        String format = req.getParameter("format");
        if (format == null || format.trim().isEmpty()) {
            format = "pdf";
        }
        format = format.trim().toLowerCase();
        boolean forceDownload = "download".equals(format);
        if (forceDownload) {
            format = "pdf";
        }

        /* 3. Load compiled report from classpath */
        InputStream jasperStream = getClass().getClassLoader()
                .getResourceAsStream(REPORT_PATH);
        if (jasperStream == null) {
            writeFriendlyError(resp, 500,
                    "Report template not found on classpath: " + REPORT_PATH,
                    "Expected at src/main/resources/reports/group_fund_composition.jasper "
                            + "and copied to WEB-INF/classes/reports/ on build.");
            return;
        }

        /* 4. Params */
        Map<String, Object> params = new HashMap<>();
        params.put("groupId", String.valueOf(gid));
        params.put("REPORT_LOCALE", java.util.Locale.US);

        /* 5. Fill and export */
        try (Connection con = database.getConnection();
             InputStream in  = jasperStream) {

            JasperPrint print = JasperFillManager.fillReport(in, params, con);

            if (print.getPages() == null || print.getPages().isEmpty()) {
                resp.sendRedirect(req.getContextPath()
                        + "/fundCompositionFilter.jsp?error=NoDataFound");
                return;
            }

            String baseName = "group_fund_composition_" + gid;
            String disposition = (forceDownload ? "attachment" : "inline");

            switch (format) {
                case "html" -> exportHtml(req, resp, print);

                case "xlsx" -> {
                    // Buffer first so a failure doesn't leave the response half-written.
                    ByteArrayOutputStream xlsxBuffer = new ByteArrayOutputStream();
                    JRXlsxExporter exporter = new JRXlsxExporter();
                    exporter.setExporterInput(new SimpleExporterInput(print));
                    exporter.setExporterOutput(
                            new SimpleOutputStreamExporterOutput(xlsxBuffer));
                    exporter.exportReport();

                    byte[] bytes = xlsxBuffer.toByteArray();
                    resp.setContentType(
                            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
                    resp.setHeader("Content-Disposition",
                            "attachment; filename=\"" + baseName + ".xlsx\"");
                    resp.setContentLength(bytes.length);
                    try (OutputStream out = resp.getOutputStream()) {
                        out.write(bytes);
                        out.flush();
                    }
                }

                default -> { /* pdf */
                    // Buffer the PDF first — prevents blank tabs when Jasper fails
                    // after the response has already started streaming.
                    ByteArrayOutputStream pdfBuffer = new ByteArrayOutputStream();
                    JasperExportManager.exportReportToPdfStream(print, pdfBuffer);
                    byte[] pdfBytes = pdfBuffer.toByteArray();

                    resp.setContentType("application/pdf");
                    resp.setHeader("Content-Disposition",
                            disposition + "; filename=\"" + baseName + ".pdf\"");
                    resp.setContentLength(pdfBytes.length);
                    try (OutputStream out = resp.getOutputStream()) {
                        out.write(pdfBytes);
                        out.flush();
                    }
                }
            }

        } catch (JRException | java.sql.SQLException e) {
            e.printStackTrace();
            writeFriendlyError(resp, 500,
                    "Report generation failed.",
                    stackTraceToString(e));
        } catch (Exception e) {
            e.printStackTrace();
            writeFriendlyError(resp, 500,
                    "Unexpected error while generating report.",
                    stackTraceToString(e));
        }
    }

    /* ------------------------------------------------------------------ */

    /**
     * Export to HTML using the built-in JasperReports ImageServlet for images
     * (e.g. the pie chart). The ImageServlet reads the JasperPrint from the
     * session attribute below.
     */
    private void exportHtml(HttpServletRequest req, HttpServletResponse resp,
                            JasperPrint print)
            throws IOException, JRException {

        // Store the print in the session so the built-in ImageServlet can
        // retrieve chart images from it.
        req.getSession().setAttribute(
                ImageServlet.DEFAULT_JASPER_PRINT_SESSION_ATTRIBUTE, print);

        resp.setContentType("text/html;charset=UTF-8");

        HtmlExporter exporter = new HtmlExporter();
        exporter.setExporterInput(new SimpleExporterInput(print));

        SimpleHtmlExporterOutput output = new SimpleHtmlExporterOutput(resp.getWriter());

        // {0} is replaced by Jasper with the image id.
        output.setImageHandler(new WebHtmlResourceHandler(
                req.getContextPath() + "/servlets/image?image={0}"));

        exporter.setExporterOutput(output);
        exporter.exportReport();
    }

    /** Render a simple, readable error page (so the tab isn't blank). */
    private static void writeFriendlyError(HttpServletResponse resp,
                                           int status,
                                           String headline,
                                           String detail) throws IOException {
        if (resp.isCommitted()) {
            return;
        }
        resp.reset();
        resp.setStatus(status);
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter w = resp.getWriter();
        w.println("<!DOCTYPE html><html><head><meta charset='UTF-8'>"
                + "<title>Report error</title>"
                + "<style>body{font-family:system-ui,Arial,sans-serif;"
                + "max-width:900px;margin:40px auto;padding:0 20px;color:#1e2b37;}"
                + "h1{color:#a93226;font-size:1.3rem;}"
                + "pre{background:#f8fafc;border:1px solid #e2e9f0;border-radius:10px;"
                + "padding:16px;overflow:auto;font-size:0.85rem;}</style></head><body>");
        w.println("<h1>⚠ " + escape(headline) + "</h1>");
        if (detail != null && !detail.isEmpty()) {
            w.println("<pre>" + escape(detail) + "</pre>");
        }
        w.println("<p><a href='javascript:history.back()'>← Go back</a></p>");
        w.println("</body></html>");
        w.flush();
    }

    private static String stackTraceToString(Throwable t) {
        StringWriter sw = new StringWriter();
        t.printStackTrace(new PrintWriter(sw));
        return sw.toString();
    }

    private static String escape(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
}