<%@ page import="java.sql.*, java.text.DecimalFormat" %>
<%@ include file="globalVar.jsp" %>
<%@ include file="dbconn.jsp" %>

<%
	DecimalFormat df = new DecimalFormat("###,###");
	String sCategoryCd = request.getParameter("categoryCd");
	long lTotPrice = 0;
	
	ResultSet rs = null;
	PreparedStatement pstmt = null;
	try {
		String sql = "SELECT A.CART_UUID, B.PRODUCT_NAME, B.PRODUCT_PRICE, A.QUANTITY " +
					 "FROM KB_Cart A " +
					 "JOIN KB_Product B ON A.PRODUCT_UUID = B.PRODUCT_UUID " +
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
	</head>
	<script>
		function processPayment() {
			if (confirm("결제 하시겠습니까?")) {
				document.getElementById("frmPay").submit();
			}
		}
	</script>
	<body>
		<div>
			<h1>로그인</h1>
			<form action="login_confirm.jsp" post="method">
				<label>전화번호: <input type="text" name="PHONE_NUM"></label>
				<input type="submit" value="로그인" />
			</form>
		</div>
		
		<!-- 회원가입 -->
		<form action="register.jsp" method="post">
			<input type="submit" value="회원가입">
		</form>
		
		<!-- 적립없이 결제 버튼 -->
		<div><button type="button" onclick="processPayment()">적립없이 결제</button></div>
		<form id="frmPay" method="post" action="paySave.jsp">
			<input type="hidden" name="shopDeviceId" value="<%=sShopDeviceId%>">
			<input type="hidden" name="categoryCd" value="<%=sCategoryCd%>">
		</form>
	</body>
</html>