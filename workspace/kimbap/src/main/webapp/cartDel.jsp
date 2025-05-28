<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="globalVar.jsp" %>
<%@ include file="dbconn.jsp" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>장바구니 항목 처리</title>
</head>
<body onload="document.redirectForm.submit();">
<%
	request.setCharacterEncoding("UTF-8");

	String sProcessType = request.getParameter("processType");  // "P"=개별삭제, "A"=전체삭제, "U-"=수량감소, "U+"=수량증가
	String sCartUuid = request.getParameter("cartUuid");
	String sCategoryCd = request.getParameter("categoryCd");

	PreparedStatement pstmt = null;
	ResultSet rs = null;

	try {
		if ("U-".equals(sProcessType)) {
			// 수량 감소 (1개면 삭제, 2개 이상이면 -1)
			String sqlQty = "SELECT QUANTITY FROM KB_Cart WHERE SHOP_UUID = ? AND SHOP_DEVICE_ID = ? AND CART_UUID = ?";
			pstmt = conn.prepareStatement(sqlQty);
			pstmt.setString(1, sShopUuid);
			pstmt.setString(2, sShopDeviceId);
			pstmt.setString(3, sCartUuid);
			rs = pstmt.executeQuery();
			int quantity = 0;
			if (rs.next()) {
				quantity = rs.getInt("QUANTITY");
			}
			rs.close();
			pstmt.close();

			if (quantity > 1) {
				String sql = "UPDATE KB_Cart SET QUANTITY = QUANTITY - 1 WHERE SHOP_UUID = ? AND SHOP_DEVICE_ID = ? AND CART_UUID = ?";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, sShopUuid);
				pstmt.setString(2, sShopDeviceId);
				pstmt.setString(3, sCartUuid);
				pstmt.executeUpdate();
				pstmt.close();
			} else {
				String sql = "DELETE FROM KB_Cart WHERE SHOP_UUID = ? AND SHOP_DEVICE_ID = ? AND CART_UUID = ?";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, sShopUuid);
				pstmt.setString(2, sShopDeviceId);
				pstmt.setString(3, sCartUuid);
				pstmt.executeUpdate();
				pstmt.close();
			}
		} else if ("U+".equals(sProcessType)) {
			// 수량 증가
			String sql = "UPDATE KB_Cart SET QUANTITY = QUANTITY + 1 WHERE SHOP_UUID = ? AND SHOP_DEVICE_ID = ? AND CART_UUID = ?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, sShopUuid);
			pstmt.setString(2, sShopDeviceId);
			pstmt.setString(3, sCartUuid);
			pstmt.executeUpdate();
			pstmt.close();
		} else if ("P".equals(sProcessType)) {
			// 개별 상품 삭제
			String sql = "DELETE FROM KB_Cart WHERE SHOP_UUID = ? AND SHOP_DEVICE_ID = ? AND CART_UUID = ?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, sShopUuid);
			pstmt.setString(2, sShopDeviceId);
			pstmt.setString(3, sCartUuid);
			pstmt.executeUpdate();
			pstmt.close();
		} else if ("A".equals(sProcessType)) {
			// 전체 삭제
			String sql = "DELETE FROM KB_Cart WHERE SHOP_UUID = ? AND SHOP_DEVICE_ID = ?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, sShopUuid);
			pstmt.setString(2, sShopDeviceId);
			pstmt.executeUpdate();
			pstmt.close();
		}
	} catch (SQLException ex) {
		out.println("장바구니 삭제/수정 중 오류 발생: " + ex.getMessage());
		ex.printStackTrace();
	} finally {
		if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
		if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
		if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
	}
%>

<form id="redirectForm" name="redirectForm" action="product.jsp" method="post">
	<input type="hidden" name="categoryCd" value="<%=sCategoryCd%>" />
</form>
</body>
</html>
