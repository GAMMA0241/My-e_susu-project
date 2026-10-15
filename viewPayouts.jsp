<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payout Schedule · Timaataba Susu</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            background: linear-gradient(160deg, #f4f6f9 0%, #eaeef4 100%);
            color: #1e2b37; line-height: 1.55;
            min-height: 100vh; padding: 40px 20px;
        }
        .container { max-width: 1180px; margin: 0 auto; }

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
            font-size: 1.5rem; font-weight: 600; color: #1e2b3c;
            margin-bottom: 8px; display: flex; align-items: center; gap: 10px;
        }
        .card-header .icon {
            display: inline-flex; align-items: center; justify-content: center;
            width: 38px; height: 38px; border-radius: 10px;
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff; font-size: 1.1rem;
        }
        .card-header .sub {
            color: #6c7a89; font-size: 0.9rem; line-height: 1.65;
            max-width: 960px;
        }
        .card-header .sub b {
            color: #1e8449; background: #e8f3ee;
            padding: 1px 8px; border-radius: 20px;
            font-size: 0.92em; font-weight: 600;
        }

        /* ---------- GROUP FILTER BAR ---------- */
        .group-filter {
            background: linear-gradient(135deg, #f0f9f4, #e6f4ec);
            border: 1px solid #cfeadd;
            border-radius: 12px;
            padding: 14px 18px;
            margin-bottom: 22px;
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }
        .group-filter label {
            font-size: 0.85rem; font-weight: 700;
            color: #1e8449;
            margin: 0;
        }
        .group-filter select {
            flex: 1;
            min-width: 200px;
            padding: 8px 12px;
            border: 1px solid #cfeadd;
            border-radius: 8px;
            font-size: 0.9rem;
            font-family: inherit;
            background: #fff;
            font-weight: 600;
            color: #1e2b37;
            cursor: pointer;
        }
        .group-filter select:focus {
            outline: none;
            border-color: #27ae60;
            box-shadow: 0 0 0 3px rgba(39,174,96,0.15);
        }

        .msg {
            display: flex; align-items: flex-start; gap: 10px;
            background: #e8f3ee; color: #1e8449;
            border: 1px solid #cfeadd; border-radius: 10px;
            padding: 12px 16px; font-size: 0.88rem;
            margin-bottom: 20px;
        }
        .msg::before {
            content: "✓"; font-size: 1rem; font-weight: 700; line-height: 1.2;
        }

        .summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 14px; margin-bottom: 26px;
        }
        .summary .stat {
            background: linear-gradient(135deg, #f8fafc, #f1f5f9);
            border: 1px solid #e6edf3;
            border-radius: 12px;
            padding: 16px 20px;
            display: flex; flex-direction: column; gap: 4px;
            position: relative; overflow: hidden;
        }
        .summary .stat::before {
            content: ""; position: absolute;
            left: 0; top: 0; bottom: 0; width: 4px;
            background: #27ae60;
        }
        .summary .stat.contrib::before  { background: #2980b9; }
        .summary .stat.interest::before { background: #27ae60; }
        .summary .stat.payout::before   { background: #7c3aed; }
        .summary .stat .label {
            font-size: 0.72rem; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.06em;
            color: #6c7a89;
        }
        .summary .stat .value {
            font-size: 1.25rem; font-weight: 700;
            font-variant-numeric: tabular-nums;
        }
        .summary .stat.contrib  .value { color: #1f6390; }
        .summary .stat.interest .value { color: #1e8449; }
        .summary .stat.payout   .value { color: #5b21b6; }

        .table-wrap {
            overflow-x: auto; border-radius: 12px;
            border: 1px solid #e6edf3; background: #fff;
            margin-bottom: 24px;
        }
        table {
            width: 100%; border-collapse: collapse;
            font-size: 0.88rem; min-width: 1000px;
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
            padding: 14px 16px; border-bottom: 1px solid #eef2f6;
            vertical-align: middle; color: #2c3e50;
        }
        tbody tr:last-child td { border-bottom: none; }
        tbody tr:hover { background: #f9fbfd; }
        td.num {
            text-align: right; font-variant-numeric: tabular-nums;
            white-space: nowrap;
        }
        td.amount {
            color: #1e8449; font-weight: 700;
            text-align: right; font-variant-numeric: tabular-nums;
        }
        td.date { color: #34495e; white-space: nowrap; }

        .group-chip {
            display: inline-block;
            background: #e7f1ff; color: #1f6390;
            border: 1px solid #c9e3f7;
            padding: 2px 10px; border-radius: 999px;
            font-size: 0.72rem; font-weight: 700;
            white-space: nowrap;
        }

        .badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 4px 10px; border-radius: 999px;
            font-size: 0.72rem; font-weight: 600;
            white-space: nowrap;
        }
        .badge::before {
            content: ""; width: 6px; height: 6px; border-radius: 50%;
        }
        .badge.paid {
            background: #e8f3ee; color: #1e8449;
            border: 1px solid #cfeadd;
        }
        .badge.paid::before { background: #27ae60; }
        .badge.pending {
            background: #fdecea; color: #b71c1c;
            border: 1px solid #f5c6cb;
        }
        .badge.pending::before { background: #b71c1c; }
        .badge .paid-on {
            font-weight: 500; opacity: 0.85; margin-left: 2px;
        }

        .btn-mark {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 7px 14px;
            background: linear-gradient(135deg, #2980b9, #154a6e);
            color: #fff; border: none; border-radius: 8px;
            font-size: 0.78rem; font-weight: 600;
            cursor: pointer;
            font-family: inherit;
        }
        .btn-mark:hover { background: linear-gradient(135deg, #1f6390, #0d3e5c); }

        .empty {
            text-align: center; color: #6c7a89;
            padding: 40px 20px; font-size: 0.9rem;
        }
        .empty .icon-big {
            display: block; font-size: 2rem;
            margin-bottom: 10px; opacity: 0.6;
        }

        .actions {
            display: flex; gap: 12px; flex-wrap: wrap;
            padding-top: 22px; border-top: 1px solid #eef2f6;
        }
        .actions form { display: inline; }
        .btn {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 11px 20px; border-radius: 10px;
            font-size: 0.9rem; font-weight: 600;
            cursor: pointer; border: 1px solid transparent;
            text-decoration: none;
            font-family: inherit;
            white-space: nowrap;
        }
        .btn-save {
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff;
            box-shadow: 0 6px 16px -6px rgba(39,174,96,0.5);
        }
        .btn-save:hover { background: linear-gradient(135deg, #219150, #196b39); }
        .btn-live {
            background: #fff; color: #2c3e50;
            border-color: #e6edf3;
        }
        .btn-live:hover { background: #f8fafc; border-color: #cfd9e3; }

        @media (max-width: 720px) {
            body { padding: 24px 14px; }
            .card { padding: 26px 22px; }
            .card-header h2 { font-size: 1.25rem; }
            .group-filter { flex-direction: column; align-items: stretch; }
            .group-filter select { width: 100%; }
            .actions { flex-direction: column; }
            .actions .btn,
            .actions form { width: 100%; }
            .actions .btn { justify-content: center; }
        }
    </style>
</head>
<body>

<div class="container">

    <div class="topnav">
        <a href="<%= request.getContextPath() %>/dashboard.jsp" class="back-link">
            🏠 Back to Dashboard
        </a>
    </div>

    <div class="card">

        <div class="card-header">
            <h2>
                <span class="icon">💸</span>
                Payout Schedule
            </h2>
            <p class="sub">
                Every member is paid at maturity (12 months from joining).
                <b>Amount Due = Contribution + Interest Share</b>, where the interest
                share is proportional to each member's contribution
                (1 GHS = 1 unit). Members who exit early receive 95% of their
                contribution — no interest.
            </p>
        </div>

        <!-- ============ GROUP FILTER ============ -->
        <form method="get"
              action="<%= request.getContextPath() %>/payoutServlet"
              class="group-filter">
            <input type="hidden" name="operation" value="viewPayouts" />

            <label for="groupId">🏘️ Group</label>
            <select id="groupId" name="groupId" onchange="this.form.submit()">
                <option value="">— All Groups —</option>
                <c:forEach var="g" items="${groups}">
                    <option value="${g.id}"
                        ${g.id == selectedGroupId ? 'selected' : ''}>
                        ${g.groupName}<c:if test="${not empty g.location}"> · ${g.location}</c:if>
                    </option>
                </c:forEach>
            </select>
        </form>

        <!-- ============ MESSAGE ============ -->
        <c:if test="${not empty param.message}">
            <div class="msg">${param.message}</div>
        </c:if>

        <!-- ============ SUMMARY ============ -->
        <div class="summary">
            <div class="stat contrib">
                <span class="label">Total Contributions</span>
                <span class="value">
                    GHS <fmt:formatNumber value="${totalContrib}" minFractionDigits="2" maxFractionDigits="2"/>
                </span>
            </div>
            <div class="stat interest">
                <span class="label">Total Interest Pool</span>
                <span class="value">
                    GHS <fmt:formatNumber value="${totalInterest}" minFractionDigits="2" maxFractionDigits="2"/>
                </span>
            </div>
            <div class="stat payout">
                <span class="label">Total Payout</span>
                <span class="value">
                    GHS <fmt:formatNumber value="${totalPayout}" minFractionDigits="2" maxFractionDigits="2"/>
                </span>
            </div>
        </div>

        <!-- ============ TABLE ============ -->
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Group</th>
                        <th>Username</th>
                        <th>Phone Number</th>
                        <th style="text-align:right">Contribution</th>
                        <th style="text-align:right">Interest Share</th>
                        <th style="text-align:right">Amount Due (GHS)</th>
                        <th>Maturity Date</th>
                        <th>Status</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${payouts}">
                        <tr>
                            <td><span class="group-chip">${p.groupName}</span></td>
                            <td>${p.username}</td>
                            <td>${p.phoneNumber}</td>
                            <td class="num">
                                <fmt:formatNumber value="${p.contribution}" type="number"
                                                  minFractionDigits="2" maxFractionDigits="2"/>
                            </td>
                            <td class="num">
                                <fmt:formatNumber value="${p.interestShare}" type="number"
                                                  minFractionDigits="2" maxFractionDigits="2"/>
                            </td>
                            <td class="amount">
                                <fmt:formatNumber value="${p.amountDue}" type="number"
                                                  minFractionDigits="2" maxFractionDigits="2"/>
                            </td>
                            <td class="date">
                                <fmt:formatDate value="${p.maturityDate}" pattern="dd MMM yyyy"/>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${p.paid}">
                                        <span class="badge paid">
                                            Paid
                                            <c:if test="${not empty p.paidOn}">
                                                <span class="paid-on">
                                                    · <fmt:formatDate value="${p.paidOn}" pattern="dd MMM yyyy"/>
                                                </span>
                                            </c:if>
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge pending">Pending</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:if test="${not p.paid}">
                                    <form action="<%= request.getContextPath() %>/payoutServlet"
                                          method="post"
                                          onsubmit="return confirm('Mark this member as paid?');">
                                        <input type="hidden" name="operation" value="markPaid" />
                                        <input type="hidden" name="PhoneNumber" value="${p.phoneNumber}" />
                                        <input type="hidden" name="groupId" value="${p.groupId}" />
                                        <button type="submit" class="btn-mark">Mark Paid</button>
                                    </form>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty payouts}">
                        <tr>
                            <td colspan="9" class="empty">
                                <span class="icon-big">📭</span>
                                No payouts to display.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <!-- ============ ACTIONS ============ -->
        <div class="actions">
            <form action="<%= request.getContextPath() %>/payoutServlet" method="post">
                <input type="hidden" name="operation" value="saveSchedule" />
                <input type="hidden" name="groupId" value="${selectedGroupId}" />
                <button type="submit" class="btn btn-save">
                    💾 Save Schedule Snapshot
                </button>
            </form>
            <a href="<%= request.getContextPath() %>/payoutServlet?operation=viewPayouts&groupId=${selectedGroupId}"
               class="btn btn-live">
                🔄 Refresh Live Calculation
            </a>
        </div>

    </div>

</div>

</body>
</html>