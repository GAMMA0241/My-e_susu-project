<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    String fullName = (String) session.getAttribute("fullName");
    String username = (String) session.getAttribute("username");
    String displayName = (fullName != null && !fullName.isBlank()) ? fullName : username;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title> UnityPurse · Dashboard</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            background: #f4f6f9; display: flex; min-height: 100vh;
            color: #1e2b37; line-height: 1.5;
        }
        .drawer {
            width: 270px;
            background: linear-gradient(180deg, #1e2b3c 0%, #17212e 100%);
            color: #eef2f6; display: flex; flex-direction: column;
            padding: 24px 0 28px; position: fixed; height: 100%;
            overflow-y: auto; transition: transform 0.28s cubic-bezier(0.2,0.9,0.4,1);
            z-index: 1000; box-shadow: 4px 0 20px rgba(0,0,0,0.08);
        }
        .drawer::-webkit-scrollbar { width: 6px; }
        .drawer::-webkit-scrollbar-track { background: #1e2b3c; }
        .drawer::-webkit-scrollbar-thumb { background: #3a4b5e; border-radius: 8px; }

        .drawer-header {
            text-align: center; padding: 0 20px 24px;
            border-bottom: 1px solid rgba(255,255,255,0.08); margin-bottom: 8px;
        }
        .drawer-header h2 { font-size: 1.35rem; color: white; margin-bottom: 6px; }
        .drawer-header span {
            font-size: 0.72rem; text-transform: uppercase;
            letter-spacing: 0.08em; color: #9aaec2; font-weight: 500;
            background: rgba(255,255,255,0.06); padding: 4px 12px;
            border-radius: 30px; display: inline-block;
        }

        /* ============ COLLAPSIBLE SECTION ============ */
        .drawer-section { border-top: 1px solid rgba(255,255,255,0.05); }
        .drawer-section:first-of-type { border-top: none; }

        .section-toggle {
            width: 100%;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px 20px 14px;
            background: transparent;
            border: none;
            color: #7f95ab;
            font-size: 0.68rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            cursor: pointer;
            font-family: inherit;
            text-align: left;
            transition: color 0.18s, background 0.18s;
        }
        .section-toggle:hover {
            color: #dfe7ef;
            background: rgba(255,255,255,0.03);
        }
        .section-toggle .section-label {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .section-toggle .arrow {
            display: inline-block;
            font-size: 0.7rem;
            color: #7f95ab;
            transition: transform 0.25s ease;
            transform: rotate(-90deg);
        }
        .section-toggle.open .arrow { transform: rotate(0deg); }
        .section-toggle.open { color: #dfe7ef; }

        .section-items {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.28s ease;
        }
        .section-items.open { max-height: 600px; }

        .section-items a {
            display: block; padding: 10px 20px 10px 32px; color: #dfe7ef;
            text-decoration: none; font-size: 0.87rem; font-weight: 500;
            transition: background 0.18s, border-left-color 0.18s, color 0.18s;
            border-left: 4px solid transparent;
        }
        .section-items a:hover {
            background: rgba(255,255,255,0.06);
            border-left-color: #27ae60;
            color: #ffffff;
        }

        /* ============ MAIN ============ */
        .main { margin-left: 270px; flex: 1; padding: 32px 40px; width: calc(100% - 270px); }
        .topbar {
            background: #ffffff; padding: 18px 28px; border-radius: 14px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.04);
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 32px; flex-wrap: wrap; gap: 12px;
        }
        .topbar h1 { font-size: 1.35rem; font-weight: 600; color: #1e2b3c; }
        .topbar .group-name { font-size: 0.85rem; font-weight: 400; color: #6c7a89; }
        .user-chip {
            display: flex; align-items: center; gap: 10px;
            background: #f4f6f9; padding: 6px 14px 6px 6px;
            border-radius: 999px; font-size: 0.85rem;
            color: #1e2b3c; font-weight: 500; flex-wrap: wrap;
        }
        .user-chip .avatar {
            width: 30px; height: 30px; border-radius: 50%;
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff; display: flex; align-items: center;
            justify-content: center; font-size: 0.8rem;
            font-weight: 700; text-transform: uppercase;
        }
        .user-chip select {
            padding: 5px 10px; border-radius: 6px;
            border: 1px solid #cfd9e3; background: #fff;
            font-size: 0.78rem; font-weight: 600;
            color: #1e2b3c; cursor: pointer; font-family: inherit;
        }
        .user-chip .logout-link {
            margin-left: 6px; color: #c0392b; text-decoration: none;
            font-weight: 600; font-size: 0.8rem;
            padding: 4px 10px; border-radius: 20px;
        }
        .user-chip .logout-link:hover { background: #fdecea; }
        .menu-toggle {
            display: none; background: #1e2b3c; color: white;
            border: none; padding: 10px 15px; border-radius: 10px;
            cursor: pointer; font-size: 1.1rem;
        }
        .welcome-box {
            background: #ffffff; padding: 48px 48px 44px;
            border-radius: 22px; box-shadow: 0 16px 32px -16px rgba(0,30,40,0.12);
            text-align: center; max-width: 1000px; margin: 0 auto;
        }
        .welcome-box h2 { color: #1e2b3c; font-size: 1.85rem; font-weight: 600; margin-bottom: 20px; }
        .welcome-box p { color: #4a6075; font-size: 0.98rem; line-height: 1.75; max-width: 760px; margin: 0 auto 14px; }
        .welcome-box b { color: #1e2b3c; font-weight: 600; background: #e8f3ee; padding: 2px 8px; border-radius: 20px; font-size: 0.9em; }
        .welcome-box .hint {
            margin-top: 32px; font-size: 0.85rem; color: #7e8e9e;
            background: #f8fafc; display: inline-block;
            padding: 10px 24px; border-radius: 40px;
            border: 1px solid #e2e9f0;
        }
        .overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(10,20,30,0.55); z-index: 999;
            opacity: 0; transition: opacity 0.25s;
        }
        .overlay.show { display: block; opacity: 1; }
        .modal-overlay {
            position: fixed; inset: 0;
            background: rgba(15,25,35,0.65);
            backdrop-filter: blur(3px);
            display: flex; align-items: center; justify-content: center;
            z-index: 9999; opacity: 0;
            animation: modalFadeIn 0.25s ease forwards;
        }
        .modal-box {
            background: #fff; border-radius: 18px;
            padding: 36px 40px 30px; max-width: 380px;
            width: calc(100% - 40px); text-align: center;
            box-shadow: 0 24px 60px -20px rgba(0,0,0,0.35);
            transform: scale(0.9);
            animation: modalPopIn 0.3s cubic-bezier(0.2,0.9,0.4,1.15) forwards;
        }
        .modal-icon {
            width: 64px; height: 64px; border-radius: 50%;
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff; font-size: 2rem; font-weight: 700;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 18px;
            box-shadow: 0 10px 24px -8px rgba(39,174,96,0.55);
        }
        .modal-box h3 { font-size: 1.25rem; font-weight: 600; color: #1e2b3c; margin-bottom: 8px; }
        .modal-box p { font-size: 0.92rem; color: #6c7a89; margin-bottom: 22px; }
        .modal-box p strong { color: #1e8449; font-weight: 600; }
        .modal-btn {
            width: 100%; padding: 12px 20px;
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff; border: none; border-radius: 10px;
            font-size: 0.95rem; font-weight: 600;
            cursor: pointer; font-family: inherit;
        }
        @keyframes modalFadeIn { to { opacity: 1; } }
        @keyframes modalPopIn { to { transform: scale(1); } }
        @media (max-width: 820px) {
            .drawer { transform: translateX(-100%); }
            .drawer.open { transform: translateX(0); }
            .main { margin-left: 0; width: 100%; padding: 20px 18px; }
            .menu-toggle { display: block; }
            .user-chip { font-size: 0.78rem; }
            .user-chip .logout-link { display: none; }
        }
    </style>
</head>
<body>

<div class="overlay" id="overlay" onclick="toggleDrawer()"></div>

<aside class="drawer" id="drawer">
    <div class="drawer-header">
        <h2>Timaataba</h2>
        <span>${sessionScope.currentGroupName}</span>
    </div>

    <!-- ============ SETTINGS ============ -->
        <div class="drawer-section">
            <button type="button" class="section-toggle"
                    data-section="settings">
                <span class="section-label">⚙️ Settings</span>
                <span class="arrow">▼</span>
            </button>
            <div class="section-items" id="section-settings">
                <a href="${pageContext.request.contextPath}/groups">👥 Groups</a>
                <a href="${pageContext.request.contextPath}/bankSetup">🏦 Bank &amp; Fees</a>
                <a href="${pageContext.request.contextPath}/signatories">✍️ Signatories</a>
            </div>
        </div>

    <!-- ============ MEMBERS & CONTRIBUTIONS ============ -->
    <div class="drawer-section">
        <button type="button" class="section-toggle"
                data-section="members">
            <span class="section-label">👥 Members &amp; Contributions</span>
            <span class="arrow">▼</span>
        </button>
        <div class="section-items" id="section-members">
            <a href="${pageContext.request.contextPath}/memberServlet?operation=registerForm">➕ Add Member</a>
            <a href="${pageContext.request.contextPath}/contributionServlet">💰 Record Contribution</a>
            <a href="${pageContext.request.contextPath}/contributionServlet?operation=viewMembersAndTotal">📊 Members &amp; Total Contribution</a>
            <a href="${pageContext.request.contextPath}/statementServlet?operation=filter">📄 Contributions Statement</a>
        </div>
    </div>

    <!-- ============ OPERATIONS ============ -->
    <div class="drawer-section">
        <button type="button" class="section-toggle"
                data-section="operations">
            <span class="section-label">⚙️ Operations</span>
            <span class="arrow">▼</span>
        </button>
        <div class="section-items" id="section-operations">
            <a href="${pageContext.request.contextPath}/payoutServlet?operation=viewPayouts">💸 View Payout Schedule</a>
        </div>
    </div>

    <!-- ============ FUND OPERATIONS ============ -->
    <div class="drawer-section">
        <button type="button" class="section-toggle"
                data-section="fundops">
            <span class="section-label">💰 Fund Operations</span>
            <span class="arrow">▼</span>
        </button>
        <div class="section-items" id="section-fundops">
            <a href="${pageContext.request.contextPath}/withdrawalServlet">💸 Fund Withdrawal / Transfer</a>
            <a href="${pageContext.request.contextPath}/withdrawalServlet?operation=list">📋 Withdrawal Requests</a>
        </div>
    </div>

    <!-- ============ PARTIES ============ -->
    <div class="drawer-section">
        <button type="button" class="section-toggle"
                data-section="parties">
            <span class="section-label">🏛️ Parties</span>
            <span class="arrow">▼</span>
        </button>
        <div class="section-items" id="section-parties">
            <a href="${pageContext.request.contextPath}/parties">🏛️ View Bank &amp; Signatories</a>
        </div>
    </div>

    <!-- ============ LOAN BOARD ============ -->
    <div class="drawer-section">
        <button type="button" class="section-toggle"
                data-section="loanboard">
            <span class="section-label">🏦 Loan Board</span>
            <span class="arrow">▼</span>
        </button>
        <div class="section-items" id="section-loanboard">
            <a href="${pageContext.request.contextPath}/loanServlet?operation=viewFund">📊 View Loan Fund</a>
            <a href="${pageContext.request.contextPath}/loanServlet?operation=newFundEntry">🏦 Add to Loan Fund</a>
            <a href="${pageContext.request.contextPath}/loanServlet?operation=newLoan">📝 Issue Loan</a>
            <a href="${pageContext.request.contextPath}/loanServlet?operation=repayForm">💵 Repay Loan</a>
            <a href="${pageContext.request.contextPath}/payoutServlet?operation=viewInterestPool">📈 Interest Pool</a>
        </div>
    </div>


</aside>

<main class="main">
    <div class="topbar">
        <button class="menu-toggle" onclick="toggleDrawer()" aria-label="Toggle menu">☰</button>
        <h1>Welcome, <%= displayName %>!
            <span class="group-name">· ${sessionScope.currentGroupName}</span>
        </h1>

        <div class="user-chip">
            <div class="avatar"><%= displayName.substring(0, 1) %></div>
            <span><%= displayName %></span>

            <form action="<%= request.getContextPath() %>/groups"
                  method="post" style="display:inline;">
                <input type="hidden" name="operation" value="switch">
                <select name="groupId" onchange="this.form.submit()">
                    <c:forEach var="g" items="${sessionScope.allGroups}">
                        <option value="${g.id}"
                            ${g.id == sessionScope.currentGroupId ? 'selected' : ''}>
                            ${g.groupName}
                        </option>
                    </c:forEach>
                </select>
            </form>

            <a class="logout-link" href="<%= request.getContextPath() %>/logout">Logout</a>
        </div>
    </div>

    <div class="welcome-box">
        <h2>Manage Your Susu Group With Ease</h2>
        <p>
            This dashboard gives you full control over your Susu group's daily operations.
            Use the navigation menu on the left to register new members, record contributions,
            generate statements, and manage the loan board.
        </p>
        <p>
            Members mature after <b>12 months</b> and receive their
            <b>total contribution plus a share of loan interest</b>,
            distributed proportionally to their contributions.
        </p>
        <p class="hint">⚡ Select an option from the drawer menu to get started.</p>
    </div>
</main>

<script>
    /* ============ DRAWER (mobile) ============ */
    function toggleDrawer() {
        document.getElementById('drawer').classList.toggle('open');
        document.getElementById('overlay').classList.toggle('show');
    }
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            const d = document.getElementById('drawer');
            if (d.classList.contains('open')) toggleDrawer();
        }
    });

    /* ============ COLLAPSIBLE SECTIONS ============ */
    (function () {
        const STORAGE_KEY = 'timaataba.drawer.sections';

        let openSections = {};
        try {
            openSections = JSON.parse(localStorage.getItem(STORAGE_KEY) || '{}');
        } catch (e) {
            openSections = {};
        }

        const toggles = document.querySelectorAll('.section-toggle');
        let anyOpen = false;
        toggles.forEach(t => {
            if (openSections[t.dataset.section]) anyOpen = true;
        });
        if (!anyOpen && toggles.length > 0) {
            openSections[toggles[0].dataset.section] = true;
        }

        toggles.forEach(t => {
            const key = t.dataset.section;
            const items = document.getElementById('section-' + key);
            if (openSections[key]) {
                t.classList.add('open');
                items.classList.add('open');
            }
        });

        toggles.forEach(t => {
            t.addEventListener('click', () => {
                const key = t.dataset.section;
                const items = document.getElementById('section-' + key);

                const willOpen = !t.classList.contains('open');
                t.classList.toggle('open', willOpen);
                items.classList.toggle('open', willOpen);

                openSections[key] = willOpen;
                localStorage.setItem(STORAGE_KEY, JSON.stringify(openSections));
            });
        });
    })();
</script>

<c:if test="${param.login eq 'success'}">
    <div class="modal-overlay" id="loginModal">
        <div class="modal-box">
            <div class="modal-icon">✓</div>
            <h3>Successfully Logged In</h3>
            <p>Welcome back, <strong><%= displayName %></strong>!</p>
            <button onclick="closeLoginModal()" class="modal-btn">OK</button>
        </div>
    </div>
    <script>
        function closeLoginModal() {
            const m = document.getElementById('loginModal');
            if (!m) return;
            m.style.opacity = '0';
            setTimeout(() => {
                m.remove();
                history.replaceState({}, '', '<%= request.getContextPath() %>/dashboard.jsp');
            }, 200);
        }
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' || e.key === 'Escape') {
                const m = document.getElementById('loginModal');
                if (m) closeLoginModal();
            }
        });
    </script>
</c:if>

</body>
</html>