<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@include file='header.jsp'%>

<!DOCTYPE html>
<html>
<head>
<title>Administrator Page</title>
</head>
<body>

<%@ include file="jdbc.jsp" %>
<%@ include file="auth.jsp"%>
<%@ page import="java.util.Date" %>
<%@page import="java.text.SimpleDateFormat"%>

<%

// TODO: Write SQL query that prints out total order amount by day
String url = "jdbc:sqlserver://db:1433;DatabaseName=tempdb;";
String uid = "SA";
String pw = "YourStrong@Passw0rd";

Connection con = DriverManager.getConnection(url, uid, pw);

Locale locale = new Locale("en", "US");
NumberFormat currFormat = NumberFormat.getCurrencyInstance(locale); 
		
PreparedStatement pstmt1, pstmt2 = null;
ResultSet rst1, rst2 = null;

String sql1 = "SELECT YEAR(orderDate), MONTH(orderDate), DAY(orderDate), SUM(totalAmount) FROM ordersummary GROUP BY YEAR(orderDate), MONTH(orderDate), DAY(orderDate)";
String sql2 = "SELECT CAST(orderDate AS DATE), SUM(totalAmount) FROM ordersummary GROUP BY CAST(orderDate AS DATE)";
pstmt1 = con.prepareStatement(sql1); 
pstmt2 = con.prepareStatement(sql2);   
rst1 = pstmt1.executeQuery();
rst2 = pstmt2.executeQuery();

out.println("<h1>Administrator Sales Report By Day</h1>");
out.println("<table border = '1'><tr><th>Order Date</th><th>Total Order Amount</th></tr>");
while(rst1.next() && rst2.next()){
    out.println("<tr><td>"+rst1.getString(1)+"-"+rst1.getString(2)+"-"+rst1.getString(3)+"</td><td>"+currFormat.format(rst2.getDouble(2))+"</td></tr>");
}
out.println("</table>");

out.println("<h2>Customers</h2>");
Statement stmt1 = con.createStatement();
ResultSet rst3 = stmt1.executeQuery("SELECT customerId, firstName, lastName, email, phonenum, address, city, state, postalCode, country, userid, password FROM customer");
out.println("<table border = '1'><tr><th>Customer ID</th><th>First Name</th><th>Last Name</th><th>Email</th><th>Phone Number</th><th>Address</th><th>City</th><th>State</th><th>Postal Code</th><th>Country</th><th>User ID</th><th>Password</th></tr>");
while(rst3.next()) {
    out.println("<tr><td>"+rst3.getInt(1)+"</td><td>"+rst3.getString(2)+"</td><td>"+rst3.getString(3)+"</td><td>"+rst3.getString(4)+"</td><td>"+rst3.getString(5)+"</td><td>"+rst3.getString(6)+"</td><td>"+rst3.getString(7)+"</td><td>"+rst3.getString(8)+"</td><td>"+rst3.getString(9)+"</td><td>"+rst3.getString(10)+"</td><td>"+rst3.getString(11)+"</td><td>"+rst3.getString(12)+"</td></tr>");
}
out.println("</table>");

%>

<h2>Add/Update/Delete Product:</h2>
<form method="get" action="admin.jsp">
<input type="text" name="productId" placeholder="Product ID" size="6">
<input type="text" name="productName" placeholder="Product Name" size="20">
<input type="text" name="categoryId" placeholder="Category ID" size="20">
<input type="text" name="productDesc" placeholder="Description" size="20">
<input type="text" name="productPrice" placeholder="Price" size="20">
<input type="submit" name="add" value="Add">
<input type="submit" name="up" value="Update">
<input type="submit" name="del" value="Delete">
</form>

<%
String id = request.getParameter("productId");
String name = request.getParameter("productName");
String catId = request.getParameter("categoryId");
String desc = request.getParameter("productDesc");
String price = request.getParameter("productPrice");
String add = request.getParameter("add");
String up = request.getParameter("up");
String del = request.getParameter("del");

if (add != null && add.equals("Add")) {
    if ((name == null || name.equals("")) || (catId == null || catId.equals("")) || (desc == null || desc.equals("")) || (price == null || price.equals(""))) {
        out.println("<p>Must provide all fields (except Product ID) to add.</p>");
    } else {
        String sql3 = "INSERT product(productName, categoryId, productDesc, productPrice) VALUES (?, ?, ?, ?)";
        PreparedStatement pstmt3 = con.prepareStatement(sql3);
        pstmt3.setString(1, name);
        pstmt3.setInt(2, Integer.parseInt(catId));
        pstmt3.setString(3, desc);
        pstmt3.setDouble(4, Double.parseDouble(price));
        int insertProd = pstmt3.executeUpdate();
        out.println("<p>Product added.</p>");
    }
} else if (up != null && up.equals("Update")) {
    if (id == null || id.equals("")) {
        out.println("<p>Must provide Product ID to update.</p>");
    } else {
        String sql4;
        PreparedStatement pstmt4;
        int upProd;
        if (name != null && !name.equals("")) {
            sql4 = "UPDATE product SET productName = ? WHERE productId = ?";
            pstmt4 = con.prepareStatement(sql4);
            pstmt4.setString(1, name);
            pstmt4.setInt(2, Integer.parseInt(id));
            upProd = pstmt4.executeUpdate();
        }
        if (catId != null && !catId.equals("")) {
            sql4 = "UPDATE product SET categoryId = ? WHERE productId = ?";
            pstmt4 = con.prepareStatement(sql4);
            pstmt4.setInt(1, Integer.parseInt(catId));
            pstmt4.setInt(2, Integer.parseInt(id));
            upProd = pstmt4.executeUpdate();
        }
        if (desc != null && !desc.equals("")) {
            sql4 = "UPDATE product SET productDesc = ? WHERE productId = ?";
            pstmt4 = con.prepareStatement(sql4);
            pstmt4.setString(1, desc);
            pstmt4.setInt(2, Integer.parseInt(id));
            upProd = pstmt4.executeUpdate();
        }
        if (price != null && !price.equals("")) {
            sql4 = "UPDATE product SET productPrice = ? WHERE productId = ?";
            pstmt4 = con.prepareStatement(sql4);
            pstmt4.setDouble(1, Double.parseDouble(price));
            pstmt4.setInt(2, Integer.parseInt(id));
            upProd = pstmt4.executeUpdate();
        }
        out.println("<p>Product updated.</p>");
    }
} else if (del != null && del.equals("Delete")) {
    if (id == null || id.equals("")) {
        out.println("<p>Must provide Product ID to delete.</p>");
    } else {
        String sql5 = "DELETE FROM product WHERE productId = ?";
        PreparedStatement pstmt5 = con.prepareStatement(sql5);
        pstmt5.setInt(1, Integer.parseInt(id));
        int delProd = pstmt5.executeUpdate();
        out.println("<p>Product deleted.</p>");
    }
}

%>

<h2>Update/Add Inventory:</h2>
<form method="get" action="admin.jsp">
<input type="text" name="prodId" placeholder="Product ID" size="10">
<input type="text" name="warehouseId" placeholder="Warehouse ID" size="10">
<input type="text" name="quantity" placeholder="Quantity" size="10">
<input type="submit" name="upinv" value="Update">
</form>

<%
String prodId = request.getParameter("prodId");
String wid = request.getParameter("warehouseId");
String qty = request.getParameter("quantity");

if((prodId == null || prodId.equals("")) || (wid == null || wid.equals("")) || (qty == null || qty.equals(""))){
    out.println("<p>Must provide all fields to edit/add inventory.</p>");
}else{
    String sqlInv;
    PreparedStatement pstmtInv;
    double invprice = 0;
    
    sqlInv = "SELECT warehouseId FROM warehouse";
    pstmtInv = con.prepareStatement(sqlInv);
    ResultSet rstw = pstmtInv.executeQuery();
    sqlInv = "SELECT productId FROM product";
    pstmtInv = con.prepareStatement(sqlInv);
    ResultSet rstp = pstmtInv.executeQuery();

    boolean isWH = false;
    boolean isProd = false;
    boolean hasProd = false;
    while(rstw.next()){
        if(rstw.getInt(1) == Integer.parseInt(wid)){
            isWH = true;
        }
    }
    while(rstp.next()){
        if(rstp.getInt(1) == Integer.parseInt(prodId)){
            isProd = true;
        }
    }
    if(isWH && isProd) {
        sqlInv = "SELECT productPrice FROM product WHERE productId = ?";
        pstmtInv = con.prepareStatement(sqlInv);
        pstmtInv.setInt(1, Integer.parseInt(prodId));
        ResultSet rstprice = pstmtInv.executeQuery();

        rstprice.next();
        invprice = rstprice.getDouble(1);

        sqlInv = "SELECT productId FROM productinventory WHERE warehouseId = ?";
        pstmtInv = con.prepareStatement(sqlInv);
        pstmtInv.setInt(1, Integer.parseInt(wid));
        ResultSet rstpi = pstmtInv.executeQuery();
            while(rstpi.next()){
                if(rstpi.getInt(1) == Integer.parseInt(prodId)){
                    hasProd = true;
                }
            }
    }
    if (!isWH) {
        out.println("<p>Invalid Warehouse ID.</p>");
    } else if (!isProd) {
        out.println("<p>Invalid Product ID.</p>");
    } else if (!hasProd) {
        String sql6 = "INSERT INTO productinventory(productId, warehouseId, quantity, price) VALUES (?, ?, ?, ?)";
        PreparedStatement pstmt6 = con.prepareStatement(sql6);
        pstmt6.setInt(1, Integer.parseInt(prodId));
        pstmt6.setInt(2, Integer.parseInt(wid));
        pstmt6.setInt(3, Integer.parseInt(qty));
        pstmt6.setDouble(4, invprice);
        int addInv = pstmt6.executeUpdate();
        out.println("<p>Inventory added.</p>");
    } else {
        String sql7 = "UPDATE productinventory SET quantity = ? WHERE productId = ? AND warehouseId = ?";
        PreparedStatement pstmt7 = con.prepareStatement(sql7);
        pstmt7.setInt(1, Integer.parseInt(qty));
        pstmt7.setInt(2, Integer.parseInt(prodId));
        pstmt7.setInt(3, Integer.parseInt(wid));
        int updateInv = pstmt7.executeUpdate();
        out.println("<p>Inventory updated.</p>");
    }
}
%>

<form method="get" action="loaddata.jsp">
    <input type="submit" value="Reload Database">
</form>

</body>
</html>

