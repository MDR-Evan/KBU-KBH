<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    String adminId = (String) session.getAttribute("adminId");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport"
	content="width=device-width, initial-scale=1.0, maximum-scale=1.0,
minimum-scale=1.0, user-scalable=no">
<link href="//fonts.googleapis.com/earlyaccess/nanumgothic.css" rel="stylesheet" type="text/css">
<link href="./style.css?v=20240521" rel="stylesheet" type="text/css">
</head>
<body>
	<div class="header_container" style="background: white;">
		<div class="header_left">
			<img src="./images/logo.png" style="width: 110px; height: 110px; margin-top: 10px;"/>
		</div>
		<div class="header_center">
			<span class="brand">김밥지옥</span> <span class="sub">키오스크</span>
		</div>
		<div class="header_right">
			<%
				if (isAdmin != null && isAdmin) {
			%>
				<span><%= adminId %>님</span>
				<a href="adminLogout.jsp" style="margin-left: 10px;">로그아웃</a>
			<%
				} else {
			%>
				<a href="adminLogin.jsp">관리자</a>
			<%
				}
			%>
		</div>
	</div>
</body>
</html>
