<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Loan Fund · Timaataba Susu</title>
    <style>
        :root {
            --primary:        #27ae60;
            --primary-dark:   #1e8449;
            --primary-light:  #e8f3ee;
            --primary-border: #cfeadd;
            --danger:         #b71c1c;
            --danger-bg:      #fdecea;
            --danger-border:  #f5c6cb;
            --info:           #2980b9;
            --info-dark:      #1f6390;
            --info-bg:        #e7f4fd;
            --info-border:    #c3e2f5;
            --text:           #1e2b37;
            --muted:          #6c7a89;
            --border:         #e6edf3;
            --bg:             #f4f6f9;
            --card-bg:        #ffffff;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
                         "Helvetica Neue", Arial, sans-serif;
            background: linear-gradient(160deg, #f4f6f9 0%, #eaeef4 100%);
            color: var(--text);
            line-height: 1.55;
            -webkit-font-smoothing: antialiased;
            min-height: 100vh;
            padding: 40px 20px;
        }

        .container { max-width: 1080px; margin: 0 auto; }

        /* ---------- TOP NAV ---------- */
        .topnav {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 10px;
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            color: var(--primary-dark);
            text-decoration: none;
            font-size: 0.88rem;
            font-weight: 500;
            padding: 8px 14px;
            border-radius: 8px;
            background: #f0f9f4;
            border: 1px solid var(--primary-border);
            transition: background 0.15s, border-color 0.15s, transform 0.1s;
        }
        .back-link:hover {
            background: #e6f4ec;
            border-color: #a9dcc1;
        }
        .back-link:active { transform: translateX(-2px); }

        /* ---------- CARD ---------- */
        .card {
            background: var(--card-bg);
            border-radius: 18px;
            padding: 38px 40px 34px;
            box-shadow: 0 16px 40px -20px rgba(0, 30, 40, 0.18),
                        0 1px 3px rgba(0, 0, 0, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.7);
        }

        .card-header {
            margin-bottom: 24px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eef2f6;
        }

        .card-header h2 {
            font-size: 1.5rem;
            font-weight: 600;
            letter-spacing: -0.02em;
            color: #1e2b3c;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .card-header .icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 38px;
            height: 38px;
            border-radius: 10px;
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: #fff;
            font-size: 1.1rem;
            flex-shrink: 0;
        }

        /* ---------- MESSAGE ---------- */
        .message {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            background: var(--info-bg);
            color: var(--info-dark);
            border: 1px solid var(--info-border);
            border-radius: 10px;
            padding: 12px 16px;
            font-size: 0.88rem;
            line-height: 1.5;
            margin-bottom: 20px;
        }
        .message::before {
            content: "ℹ";
            font-size: 1.05rem;
            line-height: 1;
            flex-shrink: 0;
        }

        /* ---------- STATS ---------- */
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 14px;
            margin-bottom: 26px;
        }

        .stat {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 16px 20px;
            display: flex;
            flex-direction: column;
            gap: 4px;
            position: relative;
            overflow: hidden;
        }

        .stat::before {
            content: "";
            position: absolute;
            left: 0; top: 0; bottom: 0;
            width: 4px;
            background: var(--primary);
        }
        .stat.pool::before    { background: var(--primary); }
        .stat.fund::before    { background: var(--info); }
        .stat.contrib::before { background: #7c3aed; }
        .stat.alloc::before   { background: var(--muted); }

        .stat .label {
            font-size: 0.72rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: var(--muted);
        }

        .stat .value {
            font-size: 1.35rem;
            font-weight: 700;
            color: #2c3e50;
            font-variant-numeric: tabular-nums;
            letter-spacing: -0.01em;
        }

        .stat.fund    .value { color: var(--info-dark); }
        .stat.pool    .value { color: var(--primary-dark); }
        .stat.contrib .value { color: #5b21b6; }
        .stat.alloc   .value { color: #4b5563; }

        /* ---------- ACTIONS ---------- */
        .actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 26px;
            padding-bottom: 22px;
            border-bottom: 1px solid #eef2f6;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 11px 20px;
            border-radius: 10px;
            font-size: 0.9rem;
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
            border: 1px solid transparent;
            transition: transform 0.1s, box-shadow 0.2s, background 0.2s, border-color 0.15s;
            white-space: nowrap;
            font-family: inherit;
        }
        .btn:active { transform: translateY(1px); }
        .btn:focus-visible { outline: 2px solid var(--primary); outline-offset: 2px; }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: #fff;
            box-shadow: 0 6px 16px -6px rgba(39, 174, 96, 0.5);
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, #219150, #196b39);
            box-shadow: 0 10px 22px -8px rgba(39, 174, 96, 0.55);
        }

        .btn-secondary {
            background: #ffffff;
            color: #2c3e50;
            border-color: var(--border);
        }
        .btn-secondary:hover {
            background: #f8fafc;
            border-color: #cfd9e3;
        }

        /* ---------- DISTRIBUTE BUTTON ---------- */
        .btn-distribute {
            background: linear-gradient(135deg, #f59e0b, #b45309);
            color: #fff;
            box-shadow: 0 6px 16px -6px rgba(245, 158, 11, 0.5);
        }
        .btn-distribute:hover {
            background: linear-gradient(135deg, #d97706, #92400e);
            box-shadow: 0 10px 22px -8px rgba(245, 158, 11, 0.55);
        }

        /* Inline form so its button sits as a direct child of .actions */
        .actions form { display: contents; }

        /* ---------- ACTIVE INVESTMENT BUTTON ---------- */
        .btn-active {
            background: linear-gradient(135deg, #7c3aed, #5b21b6);
            color: #ffffff;
            box-shadow: 0 6px 16px -6px rgba(124, 58, 237, 0.5);
        }
        .btn-active:hover {
            background: linear-gradient(135deg, #6d28d9, #4c1d95);
            box-shadow: 0 10px 22px -8px rgba(124, 58, 237, 0.55);
        }
        .btn-active .caret {
            display: inline-block;
            transition: transform 0.25s ease;
            font-size: 0.75rem;
        }
        .btn-active.open .caret {
            transform: rotate(180deg);
        }

        /* ---------- ACTIVE INVESTMENT PANEL ---------- */
        .active-panel {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.4s ease, margin-bottom 0.3s ease;
            margin-bottom: 0;
        }
        .active-panel.open {
            max-height: 2000px;
            margin-bottom: 26px;
        }
        .active-panel-inner {
            padding: 22px;
            background: linear-gradient(135deg, #f5f3ff 0%, #ede9fe 100%);
            border: 1px solid #ddd6fe;
            border-radius: 14px;
        }

        .active-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 16px;
            padding-bottom: 12px;
            border-bottom: 1px solid #ddd6fe;
            flex-wrap: wrap;
        }

        .active-header .title {
            font-size: 1.05rem;
            font-weight: 700;
            color: #4c1d95;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .active-header .title .big-icon {
            font-size: 1.2rem;
        }

        .active-header .total-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            background: #ffffff;
            border: 1px solid #ddd6fe;
            border-radius: 999px;
            font-size: 0.85rem;
            font-weight: 600;
            color: #4c1d95;
            font-variant-numeric: tabular-nums;
        }
        .active-header .total-chip b {
            color: #7c3aed;
        }

        .active-loading {
            text-align: center;
            padding: 32px 20px;
            color: #6d28d9;
            font-size: 0.9rem;
        }
        .active-loading .spinner {
            display: inline-block;
            width: 26px;
            height: 26px;
            border: 3px solid #ddd6fe;
            border-top-color: #7c3aed;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
            margin-bottom: 10px;
        }
        @keyframes spin { to { transform: rotate(360deg); } }

        .active-error {
            background: var(--danger-bg);
            color: var(--danger);
            border: 1px solid var(--danger-border);
            border-radius: 10px;
            padding: 14px 18px;
            font-size: 0.88rem;
            display: flex;
            align-items: flex-start;
            gap: 10px;
        }
        .active-error::before {
            content: "⚠";
            font-size: 1.05rem;
            line-height: 1;
            flex-shrink: 0;
        }

        .active-empty {
            text-align: center;
            padding: 40px 20px;
            color: #6d28d9;
        }
        .active-empty .big {
            font-size: 2.2rem;
            display: block;
            margin-bottom: 8px;
        }
        .active-empty h3 {
            font-size: 1rem;
            color: #4c1d95;
            margin-bottom: 4px;
        }
        .active-empty p {
            font-size: 0.85rem;
            color: #7c3aed;
        }

        /* ---------- ACTIVE INVESTMENT TABLE ---------- */
        .active-table-wrap {
            overflow-x: auto;
            border-radius: 10px;
            border: 1px solid #ddd6fe;
            background: #ffffff;
        }
        .active-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.85rem;
            min-width: 640px;
        }
        .active-table thead th {
            background: #ede9fe;
            color: #4c1d95;
            font-size: 0.68rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            padding: 12px 14px;
            text-align: left;
            white-space: nowrap;
        }
        .active-table tbody td {
            padding: 12px 14px;
            border-bottom: 1px solid #f3f0ff;
            color: #2c3e50;
        }
        .active-table tbody tr:last-child td { border-bottom: none; }
        .active-table tbody tr:hover { background: #faf5ff; }

        .active-table td.num {
            text-align: right;
            font-variant-numeric: tabular-nums;
            white-space: nowrap;
        }
        .active-table td.id {
            color: #7c3aed;
            font-weight: 700;
        }
        .active-table td.principal { color: #2c3e50; font-weight: 600; }
        .active-table td.interest  { color: #7c3aed; font-weight: 600; }
        .active-table td.total     { color: #5b21b6; font-weight: 700; }
        .active-table td.due       { color: var(--danger); font-weight: 600; white-space: nowrap; }
        .active-table td.due.soon  { color: #b45309; }

        /* ---------- SEARCH / FILTER BAR ---------- */
        .filter-bar {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 20px 22px;
            margin-bottom: 22px;
        }

        .filter-title {
            font-size: 0.72rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            color: var(--muted);
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .filter-row {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            align-items: center;
        }

        .filter-row input[type="date"] {
            padding: 10px 14px;
            border: 1px solid var(--border);
            border-radius: 10px;
            font-size: 0.9rem;
            font-family: inherit;
            color: var(--text);
            background: #ffffff;
            transition: border-color 0.15s, box-shadow 0.15s;
            cursor: pointer;
            min-width: 180px;
        }

        .filter-row input[type="date"]:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(39, 174, 96, 0.15);
        }

        .chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 14px;
            border-radius: 999px;
            background: #ffffff;
            color: #2c3e50;
            border: 1px solid var(--border);
            font-size: 0.82rem;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.15s, border-color 0.15s, color 0.15s, transform 0.1s;
            white-space: nowrap;
            font-family: inherit;
        }
        .chip:hover {
            background: var(--primary-light);
            border-color: var(--primary-border);
            color: var(--primary-dark);
        }
        .chip:active { transform: translateY(1px); }
        .chip.active {
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: #ffffff;
            border-color: transparent;
            box-shadow: 0 4px 10px -3px rgba(39, 174, 96, 0.5);
        }
        .chip.clear {
            color: var(--danger);
            border-color: var(--danger-border);
        }
        .chip.clear:hover {
            background: var(--danger-bg);
            border-color: var(--danger);
        }

        .filter-result {
            margin-top: 14px;
            padding-top: 12px;
            border-top: 1px solid #e2e9f0;
            font-size: 0.82rem;
            color: var(--muted);
            display: none;
        }
        .filter-result.show { display: block; }
        .filter-result b { color: var(--primary-dark); font-weight: 700; }

        /* ---------- TABLE ---------- */
        .table-wrap {
            overflow-x: auto;
            border-radius: 12px;
            border: 1px solid var(--border);
            background: #fff;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.88rem;
            min-width: 720px;
        }

        thead th {
            background: #f8fafc;
            text-align: left;
            font-weight: 700;
            color: #475569;
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            padding: 14px 16px;
            border-bottom: 1px solid var(--border);
            white-space: nowrap;
        }

        tbody td {
            padding: 14px 16px;
            border-bottom: 1px solid #eef2f6;
            vertical-align: middle;
            color: #2c3e50;
        }

        tbody tr:last-child td { border-bottom: none; }
        tbody tr:hover { background: #f9fbfd; }
        tbody tr.hidden { display: none; }

        td.idx { color: var(--muted); font-weight: 600; width: 44px; }

        /* ---------- TYPE BADGES ---------- */
        .type-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 0.7rem;
            font-weight: 700;
            letter-spacing: 0.03em;
            white-space: nowrap;
        }
        .type-badge::before {
            content: "";
            width: 6px;
            height: 6px;
            border-radius: 50%;
        }

        .type-allocation {
            background: var(--primary-light);
            color: var(--primary-dark);
            border: 1px solid var(--primary-border);
        }
        .type-allocation::before { background: var(--primary); }

        .type-loan_out {
            background: var(--danger-bg);
            color: var(--danger);
            border: 1px solid var(--danger-border);
        }
        .type-loan_out::before { background: var(--danger); }

        .type-repayment {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #a7f3d0;
        }
        .type-repayment::before { background: #10b981; }

        .type-badge.default {
            background: #eef2f6;
            color: #475569;
            border: 1px solid #dce3ea;
        }
        .type-badge.default::before { background: #94a3b8; }

        /* ---------- AMOUNT ---------- */
        .amount {
            font-variant-numeric: tabular-nums;
            font-weight: 700;
            text-align: right;
            white-space: nowrap;
        }
        .amount.neg { color: var(--danger); }
        .amount.pos { color: var(--primary-dark); }

        /* ---------- EMPTY / NO-MATCH ---------- */
        .no-match, .empty {
            text-align: center;
            padding: 48px 24px;
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            border: 1px dashed #cfd9e3;
            border-radius: 12px;
            color: var(--muted);
        }
        .no-match { display: none; margin-top: 16px; }
        .no-match.show { display: block; }
        .icon-big {
            display: block;
            font-size: 2.5rem;
            margin-bottom: 12px;
            opacity: 0.7;
        }
        .no-match h3, .empty h3 {
            font-size: 1.05rem;
            color: #2c3e50;
            margin-bottom: 6px;
            font-weight: 600;
        }
        .no-match p, .empty p {
            font-size: 0.88rem;
            color: var(--muted);
        }

        /* ---------- RESPONSIVE ---------- */
        @media (max-width: 720px) {
            body { padding: 24px 14px; }
            .card { padding: 26px 22px; border-radius: 14px; }
            .card-header h2 { font-size: 1.25rem; }
            .card-header .icon { width: 32px; height: 32px; font-size: 1rem; }
            .topnav { flex-direction: column; align-items: stretch; }
            .back-link { justify-content: center; }
            .actions { flex-direction: column; }
            .actions .btn { justify-content: center; width: 100%; }
            .stat .value { font-size: 1.15rem; }
            .filter-row { flex-direction: column; align-items: stretch; }
            .filter-row input[type="date"] { width: 100%; }
            .chip { justify-content: center; }
            .active-header { flex-direction: column; align-items: stretch; }
        }
    </style>
</head>
<body>

<div class="container">

    <!-- ---------- TOP NAV ---------- -->
    <div class="topnav">
        <a href="<%= request.getContextPath() %>/dashboard.jsp" class="back-link">
            🏠 Back to Dashboard
        </a>
    </div>

    <!-- ---------- CARD ---------- -->
    <div class="card">

        <div class="card-header">
            <h2>
                <span class="icon">🏦</span>
                Loan Fund
            </h2>
        </div>

        <!-- ---------- MESSAGE ---------- -->
        <c:if test="${not empty param.message}">
            <div class="message"><c:out value="${param.message}"/></div>
        </c:if>

        <!-- ---------- STATS ---------- -->
        <div class="stats">
            <div class="stat fund">
                <span class="label">Fund Balance</span>
                <span class="value">
                    <fmt:formatNumber value="${balance}" type="number"
                                      minFractionDigits="2" maxFractionDigits="2"/>
                </span>
            </div>
            <div class="stat pool">
                <span class="label">Pool Balance</span>
                <span class="value">
                    <fmt:formatNumber value="${poolBalance}" type="number"
                                      minFractionDigits="2" maxFractionDigits="2"/>
                </span>
            </div>
            <div class="stat contrib">
                <span class="label">Total Contributions</span>
                <span class="value">
                    <fmt:formatNumber value="${totalContributions}" type="number"
                                      minFractionDigits="2" maxFractionDigits="2"/>
                </span>
            </div>
            <div class="stat alloc">
                <span class="label">Total Allocated</span>
                <span class="value">
                    <fmt:formatNumber value="${totalAllocated}" type="number"
                                      minFractionDigits="2" maxFractionDigits="2"/>
                </span>
            </div>
        </div>

        <!-- ---------- ACTIONS ---------- -->
        <div class="actions">
            <a class="btn btn-primary"
               href="${pageContext.request.contextPath}/loanServlet?operation=newFundEntry">
                ➕ Add Fund Entry
            </a>
            <a class="btn btn-secondary"
               href="${pageContext.request.contextPath}/loanServlet?operation=newLoan">
                📝 Issue Loan
            </a>
            <a class="btn btn-secondary"
               href="${pageContext.request.contextPath}/loanServlet?operation=repayForm">
                💵 Repay Loan
            </a>

            <!-- Distribute Interest (POST) -->
            <form method="post"
                  action="${pageContext.request.contextPath}/loanServlet"
                  onsubmit="return confirm('Distribute interest for this group now? This will also apply today\'s charge.');">
                <input type="hidden" name="operation" value="distributeInterest">
                <input type="hidden" name="groupId"   value="${selectedGroupId}">
                <button type="submit" class="btn btn-distribute">
                    💰 Distribute Interest
                </button>
            </form>

            <!-- Active Investment toggle button -->
            <button type="button" class="btn btn-active" id="activeInvestmentBtn">
                📊 Active Investment
                <span class="caret">▾</span>
            </button>
        </div>

        <!-- ---------- ACTIVE INVESTMENT PANEL ---------- -->
        <div class="active-panel" id="activePanel">
            <div class="active-panel-inner">
                <div class="active-header">
                    <div class="title">
                        <span class="big-icon">📊</span>
                        Outstanding Loans (Active Investment)
                    </div>
                    <div class="total-chip" id="activeTotal" style="display:none;">
                        Total Outstanding: GHS <b id="activeTotalValue">0.00</b>
                    </div>
                </div>

                <div id="activeContent">
                    <!-- Content injected by JS -->
                </div>
            </div>
        </div>

        <!-- ---------- SEARCH / FILTER BAR ---------- -->
        <c:if test="${not empty entries}">
            <div class="filter-bar">
                <div class="filter-title">
                    🔍 Filter transactions
                </div>

                <div class="filter-row">
                    <input type="date" id="dateFilter" aria-label="Filter by date" />

                    <button type="button" class="chip" data-quick="today">Today</button>
                    <button type="button" class="chip" data-quick="yesterday">Yesterday</button>
                    <button type="button" class="chip" data-quick="7days">Last 7 days</button>
                    <button type="button" class="chip" data-quick="month">This month</button>
                    <button type="button" class="chip" data-quick="all">All time</button>
                    <button type="button" class="chip clear" id="clearFilter">✕ Clear</button>
                </div>

                <div class="filter-result" id="filterResult"></div>
            </div>
        </c:if>

        <!-- ---------- TABLE / EMPTY ---------- -->
        <c:choose>
            <c:when test="${not empty entries}">

                <div class="table-wrap">
                    <table id="entriesTable">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Type</th>
                                <th>Phone</th>
                                <th style="text-align:right">Amount</th>
                                <th>Notes</th>
                                <th>Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="e" items="${entries}" varStatus="loop">
                                <tr data-date="${e.createdOn}">
                                    <td class="idx">${loop.count}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${e.transactionType eq 'ALLOCATION'}">
                                                <span class="type-badge type-allocation">ALLOCATION</span>
                                            </c:when>
                                            <c:when test="${e.transactionType eq 'LOAN_OUT'}">
                                                <span class="type-badge type-loan_out">LOAN OUT</span>
                                            </c:when>
                                            <c:when test="${e.transactionType eq 'REPAYMENT'}">
                                                <span class="type-badge type-repayment">REPAYMENT</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="type-badge default">${e.transactionType}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><c:out value="${e.phoneNumber}"/></td>
                                    <td class="amount ${e.transactionType eq 'LOAN_OUT' ? 'neg' : 'pos'}">
                                        ${e.transactionType eq 'LOAN_OUT' ? '−' : '+'}
                                        <fmt:formatNumber value="${e.amount}" type="number"
                                                          minFractionDigits="2"
                                                          maxFractionDigits="2"/>
                                    </td>
                                    <td><c:out value="${e.note}"/></td>
                                    <td>${e.createdOn}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <div class="no-match" id="noMatch">
                    <span class="icon-big">🔍</span>
                    <h3>No transactions match the selected date</h3>
                    <p>Try a different date or click "Clear" to see everything.</p>
                </div>

            </c:when>
            <c:otherwise>
                <div class="empty">
                    <span class="icon-big">🏦</span>
                    <h3>No fund entries yet</h3>
                    <p>Click "Add Fund Entry" to allocate money into the loan fund.</p>
                </div>
            </c:otherwise>
        </c:choose>

    </div>

</div>

<script>
/* ============================================================
 *  1. ACTIVE INVESTMENT — toggle + fetch outstanding loans
 * ============================================================ */
(function () {
    const btn       = document.getElementById('activeInvestmentBtn');
    const panel     = document.getElementById('activePanel');
    const content   = document.getElementById('activeContent');
    const totalChip = document.getElementById('activeTotal');
    const totalVal  = document.getElementById('activeTotalValue');

    if (!btn) return;

    let loaded = false;

    btn.addEventListener('click', function () {
        const willOpen = !panel.classList.contains('open');
        panel.classList.toggle('open', willOpen);
        btn.classList.toggle('open', willOpen);

        if (willOpen && !loaded) {
            loadActiveInvestments();
            loaded = true;
        }
    });

    function loadActiveInvestments() {
        content.innerHTML =
            '<div class="active-loading">' +
                '<div class="spinner"></div>' +
                '<div>Loading outstanding loans…</div>' +
            '</div>';

        fetch('<%= request.getContextPath() %>/loanServlet?operation=outstandingLoansJson')
            .then(function (r) {
                if (!r.ok) throw new Error('Server returned ' + r.status);
                return r.json();
            })
            .then(function (loans) {
                renderLoans(loans);
            })
            .catch(function (err) {
                content.innerHTML =
                    '<div class="active-error">Could not load active investments: ' +
                    escapeHtml(err.message) + '</div>';
            });
    }

    function renderLoans(loans) {
        if (!loans || loans.length === 0) {
            totalChip.style.display = 'none';
            content.innerHTML =
                '<div class="active-empty">' +
                    '<span class="big">✅</span>' +
                    '<h3>No active investments</h3>' +
                    '<p>All loans have been repaid, or none have been issued yet.</p>' +
                '</div>';
            return;
        }

        // Compute total outstanding (principal + interest) for the chip
        let total = 0;
        loans.forEach(function (l) {
            total += parseFloat(l.principal || 0) + parseFloat(l.interest || 0);
        });
        totalVal.textContent = fmtMoney(total);
        totalChip.style.display = 'inline-flex';

        // Build the table rows
        let html = '';
        html += '<div class="active-table-wrap">';
        html += '<table class="active-table">';
        html += '<thead><tr>' +
                    '<th>#</th>' +
                    '<th>Phone</th>' +
                    '<th style="text-align:right">Principal</th>' +
                    '<th style="text-align:right">Interest</th>' +
                    '<th style="text-align:right">Total Owed</th>' +
                    '<th>Issued</th>' +
                    '<th>Due</th>' +
                '</tr></thead><tbody>';

        loans.forEach(function (l) {
            const principal = parseFloat(l.principal || 0);
            const interest  = parseFloat(l.interest  || 0);
            const totalOwed = principal + interest;
            const dueSoonClass = isDueSoon(l.dueDate) ? 'due soon' : 'due';

            html += '<tr>' +
                        '<td class="id">#' + l.id + '</td>' +
                        '<td>' + escapeHtml(l.phone || '') + '</td>' +
                        '<td class="num principal">' + fmtMoney(principal) + '</td>' +
                        '<td class="num interest">'  + fmtMoney(interest)  + '</td>' +
                        '<td class="num total">'     + fmtMoney(totalOwed) + '</td>' +
                        '<td>' + escapeHtml(formatDate(l.issuedOn)) + '</td>' +
                        '<td class="' + dueSoonClass + '">' + escapeHtml(formatDate(l.dueDate)) + '</td>' +
                    '</tr>';
        });

        html += '</tbody></table></div>';
        content.innerHTML = html;
    }

    function isDueSoon(iso) {
        if (!iso) return false;
        const due = new Date(iso);
        if (isNaN(due)) return false;
        const diffDays = (due - new Date()) / (1000 * 60 * 60 * 24);
        return diffDays >= 0 && diffDays <= 14;
    }

    function fmtMoney(n) {
        return (isFinite(n) ? n : 0).toFixed(2);
    }

    function formatDate(iso) {
        if (!iso) return '';
        const parts = iso.split('-');
        if (parts.length !== 3) return iso;
        const d = new Date(parts[0], parts[1] - 1, parts[2]);
        return d.toLocaleDateString('en-GB',
            { day: 'numeric', month: 'short', year: 'numeric' });
    }

    function escapeHtml(s) {
        return String(s)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }
})();

/* ============================================================
 *  2. DATE FILTER — for fund entries
 * ============================================================ */
(function () {
    const dateInput   = document.getElementById('dateFilter');
    const table       = document.getElementById('entriesTable');
    const noMatch     = document.getElementById('noMatch');
    const resultBox   = document.getElementById('filterResult');
    const clearBtn    = document.getElementById('clearFilter');
    const chipButtons = document.querySelectorAll('.chip[data-quick]');

    if (!table) return;

    const rows = Array.from(table.querySelectorAll('tbody tr'));

    function toISO(value) {
        if (!value) return '';
        if (/^\d{4}-\d{2}-\d{2}/.test(value)) return value.substring(0, 10);
        const d = new Date(value);
        if (isNaN(d)) return '';
        const yyyy = d.getFullYear();
        const mm   = String(d.getMonth() + 1).padStart(2, '0');
        const dd   = String(d.getDate()).padStart(2, '0');
        return yyyy + '-' + mm + '-' + dd;
    }

    function toLocalISO(d) {
        const yyyy = d.getFullYear();
        const mm   = String(d.getMonth() + 1).padStart(2, '0');
        const dd   = String(d.getDate()).padStart(2, '0');
        return yyyy + '-' + mm + '-' + dd;
    }

    function todayISO() {
        return toLocalISO(new Date());
    }

    function applyDateFilter(isoDate) {
        let visible = 0;
        rows.forEach(function (row) {
            const rowISO = toISO(row.dataset.date || '');
            const match  = !isoDate || rowISO === isoDate;
            row.classList.toggle('hidden', !match);
            if (match) visible++;
        });
        noMatch.classList.toggle('show', visible === 0 && rows.length > 0);
        if (!isoDate) {
            resultBox.classList.remove('show');
            resultBox.innerHTML = '';
        } else {
            resultBox.classList.add('show');
            const label = visible === 1 ? 'transaction' : 'transactions';
            resultBox.innerHTML =
                'Showing <b>' + visible + '</b> ' + label +
                ' on <b>' + formatPretty(isoDate) + '</b>.';
        }
    }

    function formatPretty(iso) {
        const parts = iso.split('-');
        if (parts.length !== 3) return iso;
        const d = new Date(parts[0], parts[1] - 1, parts[2]);
        return d.toLocaleDateString('en-GB',
            { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' });
    }

    function setActiveChip(quick) {
        chipButtons.forEach(function (c) {
            c.classList.toggle('active', c.dataset.quick === quick);
        });
    }

    dateInput.addEventListener('change', function () {
        setActiveChip('');
        applyDateFilter(dateInput.value);
    });

    chipButtons.forEach(function (chip) {
        chip.addEventListener('click', function () {
            const quick = chip.dataset.quick;
            const today = new Date();

            if (quick === 'all') {
                dateInput.value = '';
                applyDateFilter('');
                setActiveChip('all');
                return;
            }
            if (quick === 'today') {
                const iso = todayISO();
                dateInput.value = iso;
                applyDateFilter(iso);
                setActiveChip('today');
                return;
            }
            if (quick === 'yesterday') {
                today.setDate(today.getDate() - 1);
                const iso = toLocalISO(today);
                dateInput.value = iso;
                applyDateFilter(iso);
                setActiveChip('yesterday');
                return;
            }
            if (quick === '7days') {
                dateInput.value = '';
                const cutoff = new Date();
                cutoff.setDate(cutoff.getDate() - 6);
                const cutoffISO = toLocalISO(cutoff);
                let visible = 0;
                rows.forEach(function (row) {
                    const rowISO = toISO(row.dataset.date || '');
                    const match  = rowISO && rowISO >= cutoffISO;
                    row.classList.toggle('hidden', !match);
                    if (match) visible++;
                });
                noMatch.classList.toggle('show', visible === 0);
                resultBox.classList.add('show');
                const label = visible === 1 ? 'transaction' : 'transactions';
                resultBox.innerHTML =
                    'Showing <b>' + visible + '</b> ' + label +
                    ' from the <b>last 7 days</b>.';
                setActiveChip('7days');
                return;
            }
            if (quick === 'month') {
                dateInput.value = '';
                const now = new Date();
                const prefix = now.getFullYear() + '-' +
                    String(now.getMonth() + 1).padStart(2, '0');
                let visible = 0;
                rows.forEach(function (row) {
                    const rowISO = toISO(row.dataset.date || '');
                    const match  = rowISO && rowISO.startsWith(prefix);
                    row.classList.toggle('hidden', !match);
                    if (match) visible++;
                });
                noMatch.classList.toggle('show', visible === 0);
                resultBox.classList.add('show');
                const label = visible === 1 ? 'transaction' : 'transactions';
                resultBox.innerHTML =
                    'Showing <b>' + visible + '</b> ' + label +
                    ' for <b>' + now.toLocaleDateString('en-GB',
                        { month: 'long', year: 'numeric' }) + '</b>.';
                setActiveChip('month');
                return;
            }
        });
    });

    clearBtn.addEventListener('click', function () {
        dateInput.value = '';
        setActiveChip('');
        applyDateFilter('');
    });
})();
</script>

</body>
</html>