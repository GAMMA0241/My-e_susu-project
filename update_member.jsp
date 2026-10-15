<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Member Bio Data · Timaataba Susu</title>
    <style>
        :root {
            --primary:        #27ae60;
            --primary-dark:   #1e8449;
            --primary-light:  #e8f3ee;
            --primary-border: #cfeadd;
            --danger:         #b71c1c;
            --danger-bg:      #fdecea;
            --danger-border:  #f5c6cb;
            --info:           #1f6390;
            --info-bg:        #e7f4fd;
            --info-border:    #c3e2f5;
            --text:           #1e2b37;
            --muted:          #6c7a89;
            --border:         #d7dfe7;
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

        .container { max-width: 580px; margin: 0 auto; }

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
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: #fff;
            font-size: 1.1rem;
            flex-shrink: 0;
        }

        .card-header .sub {
            color: var(--muted);
            font-size: 0.9rem;
            line-height: 1.65;
        }

        /* ---------- INFO BANNER ---------- */
        .info-banner {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            background: linear-gradient(135deg, #eef7f2 0%, #e6f4ec 100%);
            border: 1px solid var(--primary-border);
            border-radius: 12px;
            padding: 14px 18px;
            margin-bottom: 24px;
            font-size: 0.86rem;
            color: var(--primary-dark);
            line-height: 1.55;
        }
        .info-banner .icon-circle {
            flex-shrink: 0;
            width: 22px;
            height: 22px;
            border-radius: 50%;
            background: var(--primary);
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.75rem;
            font-weight: 700;
        }

        /* ---------- MESSAGES ---------- */
        .msg {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            padding: 12px 16px;
            border-radius: 10px;
            font-size: 0.88rem;
            line-height: 1.5;
            margin-bottom: 20px;
        }
        .msg::before {
            font-size: 1.05rem;
            line-height: 1;
            flex-shrink: 0;
        }
        .msg.error {
            background: var(--danger-bg);
            color: var(--danger);
            border: 1px solid var(--danger-border);
        }
        .msg.error::before { content: "⚠"; }

        .msg.success {
            background: var(--primary-light);
            color: var(--primary-dark);
            border: 1px solid var(--primary-border);
        }
        .msg.success::before { content: "✓"; }

        /* ---------- FORM ---------- */
        .field { margin-bottom: 16px; }

        label {
            display: block;
            font-size: 0.85rem;
            font-weight: 600;
            color: #34495e;
            margin-bottom: 6px;
        }

        label .req  { color: var(--danger); margin-left: 3px; }
        label .opt  {
            color: #95a5a6;
            font-weight: 400;
            font-size: 0.88em;
            margin-left: 4px;
        }
        label .hint {
            color: #95a5a6;
            font-weight: 400;
            font-size: 0.88em;
            margin-left: 4px;
        }

        input[type="text"] {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid var(--border);
            border-radius: 10px;
            font-size: 0.95rem;
            font-family: inherit;
            color: var(--text);
            background: #fbfcfd;
            transition: border-color 0.15s, box-shadow 0.15s, background 0.15s;
        }

        input[type="text"]:focus {
            outline: none;
            border-color: var(--primary);
            background: #ffffff;
            box-shadow: 0 0 0 3px rgba(39, 174, 96, 0.15);
        }

        input::placeholder { color: #b0bcc7; }

        /* ---------- BUTTON ---------- */
        .btn-primary {
            width: 100%;
            padding: 13px 20px;
            margin-top: 12px;
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
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
            outline: 2px solid var(--primary);
            outline-offset: 3px;
        }

        /* ---------- RESPONSIVE ---------- */
        @media (max-width: 540px) {
            body { padding: 24px 14px; }
            .card { padding: 26px 22px; border-radius: 14px; }
            .card-header h2 { font-size: 1.25rem; }
            .card-header .icon { width: 32px; height: 32px; font-size: 1rem; }
            .topnav { flex-direction: column; align-items: stretch; }
            .back-link { justify-content: center; }
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
                <span class="icon">✏️</span>
                Update Member Bio Data
            </h2>
            <p class="sub">
                Enter the member's phone number to identify them, then update only
                the fields you want to change.
            </p>
        </div>

        <!-- ---------- INFO BANNER ---------- -->
        <div class="info-banner">
            <span class="icon-circle">i</span>
            <span>
                Only the fields you fill in will be updated.
                Leave a field blank to keep its current value.
            </span>
        </div>

        <!-- ---------- MESSAGES ---------- -->
        <c:if test="${not empty message}">
            <div class="msg error">${message}</div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="msg success">${success}</div>
        </c:if>

        <!-- ---------- FORM ---------- -->
        <form action="memberServlet" method="post">
            <input type="hidden" name="operation" value="UpdateBiodata" />

            <div class="field">
                <label for="phoneNumber">
                    Phone Number <span class="req">*</span>
                    <span class="hint">(identifies the member)</span>
                </label>
                <input type="text" name="phoneNumber" id="phoneNumber"
                       placeholder="e.g. 0244 123 456"
                       autocomplete="off" required />
            </div>

            <div class="field">
                <label for="fullName">
                    New Full Name <span class="opt">(optional)</span>
                </label>
                <input type="text" name="fullName" id="fullName"
                       placeholder="Leave blank to keep current"
                       autocomplete="off" />
            </div>

            <div class="field">
                <label for="ghanaCardNumber">
                    New Ghana Card Number <span class="opt">(optional)</span>
                    <span class="hint">(e.g. GHA-123456789-0)</span>
                </label>
                <input type="text" name="ghanaCardNumber" id="ghanaCardNumber"
                       placeholder="Leave blank to keep current"
                       autocomplete="off" />
            </div>

            <div class="field">
                <label for="emergencyContact">
                    New Emergency Contact <span class="opt">(optional)</span>
                </label>
                <input type="text" name="emergencyContact" id="emergencyContact"
                       placeholder="Leave blank to keep current"
                       autocomplete="off" />
            </div>

            <button type="submit" class="btn-primary">
                Update Bio Data →
            </button>
        </form>

    </div>

</div>

</body>
</html>