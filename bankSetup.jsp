<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bank &amp; Fees Setup · Timaataba Susu</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            background: linear-gradient(160deg, #f4f6f9 0%, #eaeef4 100%);
            color: #1e2b37; min-height: 100vh; padding: 40px 20px; line-height: 1.55;
        }
        .container { max-width: 620px; margin: 0 auto; }
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
        .group-banner {
            background: linear-gradient(135deg, #f0f9f4, #e6f4ec);
            border: 1px solid #cfeadd; border-radius: 10px;
            padding: 12px 16px; margin-bottom: 20px;
            font-size: 0.88rem; color: #1e8449; font-weight: 600;
        }
        .section-title {
            font-size: 0.75rem; font-weight: 700; text-transform: uppercase;
            letter-spacing: 0.08em; color: #6c7a89;
            margin: 24px 0 12px; padding-bottom: 8px;
            border-bottom: 1px solid #eef2f6;
        }
        .section-title:first-of-type { margin-top: 0; }
        .field { margin-bottom: 16px; }
        label {
            display: block; font-size: 0.85rem; font-weight: 600;
            color: #34495e; margin-bottom: 6px;
        }
        input, select {
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
        input::placeholder { color: #b0bcc7; }
        select {
            appearance: none; -webkit-appearance: none;
            background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'><path fill='%236c7a89' d='M6 8 0 0h12z'/></svg>");
            background-repeat: no-repeat;
            background-position: right 16px center;
            padding-right: 40px; cursor: pointer;
        }
        .btn {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 13px 22px; border-radius: 10px;
            font-size: 0.95rem; font-weight: 600;
            cursor: pointer; border: none; font-family: inherit;
            width: 100%; justify-content: center;
            margin-top: 14px;
            transition: transform 0.1s, box-shadow 0.2s, background 0.2s;
        }
        .btn-primary {
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff;
            box-shadow: 0 6px 16px -6px rgba(39,174,96,0.5);
        }
        .btn-primary:hover { background: linear-gradient(135deg, #219150, #196b39); }
        .btn-primary:active { transform: translateY(1px); }
        .success {
            display: flex; align-items: flex-start; gap: 10px;
            background: #e8f3ee; color: #1e8449;
            border: 1px solid #cfeadd; border-radius: 10px;
            padding: 12px 16px; font-size: 0.9rem;
            margin-bottom: 20px;
        }
        .success::before { content: "✓"; font-weight: 700; }
        @media (max-width: 540px) {
            body { padding: 24px 14px; }
            .card { padding: 26px 22px; }
            .card-header h2 { font-size: 1.25rem; }
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
                <span class="icon">🏦</span>
                Bank &amp; Fees Setup
            </h2>
        </div>

        <div class="group-banner">
            🏘️ Setting up for: <strong>${sessionScope.currentGroupName}</strong>
        </div>

        <c:if test="${param.saved eq '1'}">
            <div class="success">Bank &amp; fees setup saved successfully.</div>
        </c:if>

        <form action="<%= request.getContextPath() %>/bankSetup" method="post">

            <div class="section-title">🏦 Bank Details</div>

            <div class="field">
                <label for="bankName">Bank Name</label>
                <input type="text" id="bankName" name="bankName"
                       placeholder="e.g. GCB Bank" required>
            </div>

            <div class="field">
                <label for="bankBranch">Branch</label>
                <input type="text" id="bankBranch" name="bankBranch"
                       placeholder="e.g. Bolgatanga Main" required>
            </div>

            <div class="section-title">💳 Account Details</div>

            <div class="field">
                <label for="accountName">Account Name</label>
                <input type="text" id="accountName" name="accountName"
                       placeholder="e.g. Timaataba Susu Group" required>
            </div>

            <div class="field">
                <label for="accountNumber">Account Number</label>
                <input type="text" id="accountNumber" name="accountNumber"
                       placeholder="e.g. 1234567890123" required>
            </div>

            <div class="field">
                <label for="accountType">Account Type</label>
                <select id="accountType" name="accountType">
                    <option value="" disabled selected>-- Select account type --</option>
                    <option value="SAVINGS">Savings</option>
                    <option value="CURRENT">Current</option>
                    <option value="FIXED">Fixed Deposit</option>
                </select>
            </div>

            <div class="section-title">💰 Year-End Fees (GHS)</div>

            <div class="field">
                <label for="feeMaintenance">Maintenance Fee</label>
                <input type="number" step="0.01" min="0"
                       id="feeMaintenance" name="feeMaintenance"
                       placeholder="0.00">
            </div>

            <div class="field">
                <label for="feeService">Service Fee</label>
                <input type="number" step="0.01" min="0"
                       id="feeService" name="feeService"
                       placeholder="0.00">
            </div>

            <div class="field">
                <label for="feeOther">Other Fee</label>
                <input type="number" step="0.01" min="0"
                       id="feeOther" name="feeOther"
                       placeholder="0.00">
            </div>

            <button type="submit" class="btn btn-primary">
                💾 Save Setup
            </button>

        </form>

    </div>

</div>

</body>
</html>