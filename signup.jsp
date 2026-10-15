<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account · Timaataba Susu</title>
    <style>
        :root {
            --primary:        #27ae60;
            --primary-dark:   #1e8449;
            --primary-light:  #e8f3ee;
            --primary-border: #cfeadd;
            --danger:         #b71c1c;
            --danger-bg:      #fdecea;
            --danger-border:  #f5c6cb;
            --text:           #1e2b37;
            --muted:          #6c7a89;
            --border:         #d7dfe7;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
                         "Helvetica Neue", Arial, sans-serif;
            background: linear-gradient(135deg, #1e2b3c 0%, #2c4057 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            -webkit-font-smoothing: antialiased;
        }

        .card {
            background: #ffffff;
            width: 100%;
            max-width: 440px;
            padding: 40px 36px 34px;
            border-radius: 18px;
            box-shadow: 0 24px 60px -20px rgba(0, 0, 0, 0.35),
                        0 8px 20px -10px rgba(0, 0, 0, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.6);
        }

        /* ---------- HEADER ---------- */
        .header {
            text-align: center;
            margin-bottom: 28px;
        }

        .header .icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 54px;
            height: 54px;
            border-radius: 14px;
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: #fff;
            font-size: 1.5rem;
            margin-bottom: 14px;
            box-shadow: 0 8px 20px -6px rgba(39, 174, 96, 0.5);
        }

        .header h1 {
            font-size: 1.5rem;
            font-weight: 600;
            letter-spacing: -0.02em;
            color: #1e2b3c;
            margin-bottom: 6px;
        }

        .header .sub {
            color: var(--muted);
            font-size: 0.9rem;
            line-height: 1.5;
        }

        /* ---------- ERROR ---------- */
        .error {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            background: var(--danger-bg);
            color: var(--danger);
            border: 1px solid var(--danger-border);
            border-radius: 10px;
            padding: 12px 16px;
            font-size: 0.88rem;
            line-height: 1.5;
            margin-bottom: 20px;
        }
        .error::before {
            content: "⚠";
            font-size: 1.05rem;
            line-height: 1;
            flex-shrink: 0;
        }

        /* ---------- FORM ---------- */
        .group { margin-bottom: 16px; }

        label {
            display: block;
            font-size: 0.85rem;
            font-weight: 600;
            color: #34495e;
            margin-bottom: 6px;
        }

        input[type="text"],
        input[type="password"] {
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

        input[type="text"]:focus,
        input[type="password"]:focus {
            outline: none;
            border-color: var(--primary);
            background: #ffffff;
            box-shadow: 0 0 0 3px rgba(39, 174, 96, 0.15);
        }

        input::placeholder { color: #b0bcc7; }

        /* ---------- BUTTON ---------- */
        button {
            width: 100%;
            padding: 13px 20px;
            margin-top: 10px;
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
        button:hover {
            background: linear-gradient(135deg, #219150, #196b39);
            box-shadow: 0 10px 22px -8px rgba(39, 174, 96, 0.55);
        }
        button:active { transform: translateY(1px); }
        button:focus-visible {
            outline: 2px solid var(--primary);
            outline-offset: 3px;
        }

        /* ---------- FOOTER ---------- */
        .footer {
            text-align: center;
            margin-top: 22px;
            padding-top: 20px;
            border-top: 1px solid #eef2f6;
            font-size: 0.88rem;
            color: var(--muted);
        }

        .footer a {
            color: var(--primary-dark);
            text-decoration: none;
            font-weight: 600;
            margin-left: 4px;
            transition: color 0.15s;
        }
        .footer a:hover {
            color: var(--primary);
            text-decoration: underline;
        }

        /* ---------- RESPONSIVE ---------- */
        @media (max-width: 460px) {
            .card { padding: 32px 24px 26px; border-radius: 14px; }
            .header h1 { font-size: 1.3rem; }
            .header .icon { width: 48px; height: 48px; font-size: 1.3rem; }
        }
    </style>
</head>
<body>

<div class="card">

    <div class="header">
        <div class="icon">✨</div>
        <h1>Create Account</h1>
        <p class="sub">Sign up to get started with Timaataba Susu</p>
    </div>

    <%-- Show error if servlet forwarded one --%>
    <% String error = (String) request.getAttribute("error");
       if (error != null) { %>
        <div class="error"><%= error %></div>
    <% } %>

    <form action="<%= request.getContextPath() %>/signup" method="post" autocomplete="off">

        <div class="group">
            <label for="fullName">Full Name</label>
            <input type="text" id="fullName" name="fullName"
                   value="<%= request.getAttribute("fullName") != null ? request.getAttribute("fullName") : "" %>"
                   placeholder="e.g. John Doe"
                   autocomplete="off" required>
        </div>

        <div class="group">
            <label for="username">Username</label>
            <input type="text" id="username" name="username"
                   value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>"
                   placeholder="Choose a username"
                   autocomplete="off" required>
        </div>

        <div class="group">
            <label for="password">Password</label>
            <input type="password" id="password" name="password"
                   placeholder="At least 6 characters"
                   minlength="6" required>
        </div>

        <div class="group">
            <label for="confirm">Confirm Password</label>
            <input type="password" id="confirm" name="confirm"
                   placeholder="Re-enter password"
                   minlength="6" required>
        </div>

        <button type="submit">Create Account →</button>
    </form>

    <p class="footer">
        Already have an account?
        <a href="<%= request.getContextPath() %>/index.jsp">Sign in</a>
    </p>

</div>

</body>
</html>