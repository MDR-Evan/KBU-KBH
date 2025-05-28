<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ include file="dbconn.jsp" %>
<%
  request.setCharacterEncoding("UTF-8");
  String uuid = request.getParameter("uuid");
  String name = request.getParameter("name");
  String phone = request.getParameter("phone");
  String point = request.getParameter("point");
  String sql = "UPDATE USERS SET NAME=?, PHONE_NUM=?, POINT=? WHERE RAWTOHEX(UUID) = ?";
  PreparedStatement pstmt = conn.prepareStatement(sql);
  pstmt.setString(1, name);
  pstmt.setString(2, phone);
  pstmt.setInt(3, Integer.parseInt(point));
  pstmt.setString(4, uuid);
  int result = pstmt.executeUpdate();
  pstmt.close();
  conn.close();
  // 수정 후 목록으로 리다이렉트
  response.sendRedirect("user.jsp");
%>
