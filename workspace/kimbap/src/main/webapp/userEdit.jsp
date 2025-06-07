<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ include file="dbconn.jsp" %>
<%
  String uuid_param = request.getParameter("uuid");
  String name_val = "";
  String phone_val = "";
  int point_val = 0;

  if (uuid_param != null && !uuid_param.trim().isEmpty()) {
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    try {
      if (conn != null && !conn.isClosed()) {
        String sql = "SELECT RAWTOHEX(UUID) AS UUID_VAL, NAME, PHONE_NUM, POINT FROM USERS WHERE RAWTOHEX(UUID) = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, uuid_param);
        rs = pstmt.executeQuery();
        if (rs.next()) {
          name_val = rs.getString("NAME");
          phone_val = rs.getString("PHONE_NUM");
          point_val = rs.getInt("POINT");
        }
      }
    } catch (Exception e) {
      e.printStackTrace();
    } finally {
      if (rs != null) try { rs.close(); } catch (Exception e) {}
      if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
      if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
  }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원 정보 수정</title>
<style>
    body {
        font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
        background-color: #f7f0e5;
        margin: 0;
        padding: 0;
        color: #333;
    }

    .main-content-wrapper {
        display: flex;
        flex-direction: column;
        align-items: center;
        padding: 20px;
        box-sizing: border-box;
    }

    .form-container {
        background-color: #fff;
        padding: 35px;
        border-radius: 10px;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        width: 100%;
        max-width: 420px;
        margin-top: 30px;
    }

    .form-container h2 {
        color: #27ae60;
        text-align: center;
        margin-top: 0;
        margin-bottom: 30px;
        font-size: 22px;
    }

    label {
        display: block;
        margin-bottom: 8px;
        font-weight: bold;
        font-size: 15px;
        color: #444;
    }

    input[type="text"],
    input[type="number"] {
        width: 100%;
        padding: 14px;
        margin-bottom: 25px;
        border: 1px solid #ddd;
        border-radius: 6px;
        box-sizing: border-box;
        font-size: 16px;
        color: #333;
    }
    
    button[type="submit"] {
        background-color: #e74c3c;
        color: white;
        padding: 14px 20px;
        border: none;
        border-radius: 8px;
        cursor: pointer;
        font-size: 17px;
        font-weight: bold;
        transition: background-color 0.2s ease, transform 0.1s ease;
        width: 100%;
        text-transform: uppercase;
    }

    button[type="submit"]:hover {
        background-color: #c0392b;
        transform: translateY(-1px);
    }
</style>
</head>
<body>
    <jsp:include page="header.jsp" flush="true" />
    <jsp:include page="menuMag.jsp" />

    <div class="main-content-wrapper">
        <div class="form-container">
            <h2>회원 정보 수정</h2>
            <form method="post" action="userEditProcess.jsp">
				<input type="hidden" name="uuid" value="<%= uuid_param %>">
                
                <label for="name">이름:</label>
                <input type="text" id="name" name="name" value="<%= name_val %>" required>

                <label for="phone">휴대폰번호:</label>
                <input type="text" id="phone" name="phone" value="<%= phone_val %>" required>

                <label for="point">포인트:</label>
                <input type="number" id="point" name="point" value="<%= point_val %>" required>

                <button type="submit">수정 저장</button>
            </form>
        </div>
    </div>
</body>
</html>