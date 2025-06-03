<%@ page import="java.sql.*, java.text.DecimalFormat"%>
<%@ include file="globalVar.jsp"%>
<%@ include file="dbconn.jsp"%>

<%
DecimalFormat df = new DecimalFormat("###,###");
String sCategoryCd = request.getParameter("categoryCd");
long lTotPrice = 0;

ResultSet rs = null;
PreparedStatement pstmt = null;
try {
	String sql = "SELECT A.CART_UUID, B.PRODUCT_NAME, B.PRODUCT_PRICE, A.QUANTITY " + 
								"FROM KB_Cart A "+ 
								"JOIN KB_Product B ON A.PRODUCT_UUID = B.PRODUCT_UUID "+ 
								"WHERE A.SHOP_UUID = ? AND A.SHOP_DEVICE_ID = ? " + 
								"ORDER BY A.REG_DT ASC";

	pstmt = conn.prepareStatement(sql);
	pstmt.setString(1, sShopUuid);
	pstmt.setString(2, sShopDeviceId);
	rs = pstmt.executeQuery();

	int itemCount = 0;
	while (rs.next()) {
		String sCartUuid = rs.getString("CART_UUID");
		String sProductName = rs.getString("PRODUCT_NAME");
		long lPrice = rs.getLong("PRODUCT_PRICE");
		int quantity = rs.getInt("QUANTITY");
		long lineTotal = lPrice * quantity;
		lTotPrice += lineTotal;
		itemCount++;
	}
	if (itemCount == 0) {
	}
} catch (SQLException e) {
	out.println("장바구니 조회 오류: " + e.getMessage());
} finally {
	if (rs != null) rs.close();
	if (pstmt != null) pstmt.close();
	if (conn != null) conn.close();
}
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<style>
* {
	box-sizing: border-box;
	font-family: 'Nanum Gothic', sans-serif;
}

body {
	margin: 0;
	padding: 0;
	background: #fffdf5;
	min-height: 100vh;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
}

.login-box {
	background: #fff;
	padding: 36px 28px;
	border-radius: 18px;
	box-shadow: 0 6px 18px rgba(0, 0, 0, 0.09);
	width: 340px;
	margin-bottom: 24px;
	border: 1.5px solid #f4ede5;
}

.login-box h1 {
	text-align: center;
	margin-bottom: 26px;
	font-size: 26px;
	font-family: 'Nanum Gothic', sans-serif;
	font-weight: bold;
	letter-spacing: 2px;
}

.login-box label {
	display: block;
	margin-bottom: 7px;
	color: #333;
	font-weight: bold;
	font-size: 15px;
}

.login-box input[type="text"] {
	width: 100%;
	padding: 11px;
	border: 1.5px solid #eee6d9;
	border-radius: 10px;
	margin-bottom: 18px;
	font-size: 15px;
	background: #fffdf5;
	transition: border 0.2s;
}

.login-box input[type="text"]:focus {
	border-color: #e94826;
	outline: none;
	background: #fff;
}

.login-box input[type="submit"] {
	width: 100%;
	padding: 13px 0;
	background: #e94826;
	color: #fff;
	border: none;
	border-radius: 10px;
	font-size: 16px;
	font-weight: bold;
	cursor: pointer;
	transition: background 0.22s;
	margin-bottom: 7px;
}

.login-box input[type="submit"]:hover {
	background: #c33c1d;
}

.login-box button[type="button"] {
	width: 100%;
	padding: 13px 0;
	background: #22b573;
	color: #fff;
	border: none;
	border-radius: 10px;
	font-size: 16px;
	font-weight: bold;
	cursor: pointer;
	transition: background 0.2s;
	margin-top: 2px;
}

.login-box button[type="button"]:hover {
	background: #149a49;
}

.login-box form {
	margin-bottom: 7px;
}
</style>
</head>
<script>
	function processPayment() {
		if (confirm("결제 하시겠습니까?")) {
			document.getElementById("frmPay").submit();
		}
	}
</script>
<body>
	<div class="login-box">
		<h1>
			<span style="color: #e94826;">결</span> 
			<span style="color: #222;">제</span>
			<span style="color: #22b573;">하</span> 
			<span style="color: #e94826;">기</span>
		</h1>

		<form action="login_confirm.jsp" method="post">
			<label>전화번호</label>
			<input type="text" name="PHONE_NUM"> 
			<input type="hidden" name="shopDeviceId" value="<%=sShopDeviceId%>">
			<input type="hidden" name="categoryCd" value="<%=sCategoryCd%>">
			<input type="submit" value="로그인" />
		</form>
		<!-- 회원가입 -->
		<form action="register.jsp" method="post">
			<input type="submit" value="회원가입">
		</form>
		<!-- 적립없이 결제 버튼 -->
		<button type="button" onclick="processPayment()">적립없이 결제</button>
		<form id="frmPay" method="post" action="paySave.jsp">
			<input type="hidden" name="shopDeviceId" value="<%=sShopDeviceId%>">
			<input type="hidden" name="categoryCd" value="<%=sCategoryCd%>">
		</form>
	</div>
</body>
</html>