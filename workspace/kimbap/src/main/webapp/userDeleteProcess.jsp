<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.PreparedStatement, java.sql.SQLException" %>
<%@ include file="dbconn.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    String uuid = request.getParameter("uuid");

    PreparedStatement pstmt = null;
    int result = 0;
    String deleteErrorMessage = null;

    if (uuid != null && !uuid.isEmpty()) {
        try {
            if (conn == null) {
                deleteErrorMessage = "데이터베이스 연결에 실패했습니다.";
            } else {
                String sql = "DELETE FROM USERS WHERE RAWTOHEX(UUID) = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, uuid);
                result = pstmt.executeUpdate();

                if (result > 0) {
                    // 삭제 성공
                } else {
                    // 삭제된 행이 없음 (이미 삭제되었거나 uuid가 잘못된 경우)
                    deleteErrorMessage = "삭제할 회원 정보를 찾지 못했습니다.";
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            deleteErrorMessage = "데이터베이스 오류로 삭제에 실패했습니다: " + e.getMessage();
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (conn != null && !conn.isClosed()) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    } else {
        deleteErrorMessage = "삭제할 회원의 UUID가 제공되지 않았습니다.";
    }
    
    if (deleteErrorMessage != null) {
        // 오류 메시지를 세션에 저장하거나 쿼리 파라미터로 전달하여 user.jsp에 표시할 수 있습니다.
        // 간단하게 하기 위해 여기서는 콘솔에만 출력하고 바로 리다이렉트합니다.
        System.err.println("Delete Error: " + deleteErrorMessage); 
        // response.sendRedirect("user.jsp?error=" + java.net.URLEncoder.encode(deleteErrorMessage, "UTF-8"));
        // 위와 같이 에러를 전달할 수 있으나, 지금은 단순 리다이렉트합니다.
    }
    
    response.sendRedirect("user.jsp");
%>