<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Statement · Timaataba Susu</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            background: linear-gradient(160deg, #f4f6f9 0%, #eaeef4 100%);
            color: #1e2b37; line-height: 1.55;
            min-height: 100vh; padding: 40px 20px;
        }
        .container { max-width: 960px; margin: 0 auto; }
        .topnav {
            display: flex; justify-content: space-between;
            margin-bottom: 20px; flex-wrap: wrap; gap: 10px;
        }
        .back-link {
            display: inline-flex; align-items: center; gap: 6px;
            color: #1e8449; text-decoration: none; font-size: 0.88rem;
            font-weight: 500; padding: 8px 14px; border-radius: 8px;
            background: #f0f9f4; border: 1px solid #cfeadd;
        }
        .back-link:hover { background: #e6f4ec; }
        .card {
            background: #fff; border-radius: 18px; padding: 38px 40px 34px;
            box-shadow: 0 16px 40px -20px rgba(0,30,40,0.18);
            border: 1px solid rgba(255,255,255,0.7);
        }
        .page-header {
            display: flex; flex-wrap: wrap; align-items: center;
            gap: 12px; margin-bottom: 10px;
        }
        .page-header h2 {
            font-size: 1.5rem; font-weight: 600;
            color: #1e2b3c; display: flex; align-items: center; gap: 10px;
        }
        .page-header h2 .icon {
            display: inline-flex; align-items: center; justify-content: center;
            width: 38px; height: 38px; border-radius: 10px;
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff; font-size: 1.1rem;
        }
        .badge {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 5px 12px; border-radius: 999px;
            background: #e8f3ee; color: #1e8449;
            border: 1px solid #cfeadd;
            font-size: 0.82rem; font-weight: 600;
        }
        .badge-group {
            background: #e7f1ff; color: #1f6390;
            border-color: #c9e3f7;
        }
        .meta {
            color: #6c7a89; font-size: 0.9rem;
            margin-bottom: 24px; padding-bottom: 20px;
            border-bottom: 1px solid #eef2f6;
        }
        .meta strong {
            color: #1e2b3c; font-weight: 600;
            background: #f1f5f9; padding: 2px 8px; border-radius: 6px;
        }
        .error {
            background: #fdecea; color: #b71c1c;
            border: 1px solid #f5c6cb; border-radius: 10px;
            padding: 12px 16px; font-size: 0.88rem;
            margin-bottom: 20px;
        }
        .error::before { content: "⚠ "; }
        .table-wrap {
            overflow-x: auto; border-radius: 12px;
            border: 1px solid #e6edf3; background: #fff;
        }
        table {
            width: 100%; border-collapse: collapse;
            font-size: 0.88rem; min-width: 620px;
        }
        thead th {
            background: #f8fafc; text-align: left;
            font-weight: 700; color: #475569;
            font-size: 0.7rem; text-transform: uppercase;
            letter-spacing: 0.06em;
            padding: 14px 16px;
            border-bottom: 1px solid #e6edf3;
            white-space: nowrap;
        }
        tbody td {
            padding: 14px 16px;
            border-bottom: 1px solid #eef2f6;
            color: #2c3e50;
        }
        tbody tr:last-child td { border-bottom: none; }
        tbody tr:hover { background: #f9fbfd; }
        td.idx { color: #6c7a89; font-weight: 600; width: 56px; }
        .amount {
            font-variant-numeric: tabular-nums;
            font-weight: 600; text-align: right;
            white-space: nowrap;
        }
        .group-chip {
            display: inline-block;
            background: #e7f1ff; color: #1f6390;
            border: 1px solid #c9e3f7;
            padding: 2px 10px; border-radius: 999px;
            font-size: 0.75rem; font-weight: 600;
        }
        tfoot td {
            padding: 16px; font-weight: 700;
            background: linear-gradient(135deg, #f8fafc, #f1f5f9);
            border-top: 2px solid #cfeadd;
            font-variant-numeric: tabular-nums;
        }
        tfoot td.total-label {
            text-align: right; color: #6c7a89;
            font-size: 0.75rem; text-transform: uppercase;
            letter-spacing: 0.08em;
        }
        tfoot td.total-value {
            color: #1e8449; font-size: 1.05rem;
            white-space: nowrap; text-align: right;
        }
        .empty {
            text-align: center; padding: 48px 24px;
            background: linear-gradient(135deg, #f8fafc, #f1f5f9);
            border: 1px dashed #cfd9e3;
            border-radius: 12px; color: #6c7a89;
        }
        .empty .icon-big {
            display: block; font-size: 2.5rem;
            margin-bottom: 12px; opacity: 0.7;
        }
        .empty h3 {
            font-size: 1.05rem; color: #2c3e50;
            margin-bottom: 6px; font-weight: 600;
        }
        .actions {
            display: flex; gap: 12px; flex-wrap: wrap;
            margin-top: 24px; padding-top: 22px;
            border-top: 1px solid #eef2f6;
        }
        .btn {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 11px 20px; border-radius: 10px;
            font-size: 0.9rem; font-weight: 600;
            text-decoration: none; cursor: pointer;
            border: 1px solid transparent;
            transition: transform 0.1s, background 0.2s, box-shadow 0.2s;
            white-space: nowrap;
        }
        .btn-primary {
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff;
            box-shadow: 0 6px 16px -6px rgba(39,174,96,0.5);
        }
        .btn-primary:hover { background: linear-gradient(135deg, #219150, #196b39); }
        .btn-secondary {
            background: #fff; color: #2c3e50;
            border-color: #e6edf3;
        }
        .btn-secondary:hover { background: #f8fafc; border-color: #cfd9e3; }
        @media print {
            body { background: #fff; padding: 0; }
            .topnav, .actions { display: none !important; }
            .card { box-shadow: none; border: none; padding: 0; border-radius: 0; }
            thead th { background: #f2f2f2 !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            tfoot td { background: #f2f2f2 !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
        }
        @media (max-width: 720px) {
            body { padding: 24px 14px; }
            .card { padding: 26px 22px; }
            .page-header h2 { font-size: 1.25rem; }
            .actions { flex-direction: column; }
            .actions .btn { justify-content: center; width: 100%; }
        }
    </style>
</head>
<body>

<div class="container">

    <div class="topnav">
        <a href="<%= request.getContextPath() %>/dashboard.jsp" class="back-link">
            🏠 Back to Dashboard
        </a>
        <a href="${pageContext.request.contextPath}/statementServlet?operation=filter"
           class="back-link">
            ← New Search
        </a>
    </div>

    <div class="card">

        <div class="page-header">
            <h2>
                <span class="icon">📄</span>
                Statement
            </h2>
            <span class="badge">${phoneNumber}</span>

            <c:choose>
                <c:when test="${not empty selectedGroupId}">
                    <c:forEach var="entry" items="${memberGroups}">
                        <c:if test="${entry.key == selectedGroupId}">
                            <span class="badge badge-group">🏘️ ${entry.value}</span>
                        </c:if>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <span class="badge badge-group">🏘️ All Groups</span>
                </c:otherwise>
            </c:choose>
        </div>

        <p class="meta">
            <c:choose>
                <c:when test="${not empty fromDate and not empty toDate}">
                    Period: <strong>${fromDate}</strong> to <strong>${toDate}</strong>
                </c:when>
                <c:when test="${not empty fromDate}">
                    Period: from <strong>${fromDate}</strong>
                </c:when>
                <c:when test="${not empty toDate}">
                    Period: up to <strong>${toDate}</strong>
                </c:when>
                <c:otherwise>
                    Period: <strong>all time</strong>
                </c:otherwise>
            </c:choose>
        </p>

        <c:if test="${not empty error}">
            <div class="error">${error}</div>
        </c:if>

        <c:choose>
            <c:when test="${not empty rows}">
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th style="width:56px">#</th>
                                <th>Phone Number</th>
                                <th>Group</th>
                                <th style="text-align:right">Amount</th>
                                <th>Paid On</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="row" items="${rows}" varStatus="loop">
                                <tr>
                                    <td class="idx">${loop.count}</td>
                                    <td><c:out value="${row.phoneNumber}"/></td>
                                    <td>
                                        <span class="group-chip">
                                            <c:out value="${row.groupName}"/>
                                        </span>
                                    </td>
                                    <td class="amount">
                                        <fmt:formatNumber value="${row.amount}"
                                                          type="number"
                                                          minFractionDigits="2"
                                                          maxFractionDigits="2"/>
                                    </td>
                                    <td>${row.paidOn}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                        <tfoot>
                            <tr>
                                <td colspan="3" class="total-label">Total</td>
                                <td class="total-value">
                                    <fmt:formatNumber value="${total}"
                                                      type="number"
                                                      minFractionDigits="2"
                                                      maxFractionDigits="2"/>
                                </td>
                                <td></td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty">
                    <span class="icon-big">🔍</span>
                    <h3>No contributions found</h3>
                    <p>Try adjusting the phone number, group, or date range.</p>
                </div>
            </c:otherwise>
        </c:choose>

        <div class="actions">
            <a class="btn btn-secondary"
               href="${pageContext.request.contextPath}/statementServlet?operation=filter">
                ← New Search
            </a>
            <c:if test="${not empty rows}">
                <a class="btn btn-primary" href="javascript:window.print()">
                    🖨 Print Statement
                </a>
            </c:if>
        </div>

    </div>

</div>

</body>
</html>