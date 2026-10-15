<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Withdrawal Requests · Timaataba Susu</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            background: linear-gradient(160deg, #f4f6f9 0%, #eaeef4 100%);
            color: #1e2b37; min-height: 100vh; padding: 40px 20px; line-height: 1.55;
        }
        .container { max-width: 1280px; margin: 0 auto; }
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
            color: #1e2b3c; display: flex; align-items: center; gap: 10px;
        }
        .card-header .icon {
            display: inline-flex; align-items: center; justify-content: center;
            width: 38px; height: 38px; border-radius: 10px;
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff; font-size: 1.1rem;
        }
        .msg {
            display: flex; align-items: flex-start; gap: 10px;
            padding: 12px 16px; border-radius: 10px;
            font-size: 0.88rem; margin-bottom: 20px;
            background: #e8f3ee; color: #1e8449;
            border: 1px solid #cfeadd;
        }
        .msg::before { content: "✓"; font-weight: 700; }

        .table-wrap {
            overflow-x: auto; border-radius: 12px;
            border: 1px solid #e6edf3; background: #fff;
        }
        table {
            width: 100%; border-collapse: collapse;
            font-size: 0.86rem; min-width: 1120px;
        }
        thead th {
            background: #f8fafc; text-align: left;
            font-weight: 700; color: #475569;
            font-size: 0.68rem; text-transform: uppercase;
            letter-spacing: 0.06em;
            padding: 14px 12px;
            border-bottom: 1px solid #e6edf3;
            white-space: nowrap;
        }
        tbody td {
            padding: 14px 12px;
            border-bottom: 1px solid #eef2f6;
            color: #2c3e50;
            vertical-align: middle;
        }
        tbody tr:last-child td { border-bottom: none; }
        tbody tr:hover { background: #f9fbfd; }

        td.num { text-align: right; font-variant-numeric: tabular-nums; white-space: nowrap; }
        td.amount { color: #1e8449; font-weight: 700; text-align: right; }
        td.penalty { color: #b71c1c; font-weight: 600; text-align: right; }

        .badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 4px 10px; border-radius: 999px;
            font-size: 0.7rem; font-weight: 700;
            white-space: nowrap;
        }
        .badge::before { content: ""; width: 6px; height: 6px; border-radius: 50%; }

        .badge.MATURITY    { background: #e7f1ff; color: #1f6390; border: 1px solid #c9e3f7; }
        .badge.MATURITY::before { background: #1f6390; }
        .badge.TERMINATION { background: #fdecea; color: #b71c1c; border: 1px solid #f5c6cb; }
        .badge.TERMINATION::before { background: #b71c1c; }
        .badge.TRANSFER    { background: #f3e8ff; color: #5b21b6; border: 1px solid #ddd6fe; }
        .badge.TRANSFER::before { background: #7c3aed; }

        .status {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 4px 10px; border-radius: 999px;
            font-size: 0.7rem; font-weight: 700;
            white-space: nowrap;
        }
        .status::before { content: ""; width: 6px; height: 6px; border-radius: 50%; }
        .status.PENDING   { background: #fff4e6; color: #b45309; border: 1px solid #ffddb3; }
        .status.PENDING::before { background: #b45309; }
        .status.PAID      { background: #e8f3ee; color: #1e8449; border: 1px solid #cfeadd; }
        .status.PAID::before { background: #1e8449; }
        .status.CANCELLED { background: #eef2f6; color: #6c7a89; border: 1px solid #dce3ea; }
        .status.CANCELLED::before { background: #6c7a89; }

        /* ---------- ACTION BUTTONS ---------- */
        .action-buttons {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
        }

        .btn-mark {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 6px 12px;
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff; border: none; border-radius: 8px;
            font-size: 0.75rem; font-weight: 600;
            cursor: pointer; font-family: inherit;
            white-space: nowrap;
        }
        .btn-mark:hover { background: linear-gradient(135deg, #219150, #196b39); }

        .btn-reject {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 6px 12px;
            background: #fff;
            color: #b71c1c;
            border: 1px solid #f5c6cb;
            border-radius: 8px;
            font-size: 0.75rem; font-weight: 600;
            cursor: pointer; font-family: inherit;
            white-space: nowrap;
            transition: background 0.15s, border-color 0.15s;
        }
        .btn-reject:hover {
            background: #fdecea;
            border-color: #e57373;
        }

        .empty {
            text-align: center; color: #6c7a89;
            padding: 40px 20px; font-size: 0.9rem;
        }
        .empty .icon-big {
            display: block; font-size: 2rem;
            margin-bottom: 10px; opacity: 0.6;
        }

        .dest-cell { font-size: 0.82rem; }
        .dest-cell .lbl {
            color: #6c7a89;
            font-size: 0.72rem;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            display: block;
            margin-bottom: 2px;
        }

        /* ---------- REJECT MODAL ---------- */
        .reject-modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(15,25,35,0.65);
            backdrop-filter: blur(3px);
            z-index: 10000;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .reject-modal-overlay.show { display: flex; }

        .reject-modal {
            background: #fff;
            border-radius: 16px;
            max-width: 420px;
            width: 100%;
            padding: 28px 32px 24px;
            box-shadow: 0 24px 60px -20px rgba(0,0,0,0.35);
            animation: rejectPopIn 0.25s cubic-bezier(0.2,0.9,0.4,1.15);
        }

        @keyframes rejectPopIn {
            from { transform: scale(0.9); opacity: 0; }
            to   { transform: scale(1); opacity: 1; }
        }

        .reject-modal h3 {
            font-size: 1.15rem; font-weight: 700;
            color: #b71c1c; margin-bottom: 8px;
            display: flex; align-items: center; gap: 8px;
        }

        .reject-modal p {
            font-size: 0.88rem; color: #6c7a89;
            margin-bottom: 16px; line-height: 1.55;
        }

        .reject-modal label {
            display: block; font-size: 0.8rem;
            font-weight: 600; color: #34495e; margin-bottom: 6px;
        }

        .reject-modal textarea {
            width: 100%; padding: 10px 12px;
            border: 1px solid #d7dfe7; border-radius: 8px;
            font-size: 0.9rem; font-family: inherit;
            resize: vertical; min-height: 70px;
            margin-bottom: 16px;
        }

        .reject-modal textarea:focus {
            outline: none;
            border-color: #b71c1c;
            box-shadow: 0 0 0 3px rgba(183,28,28,0.15);
        }

        .reject-modal-actions {
            display: flex; gap: 10px; justify-content: flex-end;
        }

        .reject-modal-actions button {
            padding: 10px 18px;
            border-radius: 8px;
            font-size: 0.88rem;
            font-weight: 600;
            cursor: pointer;
            border: none;
            font-family: inherit;
        }

        .reject-modal-actions .btn-cancel {
            background: #f1f5f9;
            color: #2c3e50;
            border: 1px solid #e6edf3;
        }
        .reject-modal-actions .btn-cancel:hover { background: #e2e9f0; }

        .reject-modal-actions .btn-confirm {
            background: linear-gradient(135deg, #d32f2f, #b71c1c);
            color: #fff;
        }
        .reject-modal-actions .btn-confirm:hover {
            background: linear-gradient(135deg, #b71c1c, #8c0018);
        }

        @media (max-width: 720px) {
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
        <a href="<%= request.getContextPath() %>/withdrawalServlet" class="back-link">
            ➕ New Request
        </a>
    </div>

    <div class="card">

        <div class="card-header">
            <h2>
                <span class="icon">📋</span>
                Withdrawal / Transfer Requests
            </h2>
        </div>

        <c:if test="${not empty param.message}">
            <div class="msg"><c:out value="${param.message}"/></div>
        </c:if>

        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Type</th>
                        <th>Member</th>
                        <th>Phone</th>
                        <th style="text-align:right">Contribution</th>
                        <th style="text-align:right">Interest</th>
                        <th style="text-align:right">Penalty</th>
                        <th style="text-align:right">Payable</th>
                        <th>Destination</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="r" items="${requests}">
                        <tr>
                            <td>#${r.id}</td>
                            <td><span class="badge ${r.requestType}">${r.requestType}</span></td>
                            <td><c:out value="${r.memberName}"/></td>
                            <td><c:out value="${r.phoneNumber}"/></td>
                            <td class="num">
                                <fmt:formatNumber value="${r.contribution}"
                                                  minFractionDigits="2" maxFractionDigits="2"/>
                            </td>
                            <td class="num">
                                <fmt:formatNumber value="${r.interestShare}"
                                                  minFractionDigits="2" maxFractionDigits="2"/>
                            </td>
                            <td class="penalty">
                                <c:if test="${r.penalty > 0}">
                                    −<fmt:formatNumber value="${r.penalty}"
                                                       minFractionDigits="2" maxFractionDigits="2"/>
                                </c:if>
                            </td>
                            <td class="amount">
                                <fmt:formatNumber value="${r.amountPayable}"
                                                  minFractionDigits="2" maxFractionDigits="2"/>
                            </td>
                            <td class="dest-cell">
                                <c:choose>
                                    <c:when test="${r.requestType eq 'TRANSFER'}">
                                        <span class="lbl">Group</span>
                                        <c:out value="${r.targetGroupName}"/>
                                        <span class="lbl" style="margin-top:6px;">Bank Account</span>
                                        <c:out value="${r.targetBankAccount}"/>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="lbl">MoMo</span>
                                        <c:out value="${r.momoNumber}"/>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <span class="status ${r.status}">${r.status}</span>
                            </td>
                            <td>
                                <c:if test="${r.status eq 'PENDING'}">
                                    <div class="action-buttons">
                                        <form action="<%= request.getContextPath() %>/withdrawalServlet"
                                              method="post" style="display:inline;"
                                              onsubmit="return confirm('Mark this request as PAID? This will process the payout.');">
                                            <input type="hidden" name="operation" value="markPaid" />
                                            <input type="hidden" name="id" value="${r.id}" />
                                            <button type="submit" class="btn-mark">✓ Mark Paid</button>
                                        </form>

                                        <button type="button" class="btn-reject"
                                                onclick="openReject(${r.id})">
                                            ✕ Reject
                                        </button>
                                    </div>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty requests}">
                        <tr>
                            <td colspan="11" class="empty">
                                <span class="icon-big">📭</span>
                                No requests yet for this group.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

    </div>

</div>

<!-- ================= REJECT MODAL ================= -->
<div class="reject-modal-overlay" id="rejectModal">
    <div class="reject-modal">
        <h3>✕ Reject Request</h3>
        <p>
            This will cancel the request without processing any payout.
            The member and their funds remain unchanged.
        </p>

        <form method="post"
              action="<%= request.getContextPath() %>/withdrawalServlet"
              id="rejectForm">
            <input type="hidden" name="operation" value="reject" />
            <input type="hidden" name="id" id="rejectId" />

            <label for="rejectReason">Reason (optional)</label>
            <textarea name="reason" id="rejectReason"
                      placeholder="e.g. Member changed their mind"></textarea>

            <div class="reject-modal-actions">
                <button type="button" class="btn-cancel"
                        onclick="closeReject()">Cancel</button>
                <button type="submit" class="btn-confirm">
                    Reject Request
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    function openReject(id) {
        document.getElementById('rejectId').value = id;
        document.getElementById('rejectReason').value = '';
        document.getElementById('rejectModal').classList.add('show');
        setTimeout(() => document.getElementById('rejectReason').focus(), 100);
    }

    function closeReject() {
        document.getElementById('rejectModal').classList.remove('show');
    }

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            const m = document.getElementById('rejectModal');
            if (m.classList.contains('show')) closeReject();
        }
    });

    document.getElementById('rejectModal').addEventListener('click', function (e) {
        if (e.target === this) closeReject();
    });
</script>

</body>
</html>