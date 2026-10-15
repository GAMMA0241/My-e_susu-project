<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Withdrawal Options · Timaataba Susu</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            background: linear-gradient(160deg, #f4f6f9 0%, #eaeef4 100%);
            color: #1e2b37; min-height: 100vh; padding: 40px 20px; line-height: 1.55;
        }
        .container { max-width: 720px; margin: 0 auto; }
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

        /* ============ SUMMARY ============ */
        .summary {
            background: linear-gradient(135deg, #f8fafc, #f1f5f9);
            border: 1px solid #e6edf3; border-radius: 12px;
            padding: 20px 22px; margin-bottom: 24px;
        }
        .summary h3 {
            font-size: 0.75rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.08em;
            color: #6c7a89; margin-bottom: 12px;
        }
        .summary .row {
            display: flex; justify-content: space-between; align-items: center;
            padding: 8px 0; font-size: 0.9rem; color: #4a6075;
        }
        .summary .row + .row { border-top: 1px dashed #e2e9f0; }
        .summary .label { font-weight: 500; }
        .summary .value { font-weight: 600; color: #2c3e50; font-variant-numeric: tabular-nums; }
        .summary .value.positive { color: #1e8449; font-weight: 700; }
        .summary .value.negative { color: #b71c1c; font-weight: 700; }

        /* ============ TYPE OPTIONS ============ */
        .type-options {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 12px; margin-bottom: 24px;
        }
        .type-card {
            border: 2px solid #e6edf3; border-radius: 12px;
            padding: 18px; cursor: pointer; background: #fff;
            transition: border-color 0.15s, box-shadow 0.15s, transform 0.1s;
        }
        .type-card:hover { border-color: #cfeadd; }
        .type-card.selected {
            border-color: #27ae60;
            box-shadow: 0 0 0 3px rgba(39,174,96,0.15);
        }
        .type-card input[type=radio] { display: none; }
        .type-card .title {
            font-size: 1rem; font-weight: 700; color: #1e2b3c;
            display: flex; align-items: center; gap: 8px; margin-bottom: 6px;
        }
        .type-card .desc {
            font-size: 0.82rem; color: #6c7a89; line-height: 1.5;
        }
        .type-card .icon {
            display: inline-flex; align-items: center; justify-content: center;
            width: 32px; height: 32px; border-radius: 8px;
            background: #e8f3ee; color: #1e8449;
            font-size: 1rem;
        }
        .type-card.locked {
            opacity: 0.55;
            cursor: not-allowed;
            position: relative;
        }
        .type-card.locked::after {
            content: "🔒";
            position: absolute;
            top: 12px; right: 14px;
            font-size: 1.1rem;
        }
        .type-card.locked:hover { border-color: #e6edf3; }

        /* ============ FORM FIELDS ============ */
        .field { margin-bottom: 16px; }
        label {
            display: block; font-size: 0.85rem; font-weight: 600;
            color: #34495e; margin-bottom: 6px;
        }
        label .req { color: #b71c1c; margin-left: 3px; }
        input, textarea {
            width: 100%; padding: 12px 14px;
            border: 1px solid #d7dfe7; border-radius: 10px;
            font-size: 0.95rem; font-family: inherit;
            color: #1e2b37; background: #fbfcfd;
            transition: border-color 0.15s, box-shadow 0.15s;
        }
        input:focus, textarea:focus {
            outline: none; border-color: #27ae60; background: #fff;
            box-shadow: 0 0 0 3px rgba(39,174,96,0.15);
        }
        input:disabled {
            background: #f1f5f9; color: #95a5a6; cursor: not-allowed;
        }
        textarea { resize: vertical; min-height: 60px; }

        /* ============ NOTICES ============ */
        .notice {
            border-radius: 10px; padding: 14px 16px;
            font-size: 0.88rem; margin-bottom: 16px;
            line-height: 1.5;
        }
        .notice.ok    { background: #e8f3ee; color: #1e8449; border: 1px solid #cfeadd; }
        .notice.warn  { background: #fff4e6; color: #b45309; border: 1px solid #ffddb3; }
        .notice.error { background: #fdecea; color: #b71c1c; border: 1px solid #f5c6cb; }
        .notice.info  { background: #e7f4fd; color: #1f6390; border: 1px solid #c3e2f5; }

        /* ============ BUTTON ============ */
        .btn {
            display: inline-flex; align-items: center; justify-content: center;
            gap: 8px; padding: 13px 22px; border-radius: 10px;
            font-size: 0.95rem; font-weight: 600;
            cursor: pointer; border: none; font-family: inherit;
            width: 100%; margin-top: 12px;
            transition: transform 0.1s, box-shadow 0.2s, background 0.2s;
        }
        .btn-primary {
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff;
            box-shadow: 0 6px 16px -6px rgba(39,174,96,0.5);
        }
        .btn-primary:hover { background: linear-gradient(135deg, #219150, #196b39); }
        .btn-primary:active { transform: translateY(1px); }
        .btn-primary:disabled {
            background: #cbd5e1; cursor: not-allowed;
            box-shadow: none; color: #fff;
        }
        .btn-secondary {
            background: #fff; color: #2c3e50;
            border: 1px solid #d7dfe7;
            margin-top: 8px;
        }
        .btn-secondary:hover { background: #f8fafc; }

        .hidden { display: none; }

        @media (max-width: 540px) {
            body { padding: 24px 14px; }
            .card { padding: 26px 22px; }
            .card-header h2 { font-size: 1.25rem; }
            .type-options { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<div class="container">

    <div class="topnav">
        <a href="<%= request.getContextPath() %>/withdrawalServlet" class="back-link">
            ← Change Member
        </a>
        <a href="<%= request.getContextPath() %>/withdrawalServlet?operation=list" class="back-link">
            📋 All Requests
        </a>
    </div>

    <div class="card">

        <div class="card-header">
            <h2>
                <span class="icon">💸</span>
                Withdrawal Options
            </h2>
        </div>

        <!-- ============ SUMMARY ============ -->
        <div class="summary">
            <h3>Member Summary — <c:out value="${memberName}"/> (${phoneNumber})</h3>
            <div class="row">
                <span class="label">Total Contribution</span>
                <span class="value">
                    GHS <fmt:formatNumber value="${contribution}"
                                          minFractionDigits="2" maxFractionDigits="2"/>
                </span>
            </div>
            <div class="row">
                <span class="label">Interest Share</span>
                <span class="value">
                    GHS <fmt:formatNumber value="${interestShare}"
                                          minFractionDigits="2" maxFractionDigits="2"/>
                </span>
            </div>
            <div class="row">
                <span class="label">Months in Group</span>
                <span class="value">${monthsInGroup}</span>
            </div>
            <div class="row">
                <span class="label">Maturity Date</span>
                <span class="value">${maturityDate}</span>
            </div>
            <div class="row">
                <span class="label">Status</span>
                <span class="value">
                    <c:choose>
                        <c:when test="${matured}">
                            <span style="color:#1e8449;">✅ Matured</span>
                        </c:when>
                        <c:otherwise>
                            <span style="color:#b45309;">⏳ Not yet matured</span>
                        </c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>

        <!-- ============ FORM ============ -->
        <form method="post" action="<%= request.getContextPath() %>/withdrawalServlet"
              id="wrForm">
            <input type="hidden" name="operation"   value="submit" />
            <input type="hidden" name="phoneNumber" value="${phoneNumber}" />

            <label style="font-size:1rem; margin-bottom:12px;">Choose a Payout Option</label>

            <div class="type-options">
                <!-- MATURITY -->
                <label class="type-card ${matured ? '' : 'locked'}"
                       id="card-MATURITY"
                       data-locked="${matured ? 'false' : 'true'}">
                    <input type="radio" name="requestType" value="MATURITY"
                           ${matured ? '' : 'disabled'} />
                    <div class="title"><span class="icon">🎯</span> Maturity Payout</div>
                    <div class="desc">
                        Full contribution + interest.
                        <c:choose>
                            <c:when test="${matured}">Available now.</c:when>
                            <c:otherwise>Available from ${maturityDate}.</c:otherwise>
                        </c:choose>
                    </div>
                </label>

                <!-- TERMINATION -->
                <label class="type-card" id="card-TERMINATION">
                    <input type="radio" name="requestType" value="TERMINATION" />
                    <div class="title"><span class="icon">🚪</span> Terminate</div>
                    <div class="desc">
                        Leave the group early. 5% penalty if under 6 months.
                        Interest is still paid out.
                    </div>
                </label>

                <!-- TRANSFER -->
                <label class="type-card" id="card-TRANSFER">
                    <input type="radio" name="requestType" value="TRANSFER" />
                    <div class="title"><span class="icon">↔️</span> Transfer</div>
                    <div class="desc">
                        Move your full fund to another group.
                    </div>
                </label>
            </div>

            <!-- ============ MATURITY inputs ============ -->
            <div id="block-MATURITY" class="hidden">
                <c:choose>
                    <c:when test="${matured}">
                        <div class="notice ok">
                            ✅ Member has reached maturity. Ready to pay out.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="notice warn">
                            ⏳ Not yet matured. Maturity date: <strong>${maturityDate}</strong>.
                            You can still submit a PENDING request, but Mark Paid will only
                            work on or after the maturity date.
                        </div>
                    </c:otherwise>
                </c:choose>
                <div class="field">
                    <label for="momoMaturity">
                        MoMo Number (payout destination) <span class="req">*</span>
                    </label>
                    <input type="text" id="momoMaturity" name="momoNumber"
                           placeholder="e.g. 0244 123 456">
                </div>
            </div>

            <!-- ============ TERMINATION inputs ============ -->
            <div id="block-TERMINATION" class="hidden">
                <div class="notice info">
                    <strong>Termination Summary</strong>
                    <div id="termBreakdown" style="margin-top:8px; line-height:1.7;"></div>
                </div>
                <div class="field">
                    <label for="momoTerm">
                        MoMo Number (payout destination) <span class="req">*</span>
                    </label>
                    <input type="text" id="momoTerm" name="momoNumber"
                           placeholder="e.g. 0244 123 456">
                </div>
            </div>

            <!-- ============ TRANSFER inputs ============ -->
            <div id="block-TRANSFER" class="hidden">
                <div class="notice info">
                    <strong>Transfer Summary</strong>
                    <div style="margin-top:8px; line-height:1.7;">
                        Your total fund (contribution + interest):
                        <strong>GHS <fmt:formatNumber value="${contribution + interestShare}"
                                                      minFractionDigits="2" maxFractionDigits="2"/></strong>
                        <br/>
                        This full amount will be transferred to the target group.
                    </div>
                </div>
                <div class="field">
                    <label for="targetGroupName">
                        Target Group Name <span class="req">*</span>
                    </label>
                    <input type="text" id="targetGroupName" name="targetGroupName"
                           placeholder="e.g. Sambala Women">
                </div>
                <div class="field">
                    <label for="targetBankAccount">
                        Target Bank Account <span class="req">*</span>
                    </label>
                    <input type="text" id="targetBankAccount" name="targetBankAccount"
                           placeholder="e.g. 1234567890123">
                </div>
            </div>

            <!-- NOTES -->
            <div class="field hidden" id="block-NOTES">
                <label for="notes">
                    Notes <span style="color:#95a5a6; font-weight:400;">(optional)</span>
                </label>
                <textarea id="notes" name="notes" rows="2"
                          placeholder="Any additional info..."></textarea>
            </div>

            <button type="submit" class="btn btn-primary" id="submitBtn" disabled>
                Submit Request →
            </button>

            <a href="<%= request.getContextPath() %>/withdrawalServlet"
               class="btn btn-secondary">
                ← Cancel
            </a>
        </form>

    </div>

</div>

<script>
    // Safely parse numbers from the server
    const contribution = parseFloat("${contribution}") || 0;
    const interest     = parseFloat("${interestShare}") || 0;
    const months       = parseInt("${monthsInGroup}", 10) || 0;

    const cards  = {
        MATURITY:    document.getElementById('card-MATURITY'),
        TERMINATION: document.getElementById('card-TERMINATION'),
        TRANSFER:    document.getElementById('card-TRANSFER')
    };
    const blocks = {
        MATURITY:    document.getElementById('block-MATURITY'),
        TERMINATION: document.getElementById('block-TERMINATION'),
        TRANSFER:    document.getElementById('block-TRANSFER')
    };
    const notesBlock = document.getElementById('block-NOTES');
    const submitBtn  = document.getElementById('submitBtn');

    function select(type) {
        // Update card highlight
        for (const k in cards) {
            cards[k].classList.toggle('selected', k === type);
            blocks[k].classList.toggle('hidden', k !== type);
        }
        notesBlock.classList.remove('hidden');
        submitBtn.disabled = false;

        // Clear required on hidden inputs; enable only the visible one's
        document.getElementById('momoMaturity').required       = false;
        document.getElementById('momoTerm').required           = false;
        document.getElementById('targetGroupName').required    = false;
        document.getElementById('targetBankAccount').required  = false;

        if (type === 'MATURITY') {
            document.getElementById('momoMaturity').required = true;
        } else if (type === 'TERMINATION') {
            document.getElementById('momoTerm').required = true;
            renderTermination();
        } else if (type === 'TRANSFER') {
            document.getElementById('targetGroupName').required    = true;
            document.getElementById('targetBankAccount').required  = true;
        }
    }

    function renderTermination() {
        const penalty = months < 6 ? +(contribution * 0.05).toFixed(2) : 0;
        const payable = +(contribution - penalty + interest).toFixed(2);

        const lines = [];
        lines.push("Contribution: GHS " + contribution.toFixed(2));
        lines.push("Interest: GHS " + interest.toFixed(2));
        if (penalty > 0) {
            lines.push("Penalty (5%): −GHS " + penalty.toFixed(2));
        } else {
            lines.push("Penalty: none (≥ 6 months)");
        }
        lines.push("<strong>Amount Payable: GHS " + payable.toFixed(2) + "</strong>");
        document.getElementById('termBreakdown').innerHTML = lines.join("<br/>");
    }

    // Wire radio selection
    document.querySelectorAll('input[name="requestType"]').forEach(r => {
        r.addEventListener('change', () => select(r.value));
    });

    // Prevent clicking locked cards
    Object.values(cards).forEach(card => {
        card.addEventListener('click', e => {
            if (card.dataset.locked === 'true') {
                e.preventDefault();
                alert("This option is not available yet. Member has not reached maturity.");
            }
        });
    });
</script>

</body>
</html>