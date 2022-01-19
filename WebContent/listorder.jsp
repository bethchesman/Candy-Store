<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@include file='header.jsp'%>

<!DOCTYPE html>
<html>
<head>
<title>Sweets and Treats Grocery Order List</title>
</head>
<body>
<style>
th {
	background-color: #cacaca;
	padding: 0.75em;
	border-bottom: 2px solid rgb(250, 135, 230);
	border-left: 1px solid black;
	border-right: 1px solid black;
	border-top: 1px solid black;
	text-align: left;
	
}

table tr:nth-child(even) {
	background-color: lightgray;
}

table td {
	padding: 0.5em;
	border: 1px solid black;
	
}

table {
	border-collapse: collapse;
	margin-top: 0.5em;
	width: 100%;
	
}
</style>
<h1>Order List</h1>

<%
//Note: Forces loading of SQL Server driver
try
{	// Load driver class
	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
}
catch (java.lang.ClassNotFoundException e)
{
	out.println("ClassNotFoundException: " +e);
}

// Make connection
String url = "jdbc:sqlserver://db:1433;DatabaseName=tempdb;";
String uid = "SA";
String pw = "YourStrong@Passw0rd";

Connection con = DriverManager.getConnection(url, uid, pw);

// Write query to retrieve all order summary records

// For each order in the ResultSet

	// Print out the order summary information
	// Write a query to retrieve the products in the order
	//   - Use a PreparedStatement as will repeat this query many times
	// For each product in the order
		// Write out product information 
try 
{	
	Statement stmt = con.createStatement();
	ResultSet rst1 = stmt.executeQuery("SELECT orderId,orderDate,os.customerId,CONCAT(firstName,' ',lastName) AS customerName,totalAmount FROM ordersummary os JOIN customer c ON os.customerId = c.customerId");	
	
	String sql = "SELECT productId,quantity,price FROM orderproduct op JOIN ordersummary os ON op.orderId = os.orderId WHERE op.orderId = ?";
	PreparedStatement pstmt = con.prepareStatement(sql);
	
	out.println("<table border='2'><tr><th>Order Id</th><th>Order Date</th><th>Customer Id</th><th>Customer Name</th><th>Total Amount</th></tr>");
	while (rst1.next())
	{	pstmt.setInt(1, rst1.getInt(1));
		ResultSet rst2 = pstmt.executeQuery();
		Locale locale = new Locale("en", "US");
		NumberFormat currFormat = NumberFormat.getCurrencyInstance(locale); 
		out.println("<tr><td>"+rst1.getInt(1)+"</td>"+"<td>"+rst1.getString(2)+"</td>"+"<td>"+rst1.getInt(3)+"</td>"+"<td>"+rst1.getString(4)+"</td>"+"<td>"+currFormat.format(rst1.getDouble(5))+"</td></tr>");
		out.println("<tr><td style='border: 1px solid transparent' colspan='2'><table border='1'><tr><th>Product Id</th><th>Quantity</th><th>Price</th></tr>");
		while (rst2.next())
		{	out.println("<tr><td>"+rst2.getInt(1)+"</td>"+"<td>"+rst2.getInt(2)+"</td>"+"<td>"+currFormat.format(rst2.getDouble(3))+"</td></tr>");
		}	
		out.println("</table></tr></td>");
		out.println("<tr><td style='border: 1px solid transparent' colspan='5'><hr></td></tr>");
	}
	out.println("</table>");
}
catch (SQLException ex) 
{ 	out.println(ex); 
}
// Close connection
%>

</body>
</html>

