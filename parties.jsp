<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Parties · Timaataba Susu</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            background: linear-gradient(160deg, #f4f6f9 0%, #eaeef4 100%);
            color: #1e2b37; line-height: 1.55;
            min-height: 100vh; padding: 40px 20px;
        }
        .container { max-width: 1000px; margin: 0 auto; }

        .topnav {
            display: flex; justify-content: space-between;
            margin-bottom: 20px; flex-wrap: wrap; gap: 10px;
        }
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
            padding: 12px 16px; margin-bottom: 24px;
            font-size: 0.88rem; color: #1e8449; font-weight: 600;
        }

        /* ---------- GRID ---------- */
        .parties-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .party-card {
            background: linear-gradient(135deg, #f8fafc, #f1f5f9);
            border: 1px solid #e6edf3;
            border-radius: 14px;
            padding: 24px 26px 22px;
        }

        .party-card h3 {
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            color: #6c7a89;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .party-card h3 .emoji { font-size: 1.1rem; }

        /* ---------- BANK ROWS ---------- */
        .bank-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            font-size: 0.9rem;
            border-bottom: 1px dashed #dce3ea;
        }
        .bank-row:last-child { border-bottom: none; }
        .bank-row .label { color: #6c7a89; font-weight: 500; }
        .bank-row .value {
            color: #1e2b3c; font-weight: 600;
            text-align: right;
            word-break: break-word;
            max-width: 60%;
            font-variant-numeric: tabular-nums;
        }

        /* ---------- SIGNATORIES ---------- */
        .sig-item {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            padding: 14px 0;
            border-bottom: 1px dashed #dce3ea;
        }
        .sig-item:last-child { border-bottom: none; }

        .sig-avatar {
            width: 44px; height: 44px;
            border-radius: 50%;
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.1rem; font-weight: 700;
            text-transform: uppercase;
            flex-shrink: 0;
            box-shadow: 0 6px 14px -6px rgba(39,174,96,0.5);
        }
        .sig-info { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
        .sig-name { font-weight: 700; color: #1e2b3c; font-size: 0.95rem; }
        .sig-position {
            font-size: 0.75rem; font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            color: #1e8449;
        }
        .sig-phone { font-size: 0.82rem; color: #6c7a89; margin-top: 3px; }

        /* ---------- EMPTY ---------- */
        .party-empty {
            text-align: center;
            padding: 32px 16px;
            color: #6c7a89;
            font-size: 0.88rem;
            background: #fbfcfd;
            border: 1px dashed #cfd9e3;
            border-radius: 10px;
            line-height: 1.7;
        }
        .party-empty .big {
            display: block;
            font-size: 2rem;
            margin-bottom: 8px;
            opacity: 0.55;
        }
        .party-empty a {
            color: #1e8449;
            font-weight: 600;
            text-decoration: none;
        }
        .party-empty a:hover { text-decoration: underline; }

        /* ---------- ACTIONS ---------- */
        .actions {
            display: flex; gap: 12px; flex-wrap: wrap;
            margin-top: 26px;
            padding-top: 22px;
            border-top: 1px solid #eef2f6;
        }
        .btn {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 11px 20px; border-radius: 10px;
            font-size: 0.9rem; font-weight: 600;
            text-decoration: none;
            cursor: pointer;
            border: 1px solid transparent;
            white-space: nowrap;
        }
        .btn-secondary {
            background: #fff; color: #2c3e50;
            border-color: #e6edf3;
        }
        .btn-secondary:hover { background: #f8fafc; border-color: #cfd9e3; }

        @media (max-width: 720px) {
            body { padding: 24px 14px; }
            .card { padding: 26px 22px; }
            .card-header h2 { font-size: 1.25rem; }
            .parties-grid { grid-template-columns: 1fr; }
            .actions { flex-direction: column; }
            .actions .btn { justify-content: center; width: 100%; }
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
                <span class="icon">🏛️</span>
                Parties
            </h2>
            <p class="sub">
                The bank account and signatories responsible for this Susu group.
            </p>
        </div>

        <div class="group-banner">
            🏘️ Group: <strong>${sessionScope.currentGroupName}</strong>
        </div>

        <div class="parties-grid">

            <!-- =============== BANK =============== -->
            <div class="party-card">
                <h3><span class="emoji">🏦</span> Bank Account</h3>

                <c:choose>
                    <c:when test="${empty groupBank or empty groupBank.bankName}">
                        <div class="party-empty">
                            <span class="big">🏦</span>
                            No bank assigned to this group yet.
                            <br/>
                            <a href="${pageContext.request.contextPath}/bankSetup">
                                Set it up →
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="bank-row">
                            <span class="label">Bank</span>
                            <span class="value">${groupBank.bankName}</span>
                        </div>
                        <div class="bank-row">
                            <span class="label">Branch</span>
                            <span class="value">
                                <c:out value="${empty groupBank.bankBranch ? '—' : groupBank.bankBranch}"/>
                            </span>
                        </div>
                        <div class="bank-row">
                            <span class="label">Account Name</span>
                            <span class="value">
                                <c:out value="${empty groupBank.accountName ? '—' : groupBank.accountName}"/>
                            </span>
                        </div>
                        <div class="bank-row">
                            <span class="label">Account Number</span>
                            <span class="value">
                                <c:out value="${empty groupBank.accountNumber ? '—' : groupBank.accountNumber}"/>
                            </span>
                        </div>
                        <div class="bank-row">
                            <span class="label">Type</span>
                            <span class="value">
                                <c:out value="${empty groupBank.accountType ? '—' : groupBank.accountType}"/>
                            </span>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- =============== SIGNATORIES =============== -->
            <div class="party-card">
                <h3><span class="emoji">✍️</span> Signatories</h3>

                <c:choose>
                    <c:when test="${empty signatories}">
                        <div class="party-empty">
                            <span class="big">✍️</span>
                            No signatories set for this group yet.
                            <br/>
                            <a href="${pageContext.request.contextPath}/signatories">
                                Set them up →
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="s" items="${signatories}">
                            <div class="sig-item">
                                <div class="sig-avatar">
                                    <c:out value="${fn:substring(s.fullName, 0, 1)}"/>
                                </div>
                                <div class="sig-info">
                                    <span class="sig-name">
                                        <c:out value="${s.fullName}"/>
                                    </span>
                                    <span class="sig-position">
                                        <c:out value="${s.position}"/>
                                    </span>
                                    <c:if test="${not empty s.phoneNumber}">
                                        <span class="sig-phone">
                                            📞 <c:out value="${s.phoneNumber}"/>
                                        </span>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>

        </div>

        <div class="actions">
            <a class="btn btn-secondary"
               href="${pageContext.request.contextPath}/bankSetup">
                ✏️ Edit Bank &amp; Fees
            </a>
            <a class="btn btn-secondary"
               href="${pageContext.request.contextPath}/signatories">
                ✏️ Edit Signatories
            </a>
        </div>

    </div>

</div>

</body>
</html>