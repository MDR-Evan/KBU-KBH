<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ include file="globalVar.jsp" %>
<%@ include file="dbconn.jsp" %>
<jsp:include page="header.jsp" flush="true" />

<%
	request.setCharacterEncoding("UTF-8");

    String inputName  = request.getParameter("name");
    String inputPhone = request.getParameter("phone");
    String message    = "";

    // POST 요청일 때만 INSERT 실행
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if (inputName != null && inputPhone != null) {
            PreparedStatement pstmt = null;
            try {
                String sql = 
                  "INSERT INTO USERS (UUID, NAME, PHONE_NUM, POINT) " +
                  "VALUES (SYS_GUID(), ?, ?, 0)";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, inputName);
                pstmt.setString(2, inputPhone);

                int cnt = pstmt.executeUpdate();
                if (cnt == 1) {
                    message = "✔ 회원가입이 성공적으로 완료되었습니다.";
                } else {
                    message = "✖ 회원가입에 실패했습니다. 다시 시도해 주세요.";
                }
            } catch (Exception e) {
                e.printStackTrace();
                message = "✖ 서버 오류가 발생했습니다.";
            } finally {
                if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
                if (conn  != null) try { conn.close();  } catch (SQLException ignored) {}
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원가입</title>
    <style>
      label { display:block; margin-top:8px; }
      .message { margin:12px 0; color: #006400; }
      .error   { color: #8B0000; }
    </style>
</head>
<body>
  <div>
    <h2>회원가입</h2>

    <% if (!message.isEmpty()) { %>
      <div class="message"><%= message %></div>
    <% } %>

    <form method="post" action="point.jsp">
      <label for="name">이름:</label>
      <input
        type="text"
        id="name"
        name="name"
        value="<%= inputName != null ? inputName : "" %>"
        required
      >

      <label for="phone">휴대폰번호:</label>
      <input
        type="text"
        id="phone"
        name="phone"
        value="<%= inputPhone != null ? inputPhone : "" %>"
        required
      >

      <button type="submit">회원가입</button>
    </form>
  </div>
</body>
</html>