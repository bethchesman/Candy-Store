<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Locale" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@include file='header.jsp'%>

<!DOCTYPE html>
<html>
<head>
<title>Sweets and Treats Grocery Order Processing</title>
</head>
<body>

<% 
try
{	// Load driver class
	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
}
catch (java.lang.ClassNotFoundException e)
{
	out.println("ClassNotFoundException: " + e);
}

// Make connection
String url = "jdbc:sqlserver://db:1433;DatabaseName=tempdb;";
String uid = "SA";
String pw = "YourStrong@Passw0rd";

Connection con = DriverManager.getConnection(url, uid, pw);

// Get customer id
String custId = request.getParameter("customerId");
@SuppressWarnings({"unchecked"})
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

try {

	// Determine if valid customer id was entered
	boolean valid = false;
	boolean isInt;
	try {
		Integer.parseInt(custId);
		isInt = true;
	} catch(Exception e) {
		isInt = false;
	}
	Statement stmt = con.createStatement();
	ResultSet rst1 = stmt.executeQuery("SELECT customerId FROM customer");

	while(rst1.next() && !valid && isInt){
		if (rst1.getInt(1) == Integer.parseInt(custId))
			valid = true;
	}

	// Determine if there are products in the shopping cart
	// If either are not true, display an error message

	if (!valid)
	{
		out.println("<h1>Invalid customer id. Go back to the previous page and try again.</h1>");
	}
	else if(productList == null)
	{
		out.println("<h1>Your shopping cart is empty!</h1>");
	}
	else
	{
		// Save order information to database
		// Use retrieval of auto-generated keys.
		String sql1 = "INSERT INTO ordersummary (orderDate, totalAmount, customerId) VALUES (?,?,?)";
		PreparedStatement pstmt = con.prepareStatement(sql1, Statement.RETURN_GENERATED_KEYS);	
		pstmt.setDate(1, new java.sql.Date(System.currentTimeMillis()));
		pstmt.setDouble(2, 0.0);
		pstmt.setInt(3, Integer.parseInt(custId));	
		int osInsert = pstmt.executeUpdate();	
		ResultSet keys = pstmt.getGeneratedKeys();
		keys.next();
		int orderId = keys.getInt(1);

		// Insert each item into OrderProduct table using OrderId from previous INSERT
		double total = 0;
		Iterator<Map.Entry<String, ArrayList<Object>>> iterator1 = productList.entrySet().iterator();
		while (iterator1.hasNext())
		{ 
			Map.Entry<String, ArrayList<Object>> entry = iterator1.next();
			ArrayList<Object> product = (ArrayList<Object>) entry.getValue();
			String productId = (String) product.get(0);
			String price = (String) product.get(2);
			double pr = Double.parseDouble(price);
			int qty = ( (Integer)product.get(3)).intValue();
			String sql2 = "INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (?,?,?,?)";
			PreparedStatement pstmt2 = con.prepareStatement(sql2);
			pstmt2.setInt(1, orderId);
			pstmt2.setInt(2, Integer.parseInt(productId));
			pstmt2.setInt(3, qty);
			pstmt2.setDouble(4, pr);
			int opInsert = pstmt2.executeUpdate();
			total = total + (pr*qty);
		}

		// Update total amount for order record
		String sql3 = "UPDATE ordersummary SET totalAmount = ? WHERE orderId = ?";
		PreparedStatement pstmt3 = con.prepareStatement(sql3);
		pstmt3.setDouble(1, total);
		pstmt3.setInt(2, orderId);
		int osUpdate = pstmt3.executeUpdate();

		// Print out order summary
		Locale locale = new Locale("en", "US");
		NumberFormat currFormat = NumberFormat.getCurrencyInstance(locale);

		out.println("<h1>Your Order Summary</h1>");
		out.print("<table><tr><th>Product Id</th><th>Product Name</th><th>Quantity</th>");
		out.println("<th>Price</th><th>Subtotal</th></tr>");
		Iterator<Map.Entry<String, ArrayList<Object>>> iterator2 = productList.entrySet().iterator();
		while (iterator2.hasNext()) 
		{	Map.Entry<String, ArrayList<Object>> entry = iterator2.next();
			ArrayList<Object> product = (ArrayList<Object>) entry.getValue();
			if (product.size() < 4)
			{
				out.println("Expected product with four entries. Got: "+product);
				continue;
			}
			
			out.print("<tr><td>"+product.get(0)+"</td>");
			out.print("<td>"+product.get(1)+"</td>");

			out.print("<td align=\"center\">"+product.get(3)+"</td>");
			Object price = product.get(2);
			Object itemqty = product.get(3);
			double pr = 0;
			int qty = 0;
			
			try
			{
				pr = Double.parseDouble(price.toString());
			}
			catch (Exception e)
			{
				out.println("Invalid price for product: "+product.get(0)+" price: "+price);
			}
			try
			{
				qty = Integer.parseInt(itemqty.toString());
			}
			catch (Exception e)
			{
				out.println("Invalid quantity for product: "+product.get(0)+" quantity: "+qty);
			}		

			out.print("<td align=\"right\">"+currFormat.format(pr)+"</td>");
			out.print("<td align=\"right\">"+currFormat.format(pr*qty)+"</td></tr>");
			out.println("</tr>");
		}
		out.println("<tr><td colspan=\"4\" align=\"right\"><b>Order Total</b></td>"
				+"<td align=\"right\">"+currFormat.format(total)+"</td></tr>");
		out.println("</table>");
		out.println("<h1>Order completed. Will be shipped soon...</h1>");
		out.println("<h1>Your order reference number is: "+orderId+"</h1>");
		String sql4 = "SELECT firstName, lastName FROM customer WHERE customerId = ?";
		PreparedStatement pstmt4 = con.prepareStatement(sql4);
		pstmt4.setInt(1, Integer.parseInt(custId));
		ResultSet rst4 = pstmt4.executeQuery();
		while(rst4.next()){
			out.println("<h1>Shipping to customer: "+custId+", Name: "+rst4.getString(1)+" "+rst4.getString(2)+"</h1>");
		}
		out.println("<h2><a href='shop.html'>Return to shopping</a></h2>");

		// Clear cart if order placed successfully
		session.removeAttribute("productList");

	}
	
}
catch (SQLException ex) 
{ 
	out.println(ex); 
}
finally {	
	con.close();
}

%>
</BODY>
</HTML>

