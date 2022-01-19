<%@ page import="java.sql.*,java.net.URLEncoder" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@include file='header.jsp'%>

<!DOCTYPE html>
<html>
<head>
<title>Sweets and Treats Grocery</title>
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

<div id = search style = "background-color: rgb(250, 135, 230); padding: 0.5em;">
<h1>Search for the products you want to buy:</h1>
<form method="get" action="listprod.jsp">
<input type="text" name="productName" placeholder="Product Name" size="50"><input type="text" name="categoryId" placeholder="Category ID" size="8">
<input type="submit" value="Submit"><input type="reset" value="Reset"> (Leave blank for all products)
</form>
<h3><a href="checkout.jsp">Check Out</a></h3>
</div>


<% // Get product name to search for
String name = request.getParameter("productName");
String catId = request.getParameter("categoryId");
		
//Note: Forces loading of SQL Server driver
try
{	// Load driver class
	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
}
catch (java.lang.ClassNotFoundException e)
{
	out.println("ClassNotFoundException: " +e);
}

// Variable name now contains the search string the user entered
// Use it to build a query and print out the resultset.  Make sure to use PreparedStatement!

// Make the connection
String url = "jdbc:sqlserver://db:1433;DatabaseName=tempdb;";
String uid = "SA";
String pw = "YourStrong@Passw0rd";

Connection con = DriverManager.getConnection(url, uid, pw);

// Print out the ResultSet
try {
	Statement stmt = con.createStatement(); 
	String sql = "SELECT productId, productName, productPrice FROM product";
	
	boolean hasName = name != null && !name.equals("");
	boolean hasCatId = catId != null && !catId.equals("");

	PreparedStatement pstmt = null;
	ResultSet rst = null;

	Locale locale = new Locale("en", "US");
	NumberFormat currFormat = NumberFormat.getCurrencyInstance(locale);

	out.println("<table><tr><th> </th><th>Product Name</th><th>Price</th></tr>");
		
		if(!hasName) {
			if (!hasCatId) {
				pstmt = con.prepareStatement(sql);
				rst = pstmt.executeQuery();
			} else {
				sql += " WHERE categoryId = ?";
				pstmt = con.prepareStatement(sql);
				pstmt.setInt(1, Integer.parseInt(catId));
				rst = pstmt.executeQuery();
			}
		} else if (hasName) {
			name = "%" + name + "%";
			if (!hasCatId) {
				sql += " WHERE productName LIKE ?";
				pstmt = con.prepareStatement(sql);
				pstmt.setString(1, name);
				rst = pstmt.executeQuery();
			} else {
				sql += " WHERE productName LIKE ? AND categoryId = ?";
				pstmt = con.prepareStatement(sql);
				pstmt.setString(1, name);
				pstmt.setInt(2, Integer.parseInt(catId));
				rst = pstmt.executeQuery();
			}
		} 

		sql = pstmt.toString();

		// For each product create a link of the form
		// addcart.jsp?id=productId&name=productName&price=productPrice
			while(rst.next()){
				String link = "\"addcart.jsp?id=" + rst.getString(1) + "&name=" + rst.getString(2) + "&price=" + rst.getString(3) + "\"";
				String linkprod = "\"product.jsp?id=" + rst.getString(1) + "\"";
				out.println("<tr><td><a href="+ link +">Add to Cart</a></td><td><a href="+ linkprod +">"+rst.getString(2)+"</a></td>"+"<td>"+currFormat.format(rst.getDouble(3))+"</td></tr>");
			}
				
	out.println("</table>");
	
} catch (SQLException ex) {
	out.println(ex);
} finally {
	// Close connection
	con.close();	
}

%>

</body>
</html>