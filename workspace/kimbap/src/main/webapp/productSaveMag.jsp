<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ include file="globalVar.jsp"%>
<%@ include file="dbconn.jsp"%>

<%
String method = request.getParameter("actionMethod");
String shopUuid = sShopUuid;
String productUuid = request.getParameter("productUuid");
String categoryCd = request.getParameter("categoryCd");
String productName = request.getParameter("productName");
String price = request.getParameter("productPrice");
String qty = request.getParameter("productQuantity");
String desc = request.getParameter("productDesc");
String sort = request.getParameter("productSort");

PreparedStatement pstmt = null;
try {
	if ("I".equals(method)) {
		String sql = "INSERT INTO KB_Product (SHOP_UUID, PRODUCT_UUID, CATEGORY_CD, PRODUCT_NAME, PRODUCT_PRICE, PRODUCT_QUANTITY, PRODUCT_DESC, PRODUCT_SORT, REG_DT) "
		           + "VALUES (?, SYS_GUID(), ?, ?, ?, ?, ?, ?, SYSDATE)";
		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, shopUuid);
		pstmt.setString(2, categoryCd);
		pstmt.setString(3, productName);
		pstmt.setInt(4, Integer.parseInt(price));
		pstmt.setInt(5, Integer.parseInt(qty));
		pstmt.setString(6, desc);
		pstmt.setString(7, sort);
	} else if ("U".equals(method)) {
		String sql = "UPDATE KB_Product SET CATEGORY_CD=?, PRODUCT_NAME=?, PRODUCT_PRICE=?, PRODUCT_QUANTITY=?, PRODUCT_DESC=?, PRODUCT_SORT=?, UPT_DT=SYSDATE "
		           + "WHERE SHOP_UUID=? AND PRODUCT_UUID=?";
		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, categoryCd);
		pstmt.setString(2, productName);
		pstmt.setInt(3, Integer.parseInt(price));
		pstmt.setInt(4, Integer.parseInt(qty));
		pstmt.setString(5, desc);
		pstmt.setString(6, sort);
		pstmt.setString(7, shopUuid);
		pstmt.setString(8, productUuid);
	}
	pstmt.executeUpdate();
	response.sendRedirect("productMag.jsp");
} catch (Exception e) {
	e.printStackTrace();
	out.println("오류 발생: " + e.getMessage());
} finally {
	if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
	if (conn  != null) try { conn.close();  } catch (SQLException ignore) {}
}
%>
