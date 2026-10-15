<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Loan Fund Allocation</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .form-box { width: 400px; margin: auto; padding: 20px; border: 1px solid #ccc; border-radius: 8px; }
        label { display: block; margin-bottom: 8px; font-weight: bold; }
        input[type="text"] { width: 100%; padding: 8px; margin-bottom: 12px; }
        input[type="submit"] { background-color: #4CAF50; color: white; padding: 10px 20px; border: none; cursor: pointer; }
        input[type="submit"]:hover { background-color: #45a049; }
    </style>
</head>
<body>
<div class="form-box">
    <h2>Allocate Loan Fund</h2>
    <form action="loanBoardServlet" method="post">
        <label for="Percentage">Enter The Percentage:</label>
        <input type="text" id="Percentage" name="Percentage" placeholder="e.g. 0.60 for 60%" required>

        <input type="submit" value="Save Allocation">
    </form>
</div>
</body>
</html>
