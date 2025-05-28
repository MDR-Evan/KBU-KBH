<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
String categoryCd = request.getParameter("categoryCd");
if (categoryCd == null)
	categoryCd = "01"; // 기본 선택값 설정
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>메뉴 선택</title>
<style>
#menuArea {
	text-align: center;
	background: #cc0000;
	margin: 0;
	padding: 15px 0;
}

#menuArea ul {
	list-style: none;
	padding: 0;
	margin: 0;
	display: flex;
	justify-content: center;
	gap: 15px;
}

#menuArea a {
	text-decoration: none;
	padding: 30px 50px;
	color: #fff;
	font-size: 18px;
	border-radius: 8px;
	font-weight: bold;
	display: inline-block;
	transition: background-color 0.3s ease;
}

#menuArea a:hover {
	background-color: #d2691e;
}

#menuArea a.active {
	background-color: #8B4513; /* 선택된 메뉴 색상 */
	color: #fff;
}
</style>
<script>
	function goMenu(categoryCd) {
		var frm = document.getElementById("frmMenu");
		frm.categoryCd.value = categoryCd;
		frm.submit();
	}
</script>
</head>
<body>
	<form id="frmMenu" name="frmMenu" method="get" action="product.jsp">
		<input type="hidden" id="categoryCd" name="categoryCd"
			value="<%=categoryCd%>">
	</form>

	<nav id="menuArea">
		<ul>
			<li><a href="#" onclick="goMenu('01');"
				class="<%="01".equals(categoryCd) ? "active" : ""%>">김밥류</a></li>
			<li><a href="#" onclick="goMenu('02');"
				class="<%="02".equals(categoryCd) ? "active" : ""%>">분식류</a></li>
			<li><a href="#" onclick="goMenu('03');"
				class="<%="03".equals(categoryCd) ? "active" : ""%>">식사류</a></li>
			<li><a href="#" onclick="goMenu('04');"
				class="<%="04".equals(categoryCd) ? "active" : ""%>">돈까스류</a></li>
		</ul>
	</nav>
</body>
</html>
