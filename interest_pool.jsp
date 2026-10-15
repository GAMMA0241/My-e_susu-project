<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>💰 Interest Pool — Group <c:out value="${selectedGroupId}"/></title>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
    <style>
        :root {
            --brand:        #4f46e5;
            --brand-dark:   #4338ca;
            --brand-light:  #eef2ff;
            --pending:      #6b7280;
            --charged:      #f59e0b;
            --distributed:  #10b981;
            --danger:       #ef4444;
            --surface:      #ffffff;
            --bg:           #f3f4f6;
        }

        body {
            background: linear-gradient(135deg, #f3f4f6 0%, #e5e7eb 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Roboto, system-ui, -apple-system, sans-serif;
        }

        /* ==================== Page header ==================== */
        .page-header {
            background: linear-gradient(135deg, var(--brand) 0%, var(--brand-dark) 100%);
            color: #fff;
            border-radius: 16px;
            padding: 1.5rem 1.75rem;
            box-shadow: 0 10px 30px rgba(79, 70, 229, 0.25);
            margin-bottom: 1.5rem;
        }
        .page-header h2 {
            font-weight: 700;
            letter-spacing: -0.5px;
            margin: 0;
        }
        .page-header .group-select {
            background: rgba(255, 255, 255, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.35);
            color: #fff;
            backdrop-filter: blur(6px);
            min-width: 220px;
            font-weight: 500;
        }
        .page-header .group-select option { color: #000; }

        /* ==================== Flash message ==================== */
        .flash {
            border: none;
            border-left: 4px solid var(--brand);
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.06);
            background: #fff;
            color: #111827;
            animation: slideDown .35s ease-out;
        }
        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-8px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ==================== Summary cards ==================== */
        .stat-card {
            border: none;
            border-radius: 16px;
            box-shadow: 0 4px 14px rgba(0,0,0,0.06);
            transition: transform .2s ease, box-shadow .2s ease;
            overflow: hidden;
            position: relative;
            height: 100%;
        }
        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 24px rgba(0,0,0,0.10);
        }
        .stat-card::before {
            content: "";
            position: absolute;
            left: 0; top: 0; bottom: 0;
            width: 6px;
        }
        .stat-card.balance::before     { background: var(--distributed); }
        .stat-card.fees::before        { background: var(--charged); }
        .stat-card.actions::before     { background: var(--brand); }

        .stat-label {
            font-size: .75rem;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: #6b7280;
            font-weight: 600;
        }
        .stat-value {
            font-size: 1.75rem;
            font-weight: 800;
            letter-spacing: -0.5px;
            margin-top: .25rem;
        }
        .stat-value.balance { color: var(--distributed); }
        .stat-value.fees    { color: var(--charged); }

        /* ==================== Buttons ==================== */
        .btn-action {
            border-radius: 10px;
            font-weight: 600;
            letter-spacing: .2px;
            transition: transform .15s ease, box-shadow .15s ease;
        }
        .btn-action:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(0,0,0,0.12);
        }

        /* ==================== Main table card ==================== */
        .table-card {
            border: none;
            border-radius: 16px;
            box-shadow: 0 4px 14px rgba(0,0,0,0.06);
            overflow: hidden;
        }
        .table-card .card-header {
            background: #fff;
            border-bottom: 1px solid #e5e7eb;
            padding: 1rem 1.25rem;
        }
        .table-card .card-header h5 {
            font-weight: 700;
            margin: 0;
            display: flex;
            align-items: center;
            gap: .5rem;
        }

        /* ==================== Table ==================== */
        .pool-table {
            margin: 0;
            font-size: .9rem;
        }
        .pool-table thead th {
            background: #f9fafb;
            color: #4b5563;
            font-weight: 700;
            font-size: .72rem;
            text-transform: uppercase;
            letter-spacing: .06em;
            border-bottom: 1px solid #e5e7eb;
            padding: .85rem .75rem;
            white-space: nowrap;
        }
        .pool-table tbody td {
            padding: .85rem .75rem;
            vertical-align: middle;
            border-color: #f1f5f9;
        }
        .pool-table tbody tr {
            transition: background .15s ease;
        }
        .pool-table tbody tr:hover {
            background: #f9fafb;
        }
        .pool-table .id-badge {
            background: var(--brand-light);
            color: var(--brand-dark);
            font-weight: 700;
            font-size: .75rem;
            padding: .25rem .55rem;
            border-radius: 6px;
        }
        .amount {
            font-variant-numeric: tabular-nums;
            font-weight: 600;
        }
        .amount-net {
            font-variant-numeric: tabular-nums;
            font-weight: 800;
            color: var(--distributed);
            font-size: .95rem;
        }

        /* ==================== Status badges ==================== */
        .badge-status {
            display: inline-flex;
            align-items: center;
            gap: .35rem;
            padding: .4rem .7rem;
            font-size: .72rem;
            font-weight: 700;
            border-radius: 999px;
            letter-spacing: .02em;
            white-space: nowrap;
        }
        .badge-status.pending {
            background: #f3f4f6;
            color: var(--pending);
            border: 1px solid #e5e7eb;
        }
        .badge-status.charged {
            background: #fef3c7;
            color: #92400e;
            border: 1px solid #fde68a;
        }
        .badge-status.distributed {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #a7f3d0;
        }
        .badge-status .dot {
            width: 7px; height: 7px;
            border-radius: 50%;
            display: inline-block;
        }
        .badge-status.pending     .dot { background: var(--pending); }
        .badge-status.charged     .dot { background: var(--charged); }
        .badge-status.distributed .dot { background: var(--distributed); }

        /* ==================== Action buttons row ==================== */
        .action-group {
            display: inline-flex;
            gap: .3rem;
            align-items: center;
        }
        .btn-icon {
            width: 34px; height: 34px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0;
            border-radius: 8px;
            font-size: .95rem;
            transition: all .15s ease;
        }
        .btn-icon:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(0,0,0,0.12);
        }

        /* ==================== Empty state ==================== */
        .empty-state {
            text-align: center;
            padding: 3rem 1rem;
            color: #6b7280;
        }
        .empty-state .icon {
            font-size: 3rem;
            color: #d1d5db;
            margin-bottom: .75rem;
            display: block;
        }
        .empty-state h6 {
            font-weight: 700;
            color: #374151;
            margin-bottom: .35rem;
        }

        /* ==================== Notes ellipsis ==================== */
        .notes-cell {
            max-width: 200px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            color: #6b7280;
            font-size: .82rem;
        }

        /* ==================== Responsive tweaks ==================== */
        @media (max-width: 768px) {
            .page-header { padding: 1.1rem 1rem; }
            .page-header h2 { font-size: 1.15rem; }
            .stat-value { font-size: 1.35rem; }
            .pool-table { font-size: .82rem; }
        }
    </style>
</head>
<body>

<div class="container py-4" style="max-width: 1200px;">

    <!-- ==================== Page header ==================== -->
    <div class="page-header d-flex flex-wrap justify-content-between align-items-center gap-3">
        <div>
            <h2><i class="bi bi-piggy-bank-fill me-2"></i>Interest Pool</h2>
            <div class="small opacity-75 mt-1">
                Group <c:out value="${selectedGroupId}"/>
            </div>
        </div>

        <form method="get" action="payoutServlet" class="d-flex gap-2">
            <input type="hidden" name="operation" value="viewInterestPool"/>
            <select name="groupId" class="form-select group-select"
                    onchange="this.form.submit()">
                <c:forEach var="g" items="${groups}">
                    <option value="${g.id}"
                        <c:if test="${g.id == selectedGroupId}">selected</c:if>>
                        <c:out value="${g.groupName}"/>
                    </option>
                </c:forEach>
            </select>
        </form>
    </div>

    <!-- ==================== Flash message ==================== -->
    <c:if test="${not empty param.message}">
        <div class="alert flash alert-dismissible fade show d-flex align-items-center"
             role="alert">
            <i class="bi bi-info-circle-fill me-2 text-primary"></i>
            <div><c:out value="${param.message}"/></div>
            <button class="btn-close ms-auto" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- ==================== Summary cards ==================== -->
    <div class="row g-3 mb-4">

        <!-- Pool balance -->
        <div class="col-md-4">
            <div class="card stat-card balance">
                <div class="card-body ps-4">
                    <div class="stat-label">
                        <i class="bi bi-wallet2 me-1"></i>Total Pool Balance
                    </div>
                    <div class="stat-value balance">
                        <span class="text-muted fw-normal fs-6 me-1">GHS</span>
                        <fmt:formatNumber value="${totalPoolBalance}" pattern="#,##0.00"/>
                    </div>
                </div>
            </div>
        </div>

        <!-- Total fees -->
        <div class="col-md-4">
            <div class="card stat-card fees">
                <div class="card-body ps-4">
                    <div class="stat-label">
                        <i class="bi bi-receipt me-1"></i>Total Fees Charged
                    </div>
                    <div class="stat-value fees">
                        <span class="text-muted fw-normal fs-6 me-1">GHS</span>
                        <fmt:formatNumber value="${totalFeesCharged}" pattern="#,##0.00"/>
                    </div>
                </div>
            </div>
        </div>

        <!-- Actions -->
        <div class="col-md-4">
            <div class="card stat-card actions">
                <div class="card-body ps-4">
                    <div class="stat-label mb-2">
                        <i class="bi bi-lightning-charge-fill me-1"></i>Quick Actions
                    </div>

                    <form method="post" action="payoutServlet">
                        <input type="hidden" name="operation" value="distributeInterest"/>
                        <input type="hidden" name="groupId"   value="${selectedGroupId}"/>
                        <button class="btn btn-primary btn-action btn-sm w-100 mb-2"
                                onclick="return confirm('Move all undistributed interest into a new pool row?');">
                            <i class="bi bi-plus-circle me-1"></i>Move Interest to Pool
                        </button>
                    </form>

                    <form method="post" action="payoutServlet">
                        <input type="hidden" name="operation" value="accrueFees"/>
                        <input type="hidden" name="groupId"   value="${selectedGroupId}"/>
                        <button class="btn btn-outline-secondary btn-action btn-sm w-100"
                                onclick="return confirm('Accrue one day of fees across all open pool rows?');">
                            <i class="bi bi-hourglass-split me-1"></i>Accrue Daily Fees
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- ==================== Pool table ==================== -->
    <div class="card table-card">
        <div class="card-header d-flex align-items-center justify-content-between">
            <h5>
                <i class="bi bi-list-ul text-primary"></i>Pool Rows
            </h5>
            <span class="text-muted small">
                <c:out value="${poolRows.size()}"/> record(s)
            </span>
        </div>

        <div class="card-body p-0">
            <c:choose>
                <c:when test="${empty poolRows}">
                    <div class="empty-state">
                        <i class="bi bi-inbox icon"></i>
                        <h6>No pool rows yet</h6>
                        <p class="small mb-0">
                            Click <strong>Move Interest to Pool</strong> to create your first pool row.
                        </p>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="table-responsive">
                        <table class="table pool-table align-middle">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Date</th>
                                    <th class="text-end">Interest</th>
                                    <th class="text-end">Fee</th>
                                    <th class="text-end">Net Balance</th>
                                    <th class="text-end">Fees Total</th>
                                    <th>Status</th>
                                    <th>Notes</th>
                                    <th class="text-center">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="row" items="${poolRows}">
                                    <tr>
                                        <td>
                                            <span class="id-badge">#${row.id}</span>
                                        </td>
                                        <td>
                                            <i class="bi bi-calendar3 text-muted me-1"></i>
                                            <fmt:formatDate value="${row.distributionDate}"
                                                            pattern="dd MMM yyyy"/>
                                        </td>
                                        <td class="text-end amount">
                                            <fmt:formatNumber value="${row.interestMoved}"
                                                              pattern="#,##0.00"/>
                                        </td>
                                        <td class="text-end amount text-warning">
                                            <fmt:formatNumber value="${row.feeApplied}"
                                                              pattern="#,##0.00"/>
                                        </td>
                                        <td class="text-end amount-net">
                                            <fmt:formatNumber value="${row.netBalance}"
                                                              pattern="#,##0.00"/>
                                        </td>
                                        <td class="text-end amount">
                                            <fmt:formatNumber value="${row.feesTotal}"
                                                              pattern="#,##0.00"/>
                                            <c:if test="${row.feeCapReached}">
                                                <span class="badge bg-danger ms-1"
                                                      title="Fee cap reached">
                                                    CAP
                                                </span>
                                            </c:if>
                                        </td>

                                        <!-- STATUS -->
                                        <td>
                                            <c:choose>
                                                <c:when test="${row.pendingFees}">
                                                    <span class="badge-status pending">
                                                        <span class="dot"></span>Pending Fees
                                                    </span>
                                                </c:when>
                                                <c:when test="${row.feesCharged}">
                                                    <span class="badge-status charged">
                                                        <span class="dot"></span>Fees Charged
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-status distributed">
                                                        <span class="dot"></span>Distributed
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- NOTES -->
                                        <td class="notes-cell" title="${row.notes}">
                                            <c:out value="${row.notes}"/>
                                        </td>

                                        <!-- ACTIONS -->
                                        <td class="text-center">
                                            <div class="action-group">

                                                <%-- Cancel --%>
                                                <c:if test="${row.pendingFees}">
                                                    <form method="post" action="payoutServlet"
                                                          class="d-inline">
                                                        <input type="hidden" name="operation" value="cancelPool"/>
                                                        <input type="hidden" name="poolId"    value="${row.id}"/>
                                                        <input type="hidden" name="groupId"   value="${selectedGroupId}"/>
                                                        <button class="btn btn-icon btn-outline-danger"
                                                                title="Cancel this pool row"
                                                                onclick="return confirm('Cancel this pool row? It will be deleted, and interest will become available again.');">
                                                            <i class="bi bi-x-lg"></i>
                                                        </button>
                                                    </form>
                                                </c:if>

                                                <%-- Charge Fees --%>
                                                <c:if test="${row.pendingFees}">
                                                    <form method="post" action="payoutServlet"
                                                          class="d-inline">
                                                        <input type="hidden" name="operation" value="chargeFees"/>
                                                        <input type="hidden" name="poolId"    value="${row.id}"/>
                                                        <input type="hidden" name="groupId"   value="${selectedGroupId}"/>
                                                        <button class="btn btn-icon btn-warning text-dark"
                                                                title="Charge fees on this row"
                                                                onclick="return confirm('Charge fees on this pool row?');">
                                                            <i class="bi bi-cash-coin"></i>
                                                        </button>
                                                    </form>
                                                </c:if>

                                                <%-- Distribute --%>
                                                <c:if test="${row.feesCharged}">
                                                    <form method="post" action="payoutServlet"
                                                          class="d-inline">
                                                        <input type="hidden" name="operation" value="distributeShares"/>
                                                        <input type="hidden" name="poolId"    value="${row.id}"/>
                                                        <input type="hidden" name="groupId"   value="${selectedGroupId}"/>
                                                        <button class="btn btn-icon btn-success"
                                                                title="Distribute shares to members"
                                                                onclick="return confirm('Distribute this pool to members by contribution?');">
                                                            <i class="bi bi-send-fill"></i>
                                                        </button>
                                                    </form>
                                                </c:if>

                                                <%-- View detail --%>
                                                <a class="btn btn-icon btn-outline-primary"
                                                   href="payoutServlet?operation=viewPoolDetail&poolId=${row.id}&groupId=${selectedGroupId}"
                                                   title="View pool details">
                                                    <i class="bi bi-search"></i>
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- ==================== Footer hint ==================== -->
    <div class="text-center text-muted small mt-4">
        <i class="bi bi-info-circle me-1"></i>
        Three-step flow: <strong>Move</strong> → <strong>Charge Fees</strong> → <strong>Distribute</strong>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>