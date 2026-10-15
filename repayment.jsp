<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Repay Loan · Timaataba Susu</title>
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
        .card-header {
            margin-bottom: 24px; padding-bottom: 20px;
            border-bottom: 1px solid #eef2f6;
        }
        .card-header h2 {
            font-size: 1.5rem; font-weight: 600;
            color: #1e2b3c; margin-bottom: 8px;
            display: flex; align-items: center; gap: 10px;
        }
        .card-header .icon {
            display: inline-flex; align-items: center; justify-content: center;
            width: 38px; height: 38px; border-radius: 10px;
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff; font-size: 1.1rem;
        }
        .card-header .sub {
            color: #6c7a89; font-size: 0.9rem; line-height: 1.65;
        }
        .card-header .sub b {
            color: #1e8449; background: #e8f3ee;
            padding: 1px 8px; border-radius: 20px;
            font-size: 0.92em; font-weight: 600;
        }

        .group-filter {
            background: linear-gradient(135deg, #f0f9f4, #e6f4ec);
            border: 1px solid #cfeadd; border-radius: 12px;
            padding: 14px 18px; margin-bottom: 22px;
            display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
        }
        .group-filter label {
            font-size: 0.85rem; font-weight: 700;
            color: #1e8449; margin: 0;
        }
        .group-filter select {
            flex: 1; min-width: 200px;
            padding: 8px 12px;
            border: 1px solid #cfeadd; border-radius: 8px;
            font-size: 0.9rem; font-family: inherit;
            background: #fff; font-weight: 600;
            color: #1e2b37; cursor: pointer;
        }

        .msg {
            display: flex; align-items: flex-start; gap: 10px;
            padding: 12px 16px; border-radius: 10px;
            font-size: 0.88rem; line-height: 1.5; margin-bottom: 20px;
        }
        .msg::before { font-size: 1.05rem; line-height: 1; flex-shrink: 0; }
        .msg.error { background: #fdecea; color: #b71c1c; border: 1px solid #f5c6cb; }
        .msg.error::before { content: "⚠"; }
        .msg.success { background: #e8f3ee; color: #1e8449; border: 1px solid #cfeadd; }
        .msg.success::before { content: "✓"; }

        label {
            display: block; font-size: 0.85rem; font-weight: 600;
            color: #34495e; margin-bottom: 6px;
        }
        select {
            width: 100%; padding: 12px 40px 12px 14px;
            border: 1px solid #d7dfe7; border-radius: 10px;
            font-size: 0.95rem; font-family: inherit;
            color: #1e2b37; background: #fbfcfd;
            appearance: none; -webkit-appearance: none;
            background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'><path fill='%236c7a89' d='M6 8 0 0h12z'/></svg>");
            background-repeat: no-repeat;
            background-position: right 16px center;
            cursor: pointer;
        }
        select:focus {
            outline: none; border-color: #27ae60;
            background-color: #fff;
            box-shadow: 0 0 0 3px rgba(39,174,96,0.15);
        }

        .summary {
            margin-top: 20px; padding: 20px 22px;
            background: linear-gradient(135deg, #f8fafc, #f1f5f9);
            border: 1px solid #e6edf3; border-radius: 12px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 16px 24px;
        }
        .summary .item { display: flex; flex-direction: column; gap: 4px; }
        .summary .item .key {
            color: #6c7a89; text-transform: uppercase;
            letter-spacing: 0.06em; font-size: 0.7rem; font-weight: 700;
        }
        .summary .item .val {
            font-size: 1rem; font-weight: 700;
            color: #2c3e50; font-variant-numeric: tabular-nums;
        }
        .summary .item .val.phone    { color: #1f6390; }
        .summary .item .val.interest { color: #1e8449; }
        .summary .item .val.total    { color: #1e8449; font-size: 1.1rem; }
        .summary .item .val.due      { color: #b71c1c; }

        .btn-repay {
            width: 100%; margin-top: 24px;
            padding: 13px 20px;
            background: linear-gradient(135deg, #d32f2f, #b71c1c);
            color: #fff; border: none; border-radius: 10px;
            font-size: 0.98rem; font-weight: 600;
            cursor: pointer;
            box-shadow: 0 6px 16px -6px rgba(211,47,47,0.45);
        }
        .btn-repay:hover { background: linear-gradient(135deg, #b71c1c, #8c0018); }
        .btn-repay:active { transform: translateY(1px); }

        h3.section-heading {
            font-size: 1.05rem; font-weight: 600;
            color: #1e2b3c; margin: 32px 0 14px;
            display: flex; align-items: center; gap: 8px;
        }
        h3.section-heading::before {
            content: ""; width: 4px; height: 18px;
            background: linear-gradient(180deg, #27ae60, #1e8449);
            border-radius: 2px;
        }

        .table-wrap {
            overflow-x: auto; border-radius: 12px;
            border: 1px solid #e6edf3; background: #fff;
        }
        table {
            width: 100%; border-collapse: collapse;
            font-size: 0.88rem; min-width: 720px;
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
        td.id    { color: #6c7a89; font-weight: 600; }
        td.num   { text-align: right; font-variant-numeric: tabular-nums; white-space: nowrap; }
        td.principal { color: #2c3e50; font-weight: 600; }
        td.interest  { color: #1e8449; font-weight: 600; }
        td.total     { color: #1e8449; font-weight: 700; }
        td.due       { color: #b71c1c; font-weight: 600; white-space: nowrap; }

        .group-chip {
            display: inline-block;
            background: #e7f1ff; color: #1f6390;
            border: 1px solid #c9e3f7;
            padding: 2px 10px; border-radius: 999px;
            font-size: 0.72rem; font-weight: 700;
            white-space: nowrap;
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
            white-space: nowrap;
        }
        .btn-secondary {
            background: #fff; color: #2c3e50;
            border-color: #e6edf3;
        }
        .btn-secondary:hover { background: #f8fafc; border-color: #cfd9e3; }

        @media (max-width: 720px) {
            body { padding: 24px 14px; }
            .card { padding: 26px 22px; }
            .card-header h2 { font-size: 1.25rem; }
            .group-filter { flex-direction: column; align-items: stretch; }
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
        <a href="${pageContext.request.contextPath}/loanServlet?operation=viewFund"
           class="back-link">
            ← Back to Loan Fund
        </a>
    </div>

    <div class="card">

        <div class="card-header">
            <h2>
                <span class="icon">💵</span>
                Repay a Loan
            </h2>
            <p class="sub">
                Select an outstanding loan to repay. On repayment, the
                <b>principal</b> returns to the loan fund, and the
                <b>interest</b> is added to the pool that will be distributed
                at payout.
            </p>
        </div>

        <!-- ============ GROUP FILTER ============ -->
        <form method="get"
              action="<%= request.getContextPath() %>/loanServlet"
              class="group-filter">
            <input type="hidden" name="operation" value="repayForm" />

            <label for="groupId">🏘️ Group</label>
            <select id="groupId" name="groupId" onchange="this.form.submit()">
                <c:forEach var="g" items="${groups}">
                    <option value="${g.id}"
                        ${g.id == selectedGroupId ? 'selected' : ''}>
                        ${g.groupName}<c:if test="${not empty g.location}"> · ${g.location}</c:if>
                    </option>
                </c:forEach>
            </select>
        </form>

        <c:if test="${not empty param.message}">
            <div class="msg error"><c:out value="${param.message}"/></div>
        </c:if>
        <c:if test="${not empty param.success}">
            <div class="msg success"><c:out value="${param.success}"/></div>
        </c:if>

        <c:choose>
            <c:when test="${empty outstandingLoans}">
                <div class="empty">
                    <span class="icon-big">✅</span>
                    <h3>No outstanding loans</h3>
                    <p>All loans have been repaid, or none have been issued yet for this group.</p>
                </div>
            </c:when>

            <c:otherwise>
                <form action="${pageContext.request.contextPath}/loanServlet"
                      method="post"
                      onsubmit="return confirm('Confirm repayment of the selected loan?');">
                    <input type="hidden" name="operation" value="repay" />

                    <label for="loanId">Outstanding Loan</label>
                    <select name="loanId" id="loanId" required onchange="updatePreview()">
                        <option value="">— Select a loan —</option>
                        <c:forEach var="l" items="${outstandingLoans}">
                            <option value="${l.id}"
                                    data-phone="${l.phoneNumber}"
                                    data-principal="${l.principal}"
                                    data-interest="${l.interestAmount}"
                                    data-total="${l.totalOwed}"
                                    data-due="${l.dueDatePretty}">
                                #${l.id} — <c:out value="${l.phoneNumber}"/> —
                                GHS <fmt:formatNumber value="${l.totalOwed}"
                                                       minFractionDigits="2"
                                                       maxFractionDigits="2"/>
                                (due ${l.dueDatePretty})
                            </option>
                        </c:forEach>
                    </select>

                    <div class="summary" id="preview" style="display:none;">
                        <div class="item">
                            <span class="key">Phone</span>
                            <span class="val phone" id="pPhone">—</span>
                        </div>
                        <div class="item">
                            <span class="key">Principal</span>
                            <span class="val" id="pPrincipal">—</span>
                        </div>
                        <div class="item">
                            <span class="key">Interest</span>
                            <span class="val interest" id="pInterest">—</span>
                        </div>
                        <div class="item">
                            <span class="key">Total to Pay</span>
                            <span class="val total" id="pTotal">—</span>
                        </div>
                        <div class="item">
                            <span class="key">Due Date</span>
                            <span class="val due" id="pDue">—</span>
                        </div>
                    </div>

                    <button type="submit" class="btn-repay">Repay Loan</button>
                </form>
            </c:otherwise>
        </c:choose>

        <c:if test="${not empty outstandingLoans}">
            <h3 class="section-heading">All Outstanding Loans</h3>
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Group</th>
                            <th>Phone Number</th>
                            <th style="text-align:right">Principal</th>
                            <th style="text-align:right">Interest</th>
                            <th style="text-align:right">Total Owed</th>
                            <th>Due Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="l" items="${outstandingLoans}">
                            <tr>
                                <td class="id">#${l.id}</td>
                                <td><span class="group-chip">${l.groupName}</span></td>
                                <td><c:out value="${l.phoneNumber}"/></td>
                                <td class="num principal">
                                    <fmt:formatNumber value="${l.principal}"
                                                      minFractionDigits="2"
                                                      maxFractionDigits="2"/>
                                </td>
                                <td class="num interest">
                                    <fmt:formatNumber value="${l.interestAmount}"
                                                      minFractionDigits="2"
                                                      maxFractionDigits="2"/>
                                </td>
                                <td class="num total">
                                    <fmt:formatNumber value="${l.totalOwed}"
                                                      minFractionDigits="2"
                                                      maxFractionDigits="2"/>
                                </td>
                                <td class="due">${l.dueDatePretty}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>

        <div class="actions">
            <a class="btn btn-secondary"
               href="${pageContext.request.contextPath}/loanServlet?operation=viewFund">
                ← Back to Loan Fund
            </a>
        </div>

    </div>

</div>

<script>
    function updatePreview() {
        const sel = document.getElementById('loanId');
        const opt = sel.options[sel.selectedIndex];
        const preview = document.getElementById('preview');

        if (!opt || !opt.value) {
            preview.style.display = 'none';
            return;
        }

        const fmt = n => 'GHS ' + parseFloat(n).toFixed(2);

        document.getElementById('pPhone').textContent     = opt.dataset.phone;
        document.getElementById('pPrincipal').textContent = fmt(opt.dataset.principal);
        document.getElementById('pInterest').textContent  = fmt(opt.dataset.interest);
        document.getElementById('pTotal').textContent     = fmt(opt.dataset.total);
        document.getElementById('pDue').textContent       = opt.dataset.due;

        preview.style.display = 'grid';
    }
</script>

</body>
</html>