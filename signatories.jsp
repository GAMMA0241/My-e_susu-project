<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Signatories Setup · Timaataba Susu</title>
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
        .card-header .sub {
            color: #6c7a89; font-size: 0.9rem; margin-top: 8px;
        }
        .group-banner {
            background: linear-gradient(135deg, #f0f9f4, #e6f4ec);
            border: 1px solid #cfeadd; border-radius: 10px;
            padding: 12px 16px; margin-bottom: 20px;
            font-size: 0.88rem; color: #1e8449; font-weight: 600;
        }
        .signatory-block {
            background: #f8fafc;
            border: 1px solid #e6edf3;
            border-radius: 12px;
            padding: 20px 22px 8px;
            margin-bottom: 18px;
        }
        .signatory-block .slot-badge {
            display: inline-flex; align-items: center; gap: 6px;
            background: #e8f3ee; color: #1e8449;
            border: 1px solid #cfeadd;
            padding: 4px 12px; border-radius: 999px;
            font-size: 0.72rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.06em;
            margin-bottom: 14px;
        }
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
            transition: border-color 0.15s, box-shadow 0.15s;
        }
        input:focus {
            outline: none; border-color: #27ae60; background: #fff;
            box-shadow: 0 0 0 3px rgba(39,174,96,0.15);
        }
        input::placeholder { color: #b0bcc7; }
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
            .signatory-block { padding: 16px 16px 4px; }
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
                <span class="icon">✍️</span>
                Group Signatories
            </h2>
            <p class="sub">Two members who sign on behalf of the group.</p>
        </div>

        <div class="group-banner">
            🏘️ Setting up for: <strong>${sessionScope.currentGroupName}</strong>
        </div>

        <c:if test="${param.saved eq '1'}">
            <div class="success">Signatories saved successfully.</div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="error">${error}</div>
        </c:if>

        <form action="<%= request.getContextPath() %>/signatories" method="post">

            <!-- =============== SIGNATORY 1 =============== -->
            <div class="signatory-block">
                <div class="slot-badge">● Signatory 1</div>

                <div class="field">
                    <label for="name1">Full Name</label>
                    <input type="text" id="name1" name="name1"
                           placeholder="e.g. Kwaku Ágyemang"
                           autocomplete="off" required>
                </div>

                <div class="field">
                    <label for="phone1">Phone Number</label>
                    <input type="text" id="phone1" name="phone1"
                           placeholder="e.g. 0244 123 456"
                           autocomplete="off" required>
                </div>

                <div class="field">
                    <label for="position1">Position</label>
                    <input type="text" id="position1" name="position1"
                           placeholder="e.g. Chairman"
                           autocomplete="off" required>
                </div>
            </div>

            <!-- =============== SIGNATORY 2 =============== -->
            <div class="signatory-block">
                <div class="slot-badge">● Signatory 2</div>

                <div class="field">
                    <label for="name2">Full Name</label>
                    <input type="text" id="name2" name="name2"
                           placeholder="e.g. Ama Mensah"
                           autocomplete="off" required>
                </div>

                <div class="field">
                    <label for="phone2">Phone Number</label>
                    <input type="text" id="phone2" name="phone2"
                           placeholder="e.g. 0201 987 654"
                           autocomplete="off" required>
                </div>

                <div class="field">
                    <label for="position2">Position</label>
                    <input type="text" id="position2" name="position2"
                           placeholder="e.g. Treasurer"
                           autocomplete="off" required>
                </div>
            </div>

            <button type="submit" class="btn btn-primary">
                💾 Save Signatories
            </button>

        </form>

    </div>

</div>

</body>
</html>