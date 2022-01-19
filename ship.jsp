<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Date" %>
<%@ include file="jdbc.jsp" %>

<html>
<head>
<title>Sweets and Treats Grocery Shipment Processing</title>
</head>
<body>
        
<%@ include file="header.jsp" %>

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

try (Connection con = DriverManager.getConnection(url, uid, pw);) {
	// TODO: Get order id
	String ordId = request.getParameter("orderId");
          
	// TODO: Check if valid order id
	boolean valid = false;
	boolean isInt;
	boolean empty = false;
	try {
		Integer.parseInt(ordId);
		isInt = true;
	} catch(Exception e) {
		isInt = false;
	}
	Statement stmt1 = con.createStatement();
	ResultSet rst1 = stmt1.executeQuery("SELECT orderId FROM ordersummary");

	while (rst1.next() && !valid && isInt) {
		if (rst1.getInt(1) == Integer.parseInt(ordId))
			valid = true;
	}

	if (valid) {
		String sql1 = "SELECT totalAmount FROM ordersummary WHERE orderId = ?";
		PreparedStatement pstmt1 = con.prepareStatement(sql1);
		pstmt1.setInt(1, Integer.parseInt(ordId));
		ResultSet prst1 = pstmt1.executeQuery();
		while(prst1.next()){
			if (prst1.getDouble(1) <= 0) {
				empty = true;
			}
		}
	}


	if (!valid)
	{
		out.println("<h1>Invalid order id.</h1>");
	}
	else if(empty)
	{
		out.println("<h1>No items in order.</h1>");
	}
	else
	{
	// TODO: Start a transaction (turn-off auto-commit)
	con.setAutoCommit(false);
	
	// TODO: Retrieve all items in order with given id
	String sql2 = "SELECT productId, quantity FROM orderproduct WHERE orderId = ?";
	PreparedStatement pstmt2 = con.prepareStatement(sql2);
	pstmt2.setInt(1, Integer.parseInt(ordId));
	ResultSet prst2 = pstmt2.executeQuery();
	con.commit();

	// TODO: Create a new shipment record.
	String sql3 = "INSERT INTO shipment(shipmentDate, warehouseId) VALUES (?,?)";
	PreparedStatement pstmt3 = con.prepareStatement(sql3);
	pstmt3.setDate(1, new java.sql.Date(System.currentTimeMillis()));
	pstmt3.setInt(2, 1);
	int shipInsert = pstmt3.executeUpdate();

	// TODO: For each item verify sufficient quantity available in warehouse 1.
	// TODO: If any item does not have sufficient inventory, cancel transaction and rollback. Otherwise, update inventory for each item.
	boolean oos = false;
	while (prst2.next() && !oos) {
		String sql4 = "SELECT quantity FROM productinventory WHERE productId = ? AND warehouseId = ?";
		PreparedStatement pstmt4 = con.prepareStatement(sql4);
		pstmt4.setInt(1, prst2.getInt(1));
		pstmt4.setInt(2, 1);
		ResultSet prst4 = pstmt4.executeQuery();
		while (prst4.next()) {
			if (prst2.getInt(2) > prst4.getInt(1)) {
				out.println("<h1>Shipment not processed. Insufficient inventory for product id: "+prst2.getInt(1)+"</h1>");
				con.rollback();
				oos = true;
			} else {
				int newinv = prst4.getInt(1) - prst2.getInt(2);
				out.println("<h2>Ordered product: "+prst2.getInt(1)+" Quantity: "+prst2.getInt(2)+" Previous inventory: "+prst4.getInt(1)+" New inventory: "+newinv+"</h2>");
				String sql5 = "UPDATE productinventory SET quantity = ? WHERE productId = ? AND warehouseId = ?";
				PreparedStatement pstmt5 = con.prepareStatement(sql5);
				pstmt5.setInt(1, newinv);
				pstmt5.setInt(2, prst2.getInt(1));
				pstmt5.setInt(3, 1);
				int piUpdate = pstmt5.executeUpdate();
			}
		}
	}
	if (!oos) {
		con.commit();
	}
	
	// TODO: Auto-commit should be turned back on
	con.setAutoCommit(true);

	}
} catch (SQLException ex) {
	out.println(ex);
}
%>                       				

<h2><a href="index.jsp">Back to Main Page</a></h2>

</body>
</html>
