<!DOCTYPE html>
<html>
<head>
        <title>Sweets and Treats Main Page</title>
        <style>
                body {
                   background-image: url("img/candy.jpg");
                   font-weight: bold;
                }
        </style>
</head>
<body style="text-align:center">
<h1 style="color:white">Welcome to Sweets and Treats Grocery</h1>

<h2><a href="login.jsp" style="color: rgb(250, 135, 230);">Login</a></h2>

<h2><a href="listprod.jsp" style="color: rgb(250, 135, 230);">Begin Shopping</a></h2>

<h2><a href="showcart.jsp" style="color: rgb(250, 135, 230);">View Cart</a></h2>

<h2><a href="listorder.jsp" style="color: rgb(250, 135, 230);">List All Orders</a></h2>

<h2><a href="customer.jsp" style="color: rgb(250, 135, 230);">Customer Info</a></h2>

<h2><a href="admin.jsp" style="color: rgb(250, 135, 230);">Administrators</a></h2>

<h2><a href="logout.jsp" style="color: rgb(250, 135, 230);">Log out</a></h2>

<%
// TODO: Display user name that is logged in (or nothing if not logged in)
String userName = (String) session.getAttribute("authenticatedUser");
if (userName != null) {
        out.println("<p style='color:white'>You are logged in as: " + userName + "</p>");
}	
%>

<form method="get" action="listprod.jsp" style="display:inline-block">
        <input type="image" alt="submit" src="img/asia.jpg" width="75" height="75">
        <input type="hidden" name="categoryId" value="1"> 
        <p style="color:black">Asian</p>
</form>
<form method="get" action="listprod.jsp" style="display:inline-block">
        <input type="image" src="img/hispanic.jpg" alt="submit" width="75" height="75">
        <input type="hidden" name="categoryId" value="2"> 
        <p style="color:black">Hispanic</p>
</form>
<form method="get" action="listprod.jsp" style="display:inline-block">
        <input type="image" src="img/europe.jpg" alt="submit" width="75" height="75">
        <input type="hidden" name="categoryId" value="3"> 
        <p style="color:black">European</p>
</form>
<form method="get" action="listprod.jsp" style="display:inline-block">
        <input type="image" src="img/canada.jpg" alt="submit" width="75" height="75">
        <input type="hidden" name="categoryId" value="4"> 
        <p style="color:black">Canadian</p>
</form>

</body>
</head>


