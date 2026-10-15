<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login · Timaataba Susu</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, "Segoe UI", Roboto, Arial, sans-serif;
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            min-height: 100vh;
            display: flex; align-items: center; justify-content: center; padding: 20px;
        }
        .card {
            background: #fff; width: 100%; max-width: 400px;
            padding: 40px 32px; border-radius: 12px;
            box-shadow: 0 20px 40px rgba(0,0,0,.2);
        }
        h1 { font-size: 24px; color: #1e3c72; text-align: center; margin-bottom: 8px; }
        .sub { text-align: center; color: #666; font-size: 14px; margin-bottom: 24px; }
        .group { margin-bottom: 16px; }
        label { display: block; font-size: 13px; color: #333; margin-bottom: 6px; font-weight: 600; }
        input {
            width: 100%; padding: 11px 14px; border: 1px solid #ccc;
            border-radius: 8px; font-size: 14px;
        }
        input:focus { outline: none; border-color: #2a5298; box-shadow: 0 0 0 3px rgba(42,82,152,.15); }
        button {
            width: 100%; padding: 12px; background: #2a5298; color: #fff;
            border: none; border-radius: 8px; font-size: 15px; font-weight: 600; cursor: pointer;
        }
        button:hover { background: #1e3c72; }
        .error {
            background: #fdecea; color: #b71c1c; border: 1px solid #f5c6cb;
            padding: 10px 12px; border-radius: 8px; font-size: 13px; margin-bottom: 16px;
        }
        .success {
            background: #e8f5e9; color: #1b5e20; border: 1px solid #c8e6c9;
            padding: 10px 12px; border-radius: 8px; font-size: 13px; margin-bottom: 16px;
        }
        .footer { text-align: center; margin-top: 18px; font-size: 13px; color: #555; }
        .footer a { color: #2a5298; text-decoration: none; font-weight: 600; }

        /* ---------- LOGOUT TOAST ---------- */
        .logout-toast {
            position: fixed;
            top: 24px;
            left: 50%;
            transform: translateX(-50%) translateY(-100px);
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #ffffff;
            padding: 14px 24px;
            border-radius: 10px;
            font-size: 0.92rem;
            font-weight: 600;
            box-shadow: 0 10px 24px -8px rgba(39, 174, 96, 0.55);
            z-index: 10000;
            animation: toastSlideDown 0.4s cubic-bezier(0.2, 0.9, 0.4, 1.15) forwards,
                       toastSlideUp 0.4s ease 3s forwards;
        }

        @keyframes toastSlideDown {
            to { transform: translateX(-50%) translateY(0); }
        }

        @keyframes toastSlideUp {
            to {
                transform: translateX(-50%) translateY(-100px);
                opacity: 0;
            }
        }
    </style>
</head>
<body>

    <%-- ============================================== --%>
    <%-- LOGOUT SUCCESS TOAST — shows after logout     --%>
    <%-- ============================================== --%>
    <c:if test="${param.logout eq 'success'}">
        <div class="logout-toast" id="logoutToast">
            ✓ You have been logged out successfully
        </div>

        <script>
            // clean the URL so refresh doesn't re-show the toast
            setTimeout(() => {
                history.replaceState({}, '', '<%= request.getContextPath() %>/index.jsp');
            }, 3500);
        </script>
    </c:if>

    <div class="card">
        <h1>Welcome Back</h1>
        <p class="sub">Sign in to your account</p>

        <%-- Success message after signup --%>
        <% if ("1".equals(request.getParameter("registered"))) { %>
            <div class="success">Account created. Please sign in.</div>
        <% } %>

        <%-- Error message --%>
        <% String error = (String) request.getAttribute("error");
           if (error != null) { %>
            <div class="error"><%= error %></div>
        <% } %>

        <form action="<%= request.getContextPath() %>/login" method="post" autocomplete="off">
            <div class="group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username"
                       value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>"
                       placeholder="Enter your username" required autofocus>
            </div>
            <div class="group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password"
                       placeholder="Enter your password" required>
            </div>
            <button type="submit">Sign In</button>
        </form>

        <p class="footer">
            Don't have an account?
            <a href="<%= request.getContextPath() %>/signup.jsp">Sign up</a>
        </p>
    </div>

</body>
</html>