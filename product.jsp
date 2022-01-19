<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>
<%@include file='header.jsp'%>

<html>
<head>
<title>Sweets and Treats - Product Information</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

<%
// Get product name to search for
// TODO: Retrieve and display info for the product
String productId = request.getParameter("id");

String url = "jdbc:sqlserver://db:1433;DatabaseName=tempdb;";
String uid = "SA";
String pw = "YourStrong@Passw0rd";

try ( Connection con = DriverManager.getConnection(url, uid, pw);)
{   
    String sql = "SELECT productName, productPrice, productImageURL, productImage, productDesc from product WHERE productId = ?";
    PreparedStatement pstmt = con.prepareStatement(sql);
    pstmt.setString(1, productId);
    ResultSet rst = pstmt.executeQuery();

    rst.next();
    String pName = rst.getString(1);
    String pPrice = rst.getString(2);
    String pDesc = rst.getString(5);
    out.println("<h2>"+pName+"</h2>");
    String productImageURL = rst.getString(3);
    if (productImageURL!=null)
        out.println("<img src=\""+productImageURL+"\">");
    if(rst.getString(4)!=null)
        out.println("<img src=\"displayImage.jsp?id="+productId+"\">");

    out.println("<table><tr><th><b>Id: </b></th><td>"+productId+"</td></tr>");
    out.println("<tr><th><b>Price: </b></th><td>$"+pPrice+"</td></tr>");
    out.println("<tr><th><b>Description: </b></th><td>"+pDesc+"</td></tr></table>");
    
    String sql2 = "SELECT warehouseId, quantity FROM productinventory WHERE productId = ?";
    PreparedStatement pstmt2 = con.prepareStatement(sql2);
    pstmt2.setString(1, productId);
    ResultSet rst2 = pstmt2.executeQuery();
    out.println("<table border='2'><tr><th style='padding:5px'>Warehouse ID</th><th style='padding:5px'>Inventory</th></tr>");
    while(rst2.next()) {
        out.println("<tr><td style='padding:5px'>"+rst2.getInt(1)+"</td><td style='padding:5px'>"+rst2.getInt(2)+"</td></tr>");
    }
    out.println("<h3><a href = \"addcart.jsp?id=" + productId + "&name=" + pName + "&price=" + pPrice + "\">Add to Cart</a></h3>");
    out.println("<h3><a href = \"listprod.jsp\">Continue Shopping</a></h3>");
   
    con.close();
}
catch (SQLException ex) 
{ 	
    out.println(ex); 
}

// TODO: If there is a productImageURL, display using IMG tag
		
// TODO: Retrieve any image stored directly in database. Note: Call displayImage.jsp with product id as parameter.
		
// TODO: Add links to Add to Cart and Continue Shopping
%>

</body>
</html>

