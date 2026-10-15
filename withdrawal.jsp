<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fund Withdrawal · Timaataba Susu</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            background: linear-gradient(160deg, #f4f6f9 0%, #eaeef4 100%);
            color: #1e2b37; min-height: 100vh; padding: 40px 20px; line-height: 1.55;
        }
        .container { max-width: 620px; margin: 0 auto; }
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
            margin-bottom: 26px; padding-bottom: 20px;
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
        .card-header .sub { color: #6c7a89; font-size: 0.9rem; }
        .msg {
            display: flex; align-items: flex-start; gap: 10px;
            padding: 12px 16px; border-radius: 10px;
            font-size: 0.88rem; margin-bottom: 20px;
        }
        .msg.error { background: #fdecea; color: #b71c1c; border: 1px solid #f5c6cb; }
        .msg.error::before { content: "⚠"; font-weight: 700; }
        .msg.success { background: #e8f3ee; color: #1e8449; border: 1px solid #cfeadd; }
        .msg.success::before { content: "✓"; font-weight: 700; }
        .field { margin-bottom: 16px; }
        label {
            display: block; font-size: 0.85rem; font-weight: 600;
            color: #34495e; margin-bottom: 6px;
        }
        input {
            width: 100%; padding: 12px 14px;
            border: 1px solid #d7dfe7; border-radius: 10px;
            font-size: 0.95rem; font-family: inherit;
            color: #1e2b37; background: #fbfcfd;
        }
        input:focus {
            outline: none; border-color: #27ae60; background: #fff;
            box-shadow: 0 0 0 3px rgba(39,174,96,0.15);
        }
        .btn {
            display: inline-flex; align-items: center; justify-content: center;
            gap: 8px; padding: 13px 22px; border-radius: 10px;
            font-size: 0.95rem; font-weight: 600;
            cursor: pointer; border: none; font-family: inherit;
            width: 100%; margin-top: 12px;
        }
        .btn-primary {
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff;
            box-shadow: 0 6px 16px -6px rgba(39,174,96,0.5);
        }
        .btn-primary:hover { background: linear-gradient(135deg, #219150, #196b39); }
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
        <a href="<%= request.getContextPath() %>/withdrawalServlet?operation=list" class="back-link">
            📋 All Requests
        </a>
    </div>

    <div class="card">

        <div class="card-header">
            <h2>
                <span class="icon">💸</span>
                Fund Withdrawal / Transfer
            </h2>
            <p class="sub">
                Enter the member's phone number to check fund status and choose
                <b>Maturity</b>, <b>Termination</b>, or <b>Transfer</b>.
            </p>
        </div>

        <c:if test="${not empty error}">
            <div class="msg error">${error}</div>
        </c:if>
        <c:if test="${not empty param.message}">
            <div class="msg success">${param.message}</div>
        </c:if>

        <form method="get" action="<%= request.getContextPath() %>/withdrawalServlet">
            <input type="hidden" name="operation" value="lookup" />

            <div class="field">
                <label for="phoneNumber">Member Phone Number</label>
                <input type="text" id="phoneNumber" name="phoneNumber"
                       placeholder="e.g. 0244 123 456"
                       autocomplete="off" required autofocus>
            </div>

            <button type="submit" class="btn btn-primary">
                Check Fund Status →
            </button>
        </form>

    </div>

</div>

</body>
</html>