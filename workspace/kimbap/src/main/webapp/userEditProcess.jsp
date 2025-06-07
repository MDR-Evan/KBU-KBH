<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="dbconn.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    String uuid  = request.getParameter("uuid");
    String name  = request.getParameter("name");
    String phone = request.getParameter("phone");
    String point = request.getParameter("point");

    String sql = "UPDATE USERS SET NAME = ?, PHONE_NUM = ?, POINT = ? WHERE RAWTOHEX(UUID) = ?";
    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
        pstmt.setString(1, name);
        pstmt.setString(2, phone);
        pstmt.setInt(3, Integer.parseInt(point));
        pstmt.setString(4, uuid);
        pstmt.executeUpdate();
    } catch (Exception e) {
        e.printStackTrace();
        // 필요하면 에러 페이지로 리다이렉트하거나, 사용자에게 알림 처리
    } finally {
        try { conn.close(); } catch (Exception ignore) {}
    }

    // 수정 완료 후 목록 페이지로 이동
    response.sendRedirect("user.jsp");
%>
