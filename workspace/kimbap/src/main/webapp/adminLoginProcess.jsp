<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="dbconn.jsp" %>
<%
String adminId = request.getParameter("adminId");
String adminPw = request.getParameter("adminPw");

System.out.println("입력된 ID: " + adminId);
System.out.println("입력된 PW: " + adminPw);
System.out.println("conn is null? " + (conn == null));

String sql = "SELECT * FROM ADMIN WHERE ADMIN_ID=? AND ADMIN_PW=?";
System.out.println("SQL: " + sql);

PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, adminId);
    pstmt.setString(2, adminPw);
    rs = pstmt.executeQuery();

    if (rs.next()) {
        System.out.println("✅ 로그인 성공");
        session.setAttribute("isAdmin", true); // 로그인 상태 저장
        session.setAttribute("adminId", adminId); // 관리자 ID도 저장
        response.sendRedirect("orderMag.jsp");
    } else {
        System.out.println("❌ 로그인 실패");
%>
        <script>
            alert("로그인 실패! 아이디 또는 비밀번호를 확인하세요.");
            history.back();
        </script>
<%
    }
} catch (Exception e) {
    e.printStackTrace();
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
    try { if (conn != null) conn.close(); } catch (Exception e) {}
}
%>
