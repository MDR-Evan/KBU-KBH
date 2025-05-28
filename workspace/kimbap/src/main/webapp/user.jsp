<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="dbconn.jsp" %>

<style>
body {
    font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
    background-color: #f7f0e5;
    margin: 0;
    padding: 0;
}
h2.table-title {
    color: #27ae60;
    text-align: center;
    margin-top: 30px;
    margin-bottom: 20px;
}
table.kiosk-style-table {
    width: 80%;
    max-width: 900px;
    margin: 20px auto;
    border-collapse: collapse;
    background-color: #ffffff;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    border-radius: 8px;
    overflow: hidden;
}
table.kiosk-style-table th,
table.kiosk-style-table td {
    padding: 12px 15px;
    text-align: center;
    border-bottom: 1px solid #eeeeee;
}
table.kiosk-style-table th {
    background-color: #e74c3c; /* 헤더 빨간색 */
    color: white;
    font-weight: bold;
    border-bottom: none;
}
table.kiosk-style-table tr:last-child td {
    border-bottom: none;
}
table.kiosk-style-table td {
    color: #333333;
}

table.kiosk-style-table td form {
    margin: 0;
    display: inline-block; /* 버튼들을 같은 줄에 놓기 위해 */
}

table.kiosk-style-table td button.edit-button {
    background-color: #27ae60; /* 수정 버튼 녹색 */
    color: white;
    padding: 8px 12px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 14px;
    transition: background-color 0.3s ease;
    margin-right: 5px; /* 버튼 사이 간격 */
}
table.kiosk-style-table td button.edit-button:hover {
    background-color: #2ecc71;
}

table.kiosk-style-table td button.delete-button {
    background-color: #c0392b; /* 삭제 버튼 진한 빨간색 */
    color: white;
    padding: 8px 12px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 14px;
    transition: background-color 0.3s ease;
}
table.kiosk-style-table td button.delete-button:hover {
    background-color: #e74c3c;
}

.error-message td,
.no-data-message td {
    color: #c0392b;
    font-weight: bold;
    text-align: center;
    padding: 20px;
}
</style>

<jsp:include page="header.jsp" />
<section>
	<jsp:include page="menuMag.jsp" flush="true" />
</section>
<h2 class="table-title">회원 정보 목록</h2>
<table class="kiosk-style-table">
  <thead>
    <tr>
      <th>이름</th>
      <th>휴대폰번호</th>
      <th>포인트</th>
      <th>수정</th>
      <th>삭제</th>
    </tr>
  </thead>
  <tbody>
<%
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    int cnt = 0;
    String errorMessage = null;

    try {
        if (conn == null) {
            errorMessage = "데이터베이스 연결에 실패했습니다 (conn 객체가 null입니다). dbconn.jsp를 확인하세요.";
        } else {
            String sql = "SELECT RAWTOHEX(UUID) AS UUID, NAME, PHONE_NUM, POINT FROM USERS ORDER BY NAME";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                cnt++;
                String currentUuid = rs.getString("UUID");
                out.println("<script>console.log('JSP에서 읽은 값: " + rs.getString("NAME") + ", " + rs.getString("PHONE_NUM") + "');</script>");
%>
  <tr>
    <td><%= rs.getString("NAME") %></td>
    <td><%= rs.getString("PHONE_NUM") %></td>
    <td><%= rs.getInt("POINT") %></td>
    <td>
      <form method="get" action="userEdit.jsp">
        <input type="hidden" name="uuid" value="<%= currentUuid %>">
        <button type="submit" class="edit-button">수정</button>
      </form>
    </td>
    <td>
      <form method="post" action="userDeleteProcess.jsp" onsubmit="return confirm('정말로 이 회원을 삭제하시겠습니까?');">
        <input type="hidden" name="uuid" value="<%= currentUuid %>">
        <button type="submit" class="delete-button">삭제</button>
      </form>
    </td>
  </tr>
<%
            }
            out.println("<script>console.log('회원 수: " + cnt + "');</script>");
        }
    } catch (SQLException e) {
        errorMessage = "SQL 오류 발생: " + e.getMessage();
        e.printStackTrace();
        out.println("<script>console.error('SQL 오류: " + e.getMessage().replace("'", "\\'") + "');</script>");
    } catch (Exception e) {
        errorMessage = "일반 오류 발생: " + e.getMessage();
        e.printStackTrace();
        out.println("<script>console.error('일반 오류: " + e.getMessage().replace("'", "\\'") + "');</script>");
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (conn != null && !conn.isClosed()) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }

    if (errorMessage != null) {
%>
  <tr class="error-message">
    <td colspan="5"><%= errorMessage %></td>
  </tr>
<%
    }

    if (cnt == 0 && errorMessage == null) {
%>
  <tr class="no-data-message">
    <td colspan="5">회원 정보가 없습니다.</td>
  </tr>
<%
    }
%>
  </tbody>
</table>