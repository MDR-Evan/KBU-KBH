<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ include file="globalVar.jsp"%>
<%@ include file="dbconn.jsp"%>

<%
String shopUuid = sShopUuid;
String productUuid = request.getParameter("productUuid");

PreparedStatement pstmt = null;
try {
	String sql = "DELETE FROM KB_Product WHERE SHOP_UUID = ? AND PRODUCT_UUID = ?";
	pstmt = conn.prepareStatement(sql);
	pstmt.setString(1, shopUuid);
	pstmt.setString(2, productUuid);
	pstmt.executeUpdate();

	response.sendRedirect("productMag.jsp");
} catch (Exception e) {
	e.printStackTrace();
	out.println("삭제 오류: " + e.getMessage());
} finally {
	if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
	if (conn  != null) try { conn.close();  } catch (SQLException ignore) {}
}
%>
