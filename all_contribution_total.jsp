<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title>Members &amp; Total Contributions</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, sans-serif; background: #f4f6f9; padding: 40px; }
        .box { max-width: 950px; margin: auto; background: white; padding: 30px;
               border-radius: 8px; box-shadow: 0 2px 6px rgba(0,0,0,0.1); }
        h2 { color: #2c3e50; margin-bottom: 8px; }
        .sub { color: #7f8c8d; font-size: 14px; margin-bottom: 20px; }
        .back { display: inline-block; margin-bottom: 20px; color: #2c3e50;
                text-decoration: none; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 11px 14px; text-align: left;
                 border-bottom: 1px solid #e0e6ed; font-size: 14px; }
        th { background: #2c3e50; color: white; font-size: 12px;
             text-transform: uppercase; letter-spacing: 0.5px; }
        tr:hover { background: #f9fbfd; }
        .amount { color: #27ae60; font-weight: bold; }
        .empty { text-align: center; color: #95a5a6; padding: 25px; }
        tfoot td { background: #ecf0f1; font-weight: bold; color: #2c3e50;
                   border-top: 2px solid #2c3e50; }
        .actions { margin-top: 25px; display: flex; gap: 12px; flex-wrap: wrap; }
        .actions a, .actions button { padding: 10px 18px; border-radius: 5px;
            text-decoration: none; font-size: 14px; cursor: pointer; border: none; }
        .btn-back  { background: #2c3e50; color: white; }
        .btn-print { background: #27ae60; color: white; }
        @media print { .back, .actions { display: none; } body { background: white; padding: 0; }
                       .box { box-shadow: none; } }
    </style>
</head>
<body>
<div class="box">
    <a href="dashboard.jsp" class="back">← Back to Dashboard</a>
    <h2>Members &amp; Total Contributions</h2>
    <p class="sub">Total amount contributed by each member across all time.</p>

    <table>
        <thead>
            <tr>
                <th>Member Name</th>
                <th>Phone Number</th>
                <th>Total Contribution (GHS)</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="r" items="${list}">
                <tr>
                    <td>${r.memberName}</td>
                    <td>${r.phoneNumber}</td>
                    <td class="amount">
                        <fmt:formatNumber value="${r.total}" type="number"
                                          minFractionDigits="2" maxFractionDigits="2"/>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty list}">
                <tr><td colspan="3" class="empty">No contributions recorded yet.</td></tr>
            </c:if>
        </tbody>
        <c:if test="${not empty list}">
            <tfoot>
                <tr>
                    <td colspan="2">Grand Total</td>
                    <td class="amount">
                        <c:set var="grand" value="0"/>
                        <c:forEach var="r" items="${list}">
                            <c:set var="grand" value="${grand + r.total}"/>
                        </c:forEach>
                        <fmt:formatNumber value="${grand}" type="number"
                                          minFractionDigits="2" maxFractionDigits="2"/>
                    </td>
                </tr>
            </tfoot>
        </c:if>
    </table>

    <div class="actions">
        <a href="index.jsp" class="btn-back">Back to Dashboard</a>
        <button class="btn-print" onclick="window.print()">Print / Save PDF</button>
    </div>
</div>
</body>
</html>