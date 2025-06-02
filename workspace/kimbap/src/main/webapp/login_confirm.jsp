<%@ include file="globalVar.jsp" %>
<%@ include file="dbconn.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
  <meta charset="UTF-8">
  <title>포인트 처리</title>
  <script>
    function tryLoginAgain() {
      if (confirm("회원정보가 존재하지 않습니다.\n회원가입 하시겠습니까?")) {
        // 확인 클릭 시: 포인트 적립 페이지로
        document.getElementById("register").submit();
      } else {
        // 취소 클릭 시: 메인 페이지로
        alert("로그인을 취소하셨습니다.");
        document.getElementById("return").submit();
      }
    }
  </script>
</head>
<body>
<%
    String phone = request.getParameter("PHONE_NUM");
    boolean userExists = false;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sql = "SELECT PHONE_NUM FROM USERS WHERE PHONE_NUM = ?";
    try {
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, phone);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            userExists = true;
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null)    rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null)  conn.close();
        } catch (Exception e2) {
            e2.printStackTrace();
        }
    }
%>

  <!-- 포인트 적립 폼 -->
  <form id="frmlogin" method="post" action="earnPoint.jsp">
    <input type="hidden" name="PHONE_NUM" value="<%= phone %>">
  </form>

  <!-- 적립 포기 복귀 폼 -->
  <form id="return" method="post" action="point.jsp"></form>
  
  <!-- 회원정보 불일치 복귀 폼 -->
  <form id="register" method="post" action="register.jsp"></form>

<% if (userExists) { %>
  <script>
    // 이미 등록된 번호: 자동으로 포인트 적립 페이지로 이동
    document.getElementById("frmlogin").submit();
  </script>
<% } else { %>
  <script>
    // 등록된 번호가 없으면 확인/취소 모달 호출
    tryLoginAgain();
  </script>
<% } %>
</body>
</html>
