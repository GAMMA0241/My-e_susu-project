<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Members & Totals · Timaataba Susu</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            background: linear-gradient(160deg, #f4f6f9 0%, #eaeef4 100%);
            color: #1e2b37; line-height: 1.55;
            min-height: 100vh; padding: 40px 20px;
        }
        .container { max-width: 1000px; margin: 0 auto; }
        .topnav {
            display: flex; align-items: center; justify-content: space-between;
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
        .card-header {
            margin-bottom: 24px; padding-bottom: 20px;
            border-bottom: 1px solid #eef2f6;
        }
        .card-header h2 {
            font-size: 1.5rem; font-weight: 600;
            color: #1e2b3c; display: flex; align-items: center; gap: 10px;
        }
        .card-header .icon {
            display: inline-flex; align-items: center; justify-content: center;
            width: 38px; height: 38px; border-radius: 10px;
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff; font-size: 1.1rem;
        }
        .group-block {
            margin-bottom: 28px;
            border: 1px solid #e6edf3;
            border-radius: 14px;
            overflow: hidden;
            background: #fff;
        }
        .group-block .group-header {
            background: linear-gradient(135deg, #f0f9f4, #e6f4ec);
            padding: 14px 20px;
            border-bottom: 1px solid #cfeadd;
            display: flex; justify-content: space-between; align-items: center;
            flex-wrap: wrap; gap: 10px;
        }
        .group-block .group-header .title {
            font-weight: 700; font-size: 1rem; color: #1e8449;
        }
        .group-block .group-header .meta {
            font-size: 0.8rem; color: #1e8449; opacity: 0.8;
        }
        table { width: 100%; border-collapse: collapse; }
        thead th {
            background: #f8fafc;
            text-align: left;
            font-size: 0.7rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.06em;
            color: #475569;
            padding: 12px 16px;
            border-bottom: 1px solid #eef2f6;
            white-space: nowrap;
        }
        tbody td {
            padding: 12px 16px;
            font-size: 0.88rem;
            border-bottom: 1px solid #eef2f6;
            color: #2c3e50;
        }
        tbody tr:last-child td { border-bottom: none; }
        tbody tr:hover { background: #f9fbfd; }
        td.num { text-align: right; font-variant-numeric: tabular-nums; font-weight: 600; }
        td.total { color: #1e8449; font-weight: 700; }
        tfoot td {
            padding: 12px 16px;
            background: #f8fafc;
            font-weight: 700;
            border-top: 2px solid #cfeadd;
            color: #1e8449;
            font-variant-numeric: tabular-nums;
        }
        tfoot td.label {
            text-align: right; font-size: 0.75rem;
            text-transform: uppercase; letter-spacing: 0.08em;
        }
        .grand-total-box {
            margin-top: 24px; padding: 20px 24px;
            background: linear-gradient(135deg, #1e8449, #196b39);
            color: #fff; border-radius: 14px;
            display: flex; justify-content: space-between; align-items: center;
            flex-wrap: wrap; gap: 10px;
        }
        .grand-total-box .label {
            font-size: 0.85rem; font-weight: 600; opacity: 0.9;
            text-transform: uppercase; letter-spacing: 0.08em;
        }
        .grand-total-box .value {
            font-size: 1.8rem; font-weight: 700;
            font-variant-numeric: tabular-nums;
        }
        .empty-row {
            padding: 24px; text-align: center;
            color: #6c7a89; font-size: 0.88rem;
            background: #fbfcfd;
        }
        @media (max-width: 640px) {
            body { padding: 24px 14px; }
            .card { padding: 26px 20px; }
            .card-header h2 { font-size: 1.25rem; }
            thead th, tbody td, tfoot td { padding: 10px 12px; font-size: 0.82rem; }
        }
    </style>
</head>
<body>

<div class="container">

    <div class="topnav">
        <a href="<%= request.getContextPath() %>/dashboard.jsp" class="back-link">
            🏠 Back to Dashboard
        </a>
        <a href="<%= request.getContextPath() %>/contributionServlet" class="back-link">
            ← Record Contribution
        </a>
    </div>

    <div class="card">

        <div class="card-header">
            <h2>
                <span class="icon">📊</span>
                Members &amp; Total Contributions
            </h2>
        </div>

        <c:forEach var="entry" items="${membersByGroup}">
            <c:set var="gid"     value="${entry.key}" />
            <c:set var="members" value="${entry.value}" />

            <c:forEach var="g" items="${groups}">
                <c:if test="${g.id == gid}">
                    <div class="group-block">

                        <div class="group-header">
                            <div class="title">🏘️ ${g.groupName}</div>
                            <div class="meta">
                                <c:if test="${not empty g.location}">${g.location} · </c:if>
                                ${members.size()} member<c:if test="${members.size() != 1}">s</c:if>
                            </div>
                        </div>

                        <table>
                            <thead>
                                <tr>
                                    <th style="width:44px">#</th>
                                    <th>Full Name</th>
                                    <th>Phone</th>
                                    <th style="text-align:right">Total Contribution (GHS)</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty members}">
                                        <tr>
                                            <td colspan="4" class="empty-row">
                                                No members in this group yet.
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="groupTotal" value="0" />
                                        <c:forEach var="m" items="${members}" varStatus="loop">
                                            <tr>
                                                <td>${loop.count}</td>
                                                <td>${m.fullName}</td>
                                                <td>${m.phoneNumber}</td>
                                                <td class="num total">
                                                    <fmt:formatNumber value="${m.total}"
                                                                      type="number"
                                                                      minFractionDigits="2"
                                                                      maxFractionDigits="2"/>
                                                </td>
                                            </tr>
                                            <c:set var="groupTotal" value="${groupTotal + m.total}" />
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                            <c:if test="${not empty members}">
                                <tfoot>
                                    <tr>
                                        <td colspan="3" class="label">Group Total</td>
                                        <td class="num">
                                            GHS <fmt:formatNumber value="${groupTotal}"
                                                                  type="number"
                                                                  minFractionDigits="2"
                                                                  maxFractionDigits="2"/>
                                        </td>
                                    </tr>
                                </tfoot>
                            </c:if>
                        </table>

                    </div>
                </c:if>
            </c:forEach>
        </c:forEach>

        <c:if test="${empty membersByGroup}">
            <p style="text-align:center; color:#6c7a89; padding:40px;">
                No groups defined yet.
            </p>
        </c:if>

        <c:if test="${not empty membersByGroup}">
            <div class="grand-total-box">
                <span class="label">Grand Total (All Groups)</span>
                <span class="value">
                    GHS <fmt:formatNumber value="${grandTotal}"
                                          type="number"
                                          minFractionDigits="2"
                                          maxFractionDigits="2"/>
                </span>
            </div>
        </c:if>

    </div>

</div>

</body>
</html>