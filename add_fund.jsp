<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add to Loan Fund · Timaataba Susu</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto,
                         'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(160deg, #f4f6f9 0%, #eaeef4 100%);
            min-height: 100vh;
            padding: 40px 20px;
            color: #1e2b37;
            line-height: 1.55;
            -webkit-font-smoothing: antialiased;
        }

        .container { max-width: 620px; margin: 0 auto; }

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
            color: #2c3e50;
            text-decoration: none;
            font-size: 0.88rem;
            font-weight: 500;
            padding: 8px 14px;
            border-radius: 8px;
            background: #ffffff;
            border: 1px solid #e2e9f0;
            transition: background 0.15s, border-color 0.15s, transform 0.1s;
        }
        .back-link:hover {
            background: #f8fafc;
            border-color: #cfd9e3;
        }
        .back-link:active { transform: translateX(-2px); }

        .back-link.dashboard {
            color: #1e8449;
            border-color: #cfeadd;
            background: #f0f9f4;
        }
        .back-link.dashboard:hover {
            background: #e6f4ec;
            border-color: #a9dcc1;
        }

        /* ---------- CARD ---------- */
        .card {
            background: #ffffff;
            border-radius: 18px;
            padding: 38px 40px 34px;
            box-shadow: 0 16px 40px -20px rgba(0, 30, 40, 0.18),
                        0 1px 3px rgba(0, 0, 0, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.7);
        }

        .card-header {
            margin-bottom: 26px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eef2f6;
        }

        .card-header h2 {
            font-size: 1.5rem;
            font-weight: 600;
            letter-spacing: -0.02em;
            color: #1e2b3c;
            margin-bottom: 8px;
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
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff;
            font-size: 1.1rem;
            flex-shrink: 0;
        }

        .card-header .sub {
            color: #6c7a89;
            font-size: 0.9rem;
            line-height: 1.6;
        }

        /* ---------- GROUP BANNER ---------- */
        .group-banner {
            background: linear-gradient(135deg, #f0f9f4, #e6f4ec);
            border: 1px solid #cfeadd;
            border-radius: 10px;
            padding: 12px 16px;
            margin-bottom: 20px;
            font-size: 0.88rem;
            color: #1e8449;
            font-weight: 600;
        }

        /* ---------- STATS ---------- */
        .stats {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            border: 1px solid #e6edf3;
            border-radius: 12px;
            padding: 18px 22px;
            margin-bottom: 26px;
        }

        .stats .row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 0;
            font-size: 0.92rem;
            color: #4a6075;
        }
        .stats .row + .row {
            border-top: 1px dashed #e2e9f0;
        }

        .stats .label { font-weight: 500; }
        .stats .value { font-weight: 600; color: #2c3e50; font-variant-numeric: tabular-nums; }

        .stats .highlight {
            margin-top: 6px;
            padding-top: 12px;
            border-top: 1px solid #dce6ee;
        }
        .stats .highlight .value {
            color: #1e8449;
            font-size: 1.05rem;
        }

        /* ---------- FORM ---------- */
        .field { margin-bottom: 18px; }

        label {
            display: block;
            font-size: 0.85rem;
            font-weight: 600;
            color: #34495e;
            margin-bottom: 6px;
        }

        input[type="number"],
        textarea {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid #d7dfe7;
            border-radius: 10px;
            font-size: 0.95rem;
            font-family: inherit;
            color: #1e2b37;
            background: #fbfcfd;
            transition: border-color 0.15s, box-shadow 0.15s, background 0.15s;
        }

        input[type="number"]:focus,
        textarea:focus {
            outline: none;
            border-color: #27ae60;
            background: #ffffff;
            box-shadow: 0 0 0 3px rgba(39, 174, 96, 0.15);
        }

        textarea { resize: vertical; min-height: 60px; }

        /* Remove spinner arrows for a cleaner look */
        input[type="number"]::-webkit-outer-spin-button,
        input[type="number"]::-webkit-inner-spin-button {
            -webkit-appearance: none;
            margin: 0;
        }
        input[type="number"] { -moz-appearance: textfield; }

        /* ---------- BUTTON ---------- */
        .btn-primary {
            width: 100%;
            padding: 13px 20px;
            margin-top: 10px;
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #ffffff;
            border: none;
            border-radius: 10px;
            font-size: 0.98rem;
            font-weight: 600;
            cursor: pointer;
            letter-spacing: 0.01em;
            box-shadow: 0 6px 16px -6px rgba(39, 174, 96, 0.5);
            transition: transform 0.1s, box-shadow 0.2s, background 0.2s;
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, #219150, #196b39);
            box-shadow: 0 10px 22px -8px rgba(39, 174, 96, 0.55);
        }
        .btn-primary:active { transform: translateY(1px); }
        .btn-primary:focus-visible {
            outline: 2px solid #27ae60;
            outline-offset: 3px;
        }

        /* ---------- MESSAGES ---------- */
        .msg {
            margin-bottom: 20px;
            padding: 12px 16px;
            border-radius: 10px;
            font-size: 0.88rem;
            display: flex;
            align-items: flex-start;
            gap: 10px;
            line-height: 1.5;
        }
        .msg::before {
            content: "⚠";
            font-size: 1.05rem;
            line-height: 1;
        }
        .msg.error {
            background: #fdecea;
            color: #b71c1c;
            border: 1px solid #f5c6cb;
        }
        .msg.success {
            background: #e8f5e9;
            color: #1b5e20;
            border: 1px solid #c8e6c9;
        }
        .msg.success::before { content: "✓"; }

        /* ---------- RESPONSIVE ---------- */
        @media (max-width: 540px) {
            body { padding: 24px 14px; }
            .card { padding: 26px 22px; border-radius: 14px; }
            .card-header h2 { font-size: 1.25rem; }
            .card-header .icon { width: 32px; height: 32px; font-size: 1rem; }
            .stats { padding: 14px 16px; }
            .stats .row { font-size: 0.85rem; }
            .topnav { flex-direction: column; align-items: stretch; }
            .back-link { justify-content: center; }
        }
    </style>
</head>
<body>

<div class="container">

    <!-- ---------- TOP NAVIGATION ---------- -->
    <div class="topnav">
        <a href="<%= request.getContextPath() %>/dashboard.jsp" class="back-link dashboard">
            🏠 Back to Dashboard
        </a>
        <a href="<%= request.getContextPath() %>/loanServlet?operation=viewFund"
           class="back-link">
            ← Back to Loan Fund
        </a>
    </div>

    <!-- ---------- MAIN CARD ---------- -->
    <div class="card">

        <div class="card-header">
            <h2>
                <span class="icon">🏦</span>
                Add to Loan Fund
            </h2>
            <p class="sub">
                Enter an amount to move from the contribution pool into the loan fund.
                The pool balance below will decrease by that amount.
            </p>
        </div>

        <!-- ============ GROUP BANNER ============ -->
        <div class="group-banner">
            🏘️ Allocating to: <strong>${sessionScope.currentGroupName}</strong>
        </div>

        <c:set var="totalContributions" value="${empty totalContributions ? 0 : totalContributions}" />
        <c:set var="totalAllocated"     value="${empty totalAllocated     ? 0 : totalAllocated}" />
        <c:set var="balance"            value="${empty balance            ? 0 : balance}" />

        <!-- ---------- STATS PANEL ---------- -->
        <div class="stats">
            <div class="row">
                <span class="label">Total Contributions</span>
                <span class="value">
                    GHS <fmt:formatNumber value="${totalContributions}" type="number"
                                          minFractionDigits="2" maxFractionDigits="2"/>
                </span>
            </div>
            <div class="row">
                <span class="label">Already in Loan Fund</span>
                <span class="value">
                    GHS <fmt:formatNumber value="${totalAllocated}" type="number"
                                          minFractionDigits="2" maxFractionDigits="2"/>
                </span>
            </div>
            <div class="row highlight">
                <span class="label">Remaining Pool</span>
                <span class="value">
                    GHS <fmt:formatNumber value="${balance}" type="number"
                                          minFractionDigits="2" maxFractionDigits="2"/>
                </span>
            </div>
        </div>

        <!-- ---------- FEEDBACK MESSAGES ---------- -->
        <c:if test="${not empty param.message}">
            <div class="msg error">${param.message}</div>
        </c:if>
        <c:if test="${not empty param.success}">
            <div class="msg success">${param.success}</div>
        </c:if>

        <!-- ---------- FORM ---------- -->
        <form action="<%= request.getContextPath() %>/loanServlet" method="post">
            <input type="hidden" name="operation" value="allocate" />

            <div class="field">
                <label for="amount">Amount (GHS)</label>
                <input type="number" step="0.01" min="0.01"
                       name="amount" id="amount"
                       placeholder="e.g. 500.00" required />
            </div>

            <div class="field">
                <label for="note">Note <span style="color:#95a5a6; font-weight:400;">(optional)</span></label>
                <textarea name="note" id="note" rows="2"
                          placeholder="e.g. Q1 allocation"></textarea>
            </div>

            <button type="submit" class="btn-primary">
                Move to Loan Fund →
            </button>
        </form>

    </div>

</div>

</body>
</html>