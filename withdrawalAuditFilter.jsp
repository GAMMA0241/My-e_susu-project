<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Withdrawal Audit Trail · Timaataba Susu</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            background: linear-gradient(160deg, #f4f6f9 0%, #eaeef4 100%);
            color: #1e2b37; min-height: 100vh; padding: 40px 20px; line-height: 1.55;
        }
        .container { max-width: 520px; margin: 0 auto; }
        .topnav { margin-bottom: 20px; }
        .back-link {
            display: inline-flex; align-items: center; gap: 6px;
            color: #1e8449; text-decoration: none; font-size: 0.88rem;
            font-weight: 500; padding: 8px 14px; border-radius: 8px;
            background: #f0f9f4; border: 1px solid #cfeadd;
            transition: background 0.15s;
        }
        .back-link:hover { background: #e6f4ec; }
        .card {
            background: #fff; border-radius: 18px; padding: 38px 40px 34px;
            box-shadow: 0 16px 40px -20px rgba(0,30,40,0.18);
            border: 1px solid rgba(255,255,255,0.7);
        }
        .card-header {
            margin-bottom: 26px; padding-bottom: 20px;
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
        .card-header .sub {
            color: #6c7a89; font-size: 0.9rem; margin-top: 8px;
        }
        .group-banner {
            background: linear-gradient(135deg, #f0f9f4, #e6f4ec);
            border: 1px solid #cfeadd; border-radius: 10px;
            padding: 12px 16px; margin-bottom: 20px;
            font-size: 0.88rem; color: #1e8449; font-weight: 600;
        }
        .section-title {
            font-size: 0.72rem; font-weight: 700; text-transform: uppercase;
            letter-spacing: 0.08em; color: #6c7a89;
            margin: 22px 0 10px; padding-bottom: 6px;
            border-bottom: 1px solid #eef2f6;
        }
        .section-title:first-of-type { margin-top: 0; }
        .field { margin-bottom: 16px; }
        label {
            display: block; font-size: 0.85rem; font-weight: 600;
            color: #34495e; margin-bottom: 6px;
        }
        input[type="date"], select {
            width: 100%; padding: 12px 14px;
            border: 1px solid #d7dfe7; border-radius: 10px;
            font-size: 0.95rem; font-family: inherit;
            color: #1e2b37; background: #fbfcfd;
            transition: border-color 0.15s, box-shadow 0.15s, background 0.15s;
        }
        input:focus, select:focus {
            outline: none; border-color: #27ae60; background: #fff;
            box-shadow: 0 0 0 3px rgba(39,174,96,0.15);
        }
        .field-row {
            display: grid; grid-template-columns: 1fr 1fr; gap: 12px;
        }
        .help {
            font-size: 0.78rem; color: #8a97a3; margin-top: 4px;
        }
        .btn {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 13px 22px; border-radius: 10px;
            font-size: 0.95rem; font-weight: 600;
            cursor: pointer; border: none; font-family: inherit;
            width: 100%; justify-content: center;
            margin-top: 8px;
            transition: transform 0.1s, box-shadow 0.2s, background 0.2s;
        }
        .btn-primary {
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff;
            box-shadow: 0 6px 16px -6px rgba(39,174,96,0.5);
        }
        .btn-primary:hover { background: linear-gradient(135deg, #219150, #196b39); }
        .btn-primary:active { transform: translateY(1px); }
        .btn-secondary {
            background: #f0f9f4; color: #1e8449;
            border: 1px solid #cfeadd; box-shadow: none;
        }
        .btn-secondary:hover { background: #e6f4ec; }
        .error {
            background: #fdecea; color: #b71c1c;
            border: 1px solid #f5c6cb; border-radius: 10px;
            padding: 12px 16px; font-size: 0.9rem;
            margin-bottom: 20px;
        }
        .error::before { content: "⚠ "; }
        @media (max-width: 540px) {
            body { padding: 24px 14px; }
            .card { padding: 26px 22px; }
            .card-header h2 { font-size: 1.25rem; }
            .field-row { grid-template-columns: 1fr; }
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
                <span class="icon">📋</span>
                Withdrawal Audit Trail
            </h2>
            <p class="sub">Every withdrawal request — who asked, how much, and who processed it.</p>
        </div>

        <div class="group-banner">
            🏘️ Group: <strong>${sessionScope.currentGroupName}</strong>
        </div>

        <c:if test="${param.error eq 'InvalidDateRange'}">
            <div class="error">The "From" date must be on or before the "To" date.</div>
        </c:if>

        <form action="<%= request.getContextPath() %>/withdrawalAudit" method="get">

            <div class="section-title">📅 Date Range (optional)</div>

            <div class="field-row">
                <div class="field">
                    <label for="fromDate">From</label>
                    <input type="date" id="fromDate" name="fromDate"
                           value="${param.fromDate}">
                </div>
                <div class="field">
                    <label for="toDate">To</label>
                    <input type="date" id="toDate" name="toDate"
                           value="${param.toDate}">
                </div>
            </div>
            <div class="help" style="margin-top:-8px;margin-bottom:16px;">
                Leave blank to include all withdrawals up to today.
            </div>

            <div class="section-title">🔍 Status</div>

            <div class="field">
                <label for="status">Filter by Status</label>
                <select id="status" name="status">
                    <option value=""          ${empty param.status                      ? 'selected' : ''}>All statuses</option>
                    <option value="PENDING"   ${param.status eq 'PENDING'   ? 'selected' : ''}>Pending</option>
                    <option value="APPROVED"  ${param.status eq 'APPROVED'  ? 'selected' : ''}>Approved</option>
                    <option value="PAID"      ${param.status eq 'PAID'      ? 'selected' : ''}>Paid</option>
                    <option value="CANCELLED" ${param.status eq 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                </select>
            </div>

            <div class="section-title">📤 Output Format</div>

            <div class="field">
                <label for="format">Format</label>
                <select id="format" name="format">
                    <option value="pdf"  ${param.format eq 'html' ? '' : 'selected'}>PDF (download)</option>
                    <option value="html" ${param.format eq 'html' ? 'selected' : ''}>HTML (view in browser)</option>
                </select>
            </div>

            <button type="submit" class="btn btn-primary">
                📋 Generate Report
            </button>
            <button type="button" class="btn btn-secondary"
                    onclick="window.location.href='<%= request.getContextPath() %>/dashboard.jsp'">
                Cancel
            </button>

        </form>

    </div>

</div>

</body>
</html>