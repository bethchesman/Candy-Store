<%@include file='header.jsp'%>

<!DOCTYPE html>
<html>
<head>
<title>Customer Page</title>
</head>
<body>

<%@ include file="auth.jsp"%>
<%@ page import="java.text.NumberFormat" %>
<%@ include file="jdbc.jsp" %>

<%
	String username = (String) session.getAttribute("authenticatedUser");
%>

<%

// TODO: Print Customer information
String url = "jdbc:sqlserver://db:1433;DatabaseName=tempdb;";
String uid = "SA";
String pw = "YourStrong@Passw0rd";

Connection con = DriverManager.getConnection(url, uid, pw);
			
String sql = "SELECT customerId, firstName, lastName, email, phonenum, address, city, state, postalCode, country, userid FROM customer WHERE userId = ?";
PreparedStatement pstmt = con.prepareStatement(sql);
			
pstmt.setString(1, username);
ResultSet rst = pstmt.executeQuery();
						
while(rst.next()) {
	out.println("<table border='1'><tr><td>Customer ID: </td><td>"+rst.getInt(1)+"</td></tr>"+"<tr><td>First Name</td><td>"+rst.getString(2)+"</td></tr>"+"<tr><td>Last Name</td><td>"+rst.getString(3)+"</td></tr>"+"<tr><td>Email</td><td>"+rst.getString(4)+"</td></tr>"+"<tr><td>Phone Number</td><td>"+rst.getString(5)+"</td></tr>"+"<tr><td>Address</td><td>"+rst.getString(6)+"</td></tr>"+"<tr><td>City</td><td>"+rst.getString(7)+"</td></tr>"+"<tr><td>State</td><td>"+rst.getString(8)+"</td></tr>"+"<tr><td>Postal Code</td><td>"+rst.getString(9)+"</td></tr>"+"<tr><td>Country</td><td>"+rst.getString(10)+"</td></tr>"+"<tr><td>User Id</td><td>"+userName+"</td></tr></table>");
}

// Make sure to close connection
con.close();
%>

</body>
</html>

