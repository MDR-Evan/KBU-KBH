<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="globalVar.jsp"%>
<%@ include file="dbconn.jsp"%>
<!DOCTYPE html>
<html>
<body onload="document.redirectForm.submit();">
<%
ResultSet rs = null;
PreparedStatement pstmt = null;

try {
	String sOrderUuid = "";
	int iMasterResult = 0;
	int iItemResult = 0;
	int iCartDelResult = 0;

	// 주문 UUID 생성
	String keySql = "SELECT SYS_GUID() AS UUID FROM DUAL";
	pstmt = conn.prepareStatement(keySql);
	rs = pstmt.executeQuery();
	if (rs.next()) {
		sOrderUuid = rs.getString("UUID");
	}
	rs.close();
	pstmt.close();

	// 총 합계 가격 구하기
	String totPriceSql = 
		"SELECT SUM(B.PRODUCT_PRICE * A.QUANTITY) TOT_PRICE " +
		" FROM KB_Cart A " +
		" INNER JOIN KB_Product B ON A.PRODUCT_UUID = B.PRODUCT_UUID AND A.SHOP_UUID = B.SHOP_UUID " +
		" WHERE A.SHOP_UUID = ? AND A.SHOP_DEVICE_ID = ? " +
		" GROUP BY A.SHOP_UUID, A.SHOP_DEVICE_ID";

	pstmt = conn.prepareStatement(totPriceSql);
	pstmt.setString(1, sShopUuid);
	pstmt.setString(2, sShopDeviceId);
	rs = pstmt.executeQuery();

	int iTotalPrice = 0;
	if (rs.next()) {
		iTotalPrice = rs.getInt("TOT_PRICE");
	}
	rs.close();
	pstmt.close();

	if (iTotalPrice > 0) {
		// 주문 마스터 등록
		String masterSql = 
			"INSERT INTO KB_Order_Master (SHOP_UUID, ORDER_UUID, ORDER_STATUS, TOT_PRICE, REG_DT) " +
			"VALUES (?, ?, 'PC', ?, SYSDATE)";
		pstmt = conn.prepareStatement(masterSql);
		pstmt.setString(1, sShopUuid);
		pstmt.setString(2, sOrderUuid);
		pstmt.setInt(3, iTotalPrice);
		iMasterResult = pstmt.executeUpdate();
		pstmt.close();
	} else {
		out.println("<script>alert('선택된 상품이 없습니다.'); history.back();</script>");
	}

	if (iMasterResult > 0) {
		// 주문 상세 등록
		String itemSql =
			"INSERT INTO KB_Order_Item (ORDER_ITEM_UUID, SHOP_UUID, ORDER_UUID, PRODUCT_UUID, QUANTITY, PRICE, REG_DT) " +
			"SELECT SYS_GUID(), A.SHOP_UUID, ?, A.PRODUCT_UUID, A.QUANTITY, B.PRODUCT_PRICE, SYSDATE " +
			" FROM KB_Cart A " +
			" INNER JOIN KB_Product B ON A.PRODUCT_UUID = B.PRODUCT_UUID AND A.SHOP_UUID = B.SHOP_UUID " +
			" WHERE A.SHOP_UUID = ? AND A.SHOP_DEVICE_ID = ?";
		pstmt = conn.prepareStatement(itemSql);
		pstmt.setString(1, sOrderUuid);
		pstmt.setString(2, sShopUuid);
		pstmt.setString(3, sShopDeviceId);
		iItemResult = pstmt.executeUpdate();
		pstmt.close();

		// 재고 차감
		String updateSql =
			"UPDATE KB_Product A SET A.PRODUCT_QUANTITY = A.PRODUCT_QUANTITY - " +
			" (SELECT B.QUANTITY FROM KB_Cart B " +
			"  WHERE B.SHOP_UUID = ? AND B.SHOP_DEVICE_ID = ? AND A.PRODUCT_UUID = B.PRODUCT_UUID) " +
			"WHERE EXISTS (SELECT 1 FROM KB_Cart B " +
			" WHERE B.SHOP_UUID = ? AND B.SHOP_DEVICE_ID = ? AND A.PRODUCT_UUID = B.PRODUCT_UUID)";
		pstmt = conn.prepareStatement(updateSql);
		pstmt.setString(1, sShopUuid);
		pstmt.setString(2, sShopDeviceId);
		pstmt.setString(3, sShopUuid);
		pstmt.setString(4, sShopDeviceId);
		pstmt.executeUpdate();
		pstmt.close();
	}

	if (iItemResult > 0) {
		// 장바구니 비우기
		String cartDelSql = 
			"DELETE FROM KB_Cart WHERE SHOP_UUID = ? AND SHOP_DEVICE_ID = ?";
		pstmt = conn.prepareStatement(cartDelSql);
		pstmt.setString(1, sShopUuid);
		pstmt.setString(2, sShopDeviceId);
		iCartDelResult = pstmt.executeUpdate();
		pstmt.close();
	}

	if (iItemResult > 0 && iCartDelResult > 0) {
		out.println("<script>alert('주문되었습니다.');</script>");
	}
} catch (SQLException ex) {
	out.println("SQLException: " + ex.getMessage());
	ex.printStackTrace();
} finally {
	if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
	if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>

<form id="redirectForm" name="redirectForm" action="product.jsp" method="post">
	<input type="hidden" name="categoryCd" value="01" />
</form>
</body>
</html>
