<style>
    .inline-block {
  display: inline-block;
  padding: 0px 4px;
}
</style>

<div class='inline-block'><a href="index.jsp">Home Page</a></div>

<div class='inline-block'><a href="login.jsp">Login</a></div>

<div class='inline-block'><a href="listprod.jsp">Begin Shopping</a></div>

<div class='inline-block'><a href="showcart.jsp">View Cart</a></div>

<div class='inline-block'><a href="listorder.jsp">List All Orders</a></div>

<div class='inline-block'><a href="customer.jsp">Customer Info</a></div>

<div class='inline-block'><a href="admin.jsp">Administrators</a></div>

<div class='inline-block'><a href="logout.jsp">Log out</a></div>

<%
String userName = (String) session.getAttribute("authenticatedUser");
if (userName != null) {
        out.println("<div style='float:right'>You are logged in as: " + userName + "</div>");
}	
%>
<hr>
