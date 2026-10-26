<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    // Fallback: if session has allGroups but no currentGroupId, pick the first
    if (session.getAttribute("currentGroupId") == null
            && session.getAttribute("allGroups") != null) {
        java.util.List<?> groups = (java.util.List<?>) session.getAttribute("allGroups");
        if (!groups.isEmpty()) {
            try {
                Object first = groups.get(0);
                java.lang.reflect.Method getId = first.getClass().getMethod("getId");
                session.setAttribute("currentGroupId", getId.invoke(first));
            } catch (Exception ignored) {}
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UnityPurse · Fund Composition Report</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            background: #f4f6f9; color: #1e2b37; line-height: 1.55;
            min-height: 100vh; display: flex; justify-content: center;
            padding: 60px 20px;
        }
        .card {
            background: #fff; border-radius: 18px;
            box-shadow: 0 16px 40px -20px rgba(0,30,40,0.18);
            padding: 36px 40px 32px; max-width: 560px; width: 100%;
        }
        .card h1 { font-size: 1.4rem; color: #1e2b3c; margin-bottom: 6px; }
        .card .sub { color: #6c7a89; font-size: 0.9rem; margin-bottom: 28px; }

        .error-box {
            background: #fdecea; border: 1px solid #f5c6c0; color: #a93226;
            padding: 12px 16px; border-radius: 10px;
            font-size: 0.87rem; margin-bottom: 22px;
        }
        .error-box b { color: #7b241c; }

        label {
            display: block; font-size: 0.82rem; font-weight: 600;
            color: #4a6075; margin-bottom: 6px;
            text-transform: uppercase; letter-spacing: 0.04em;
        }
        select {
            width: 100%; padding: 11px 14px; border-radius: 10px;
            border: 1px solid #cfd9e3; background: #fff; color: #1e2b3c;
            font-size: 0.95rem; font-family: inherit; margin-bottom: 22px;
        }
        .btn-row { display: flex; gap: 12px; flex-wrap: wrap; }
        .btn {
            border: none; cursor: pointer; font-weight: 600;
            text-align: center; text-decoration: none;
            padding: 12px 18px; border-radius: 10px;
            font-size: 0.95rem; font-family: inherit; flex: 1;
            transition: transform 0.15s, box-shadow 0.15s, background 0.15s;
        }
        .btn-primary {
            background: linear-gradient(135deg, #27ae60, #1e8449);
            color: #fff;
            box-shadow: 0 8px 18px -8px rgba(39,174,96,0.55);
        }
        .btn-primary:hover { transform: translateY(-1px); }
        .btn-secondary { background: #eef2f6; color: #1e2b3c; }
        .btn-secondary:hover { background: #e2e9f0; }
        .btn-tertiary { background: #fff; color: #1e2b3c; border: 1px solid #cfd9e3; }
        .btn-tertiary:hover { background: #f4f6f9; }
        .back-link {
            display: inline-block; margin-top: 26px; color: #4a6075;
            font-size: 0.86rem; text-decoration: none;
        }
        .back-link:hover { color: #1e2b3c; text-decoration: underline; }
        .hint {
            margin-top: 22px; padding: 12px 16px; border-radius: 10px;
            background: #f8fafc; border: 1px solid #e2e9f0;
            font-size: 0.82rem; color: #6c7a89;
        }
    </style>
</head>
<body>
<div class="card">
    <h1>🥧 Fund Composition Report</h1>
    <p class="sub">View or download the group fund breakdown with a slice-angle pie chart.</p>

    <c:if test="${param.error eq 'InvalidGroupId'}">
        <div class="error-box">
            <b>Invalid group ID.</b> Please pick a group from the list and try again.
        </div>
    </c:if>
    <c:if test="${param.error eq 'NoDataFound'}">
        <div class="error-box">
            <b>No data found.</b> This group has no contributions, loans, or interest records yet.
        </div>
    </c:if>

    <form id="reportForm" method="get"
          action="${pageContext.request.contextPath}/fundComposition"
          target="_blank">
        <input type="hidden" name="format" id="formatField" value="pdf"/>

        <label for="groupId">Select Group</label>
        <select name="groupId" id="groupId" required>
            <c:forEach var="g" items="${sessionScope.allGroups}">
                <option value="${g.id}"
                    ${g.id == sessionScope.currentGroupId ? 'selected' : ''}>
                    <c:out value="${g.groupName}"/> (ID: <c:out value="${g.id}"/>)
                </option>
            </c:forEach>
            <c:if test="${empty sessionScope.allGroups}">
                <option value="${sessionScope.currentGroupId}">
                    Current group (ID: <c:out value="${sessionScope.currentGroupId}"/>)
                </option>
            </c:if>
        </select>

        <div class="btn-row" style="margin-bottom:12px;">
            <button type="submit" class="btn btn-primary"
                    onclick="document.getElementById('formatField').value='pdf';">
                📄 View PDF
            </button>
            <button type="submit" class="btn btn-secondary"
                    onclick="document.getElementById('formatField').value='html';">
                🌐 View HTML
            </button>
            <button type="submit" class="btn btn-secondary"
                    onclick="document.getElementById('formatField').value='download';">
                ⬇️ Download PDF
            </button>
        </div>
        <div class="btn-row">
            <button type="submit" class="btn btn-tertiary"
                    onclick="document.getElementById('formatField').value='xlsx';">
                📊 Download Excel (.xlsx)
            </button>
        </div>
    </form>

    <div class="hint">
        💡 PDF and HTML open in a new tab. Excel downloads immediately.
    </div>

    <a class="back-link" href="${pageContext.request.contextPath}/dashboard.jsp">← Back to Dashboard</a>
</div>
</body>
</html>