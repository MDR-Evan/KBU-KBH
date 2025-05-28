<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="globalVar.jsp"%>
<%@ include file="dbconn.jsp"%>

<%
PreparedStatement pstmt = null;
String uuid = request.getParameter("orderUuid");
String status = request.getParameter("orderStatus");

// 테이블명 및 shop_uuid 조건 반영
String sql = "UPDATE KB_Order_Master SET ORDER_STATUS = ? WHERE SHOP_UUID = ? AND ORDER_UUID = ?";

try {
	pstmt = conn.prepareStatement(sql);
	pstmt.setString(1, status);
	pstmt.setString(2, sShopUuid);     // globalVar.jsp에 선언된 매장 UUID
	pstmt.setString(3, uuid);
	pstmt.executeUpdate();
} catch (Exception e) {
	e.printStackTrace();
	out.println("주문 상태 변경 오류: " + e.getMessage());
} finally {
	if (pstmt != null) try { pstmt.close(); } catch (Exception ignore) {}
	if (conn != null) try { conn.close(); } catch (Exception ignore) {}
}

// 주문관리 페이지로 이동
response.sendRedirect("orderMag.jsp");
%>
