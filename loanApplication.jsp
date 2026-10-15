<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Issue Loan · Timaataba Susu</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            background: linear-gradient(160deg, #f4f6f9 0%, #eaeef4 100%);
            color: #1e2b37; line-height: 1.55;
            min-height: 100vh; padding: 40px 20px;
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
            margin-bottom: 24px; padding-bottom: 20px;
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
        .card-header .sub { color: #6c7a89; font-size: 0.9rem; line-height: 1.65; }
        .card-header .sub b {
            color: #1e8449; background: #e8f3ee;
            padding: 1px 8px; border-radius: 20px;
            font-size: 0.92em; font-weight: 600;
        }
        .msg {
            display: flex; align-items: flex-start; gap: 10px;
            padding: 12px 16px; border-radius: 10px;
            font-size: 0.88rem; line-height: 1.5;
            margin-bottom: 20px;
        }
        .msg::before { font-size: 1.05rem; line-height: 1; flex-shrink: 0; }
        .msg.error {
            background: #fdecea; color: #b71c1c;
            border: 1px solid #f5c6cb;
        }
        .msg.error::before { content: "⚠"; }
        .msg.success {
            background: #e8f3ee; color: #1e8449;
            border: 1px solid #cfeadd;
        }
        .msg.success::before { content: "✓"; }
        .field { margin-bottom: 16px; }
        label {
            display: block; font-size: 0.85rem; font-weight: 600;
            color: #34495e; margin-bottom: 6px;
        }
        label .req { color: #b71c1c; margin-left: 3px; }
        label .hint { color: #95a5a6; font-weight: 400; font-size: 0.88em; margin-left: 4px; }
        input, select {
            width: 100%; padding: 12px 14px;
            border: 1px solid #d7dfe7; border-radius: 10px;
            font-size: 0.95rem; font-family: inherit;
            color: #1e2b37; background: #fbfcfd;
            transition: border-color 0.15s, box-shadow 0.15s;
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
        .group-highlight {
            background: linear-gradient(135deg, #f0f9f4, #e6f4ec);
            border: 1px solid #cfeadd; border-radius: 12px;
            padding: 16px 18px; margin-bottom: 20px;
        }
        .group-highlight label {
            color: #1e8449; font-weight: 700; margin-bottom: 8px; font-size: 0.88rem;
        }
        .group-highlight select {
            background: #fff; border-color: #cfeadd; font-weight: 600;
        }
        .group-highlight .note {
            font-size: 0.75rem; color: #1e8449; margin-top: 6px; opacity: 0.85;
        }
        .input-wrap { position: relative; }
        .input-wrap .prefix {
            position: absolute; left: 14px; top: 50%;
            transform: translateY(-50%);
            color: #95a5a6; font-size: 0.9rem; font-weight: 600;
            pointer-events: none;
        }
        .input-wrap input { padding-left: 52px; }
        input[type="number"]::-webkit-outer-spin-button,
        input[type="number"]::-webkit-inner-spin-button {
            -webkit-appearance: none; margin: 0;
        }
        input[type="number"] { -moz-appearance: textfield; }
        .preview {
            margin-top: 6px;
            margin-bottom: 18px;
            padding: 16px 20px;
            background: linear-gradient(135deg, #eef7ff 0%, #e5f2fd 100%);
            border: 1px solid #c9e3f7;
            border-radius: 12px;
            font-size: 0.9rem;
            color: #1f6390;
            line-height: 1.7;
            display: none;
            position: relative;
            padding-left: 52px;
        }
        .preview.show { display: block; }
        .preview::before {
            content: "💡";
            position: absolute; left: 18px; top: 16px;
            font-size: 1.3rem; line-height: 1;
        }
        .preview b { color: #154a6e; }
        .btn-primary {
            width: 100%; padding: 13px 20px;
            margin-top: 8px;
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff; border: none; border-radius: 10px;
            font-size: 0.98rem; font-weight: 600; cursor: pointer;
            box-shadow: 0 6px 16px -6px rgba(39,174,96,0.5);
            transition: transform 0.1s, box-shadow 0.2s;
        }
        .btn-primary:hover { background: linear-gradient(135deg, #219150, #196b39); }
        .btn-primary:active { transform: translateY(1px); }
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
        <a href="${pageContext.request.contextPath}/loanServlet?operation=viewFund"
           class="back-link">
            ← Back to Loan Fund
        </a>
    </div>

    <div class="card">

        <div class="card-header">
            <h2>
                <span class="icon">📝</span>
                Issue a Loan
            </h2>
            <p class="sub">
                Loans are drawn from the loan fund. The interest rate is fixed by the group,
                and the repayment period cannot exceed <b>6 months</b>.
            </p>
        </div>

        <c:if test="${not empty param.message}">
            <div class="msg error"><c:out value="${param.message}"/></div>
        </c:if>
        <c:if test="${not empty param.success}">
            <div class="msg success"><c:out value="${param.success}"/></div>
        </c:if>

        <form action="<%= request.getContextPath() %>/loanServlet" method="post" id="loanForm">
            <input type="hidden" name="operation" value="issue" />

            <!-- GROUP DROPDOWN (informational — serverside still uses session group) -->
            <div class="group-highlight">
                <label for="groupId">🏘️ Group</label>
                <select id="groupId" name="groupId" disabled>
                    <c:forEach var="g" items="${groups}">
                        <option value="${g.id}"
                            ${g.id == selectedGroupId ? 'selected' : ''}>
                            ${g.groupName}<c:if test="${not empty g.location}"> · ${g.location}</c:if>
                        </option>
                    </c:forEach>
                </select>
                <div class="note">
                    Switch groups via the topbar dropdown on the dashboard.
                    The loan will be issued under this group.
                </div>
            </div>

            <div class="field">
                <label for="PhoneNumber">Member Phone Number <span class="req">*</span></label>
                <input type="text" name="PhoneNumber" id="PhoneNumber"
                       placeholder="e.g. 0244000001"
                       autocomplete="off" required />
            </div>

            <div class="field">
                <label for="principal">Principal Amount</label>
                <div class="input-wrap">
                    <span class="prefix">GHS</span>
                    <input type="number" step="0.01" min="0.01"
                           name="principal" id="principal"
                           class="with-prefix"
                           placeholder="0.00"
                           required />
                </div>
            </div>

            <div class="field">
                <label for="months">Duration <span class="hint">(max 6 months)</span></label>
                <select name="months" id="months" required>
                    <option value="">— Select duration —</option>
                    <option value="1">1 month</option>
                    <option value="2">2 months</option>
                    <option value="3">3 months</option>
                    <option value="4">4 months</option>
                    <option value="5">5 months</option>
                    <option value="6">6 months</option>
                </select>
            </div>

            <div class="preview" id="preview"></div>

            <button type="submit" class="btn-primary">
                Issue Loan →
            </button>
        </form>

    </div>

</div>

<c:set var="rate" value="${empty interestRate ? 0.10 : interestRate}" />

<script>
    const RATE = ${rate};

    const principalInput = document.getElementById('principal');
    const monthsInput    = document.getElementById('months');
    const preview        = document.getElementById('preview');

    function updatePreview() {
        const p = parseFloat(principalInput.value);
        const m = parseInt(monthsInput.value, 10);
        if (!p || p <= 0 || !m) {
            preview.classList.remove('show');
            preview.innerHTML = '';
            return;
        }
        const interest = p * RATE;
        const total    = p + interest;
        preview.innerHTML =
            "<b>Loan Preview</b><br/>" +
            "Interest (" + (RATE * 100).toFixed(2) + "%): GHS " + interest.toFixed(2) + "<br/>" +
            "Total to repay in " + m + " month(s): <b>GHS " + total.toFixed(2) + "</b>";
        preview.classList.add('show');
    }

    principalInput.addEventListener('input', updatePreview);
    monthsInput.addEventListener('change', updatePreview);
</script>

</body>
</html>