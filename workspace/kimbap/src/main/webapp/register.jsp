<%@ page import="java.sql.*" language="java" contentType="text/html; charset=UTF-8" %>
<%@ include file="globalVar.jsp" %>
<%@ include file="dbconn.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String inputName  = request.getParameter("name");
    String inputPhone = request.getParameter("phone");
    String errorMsg   = null;

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
                    // --------------------------------------------
                    // 회원가입 성공 → JS 팝업 후 point.jsp로 이동
                    // --------------------------------------------
                    out.println("<script>");
                    out.println("  alert('✔ 회원가입이 성공적으로 완료되었습니다.');");
                    out.println("  location.href='point.jsp';");
                    out.println("</script>");
                    return; // 이후 HTML 출력 중단
                } else {
                    errorMsg = "✖ 회원가입에 실패했습니다. 다시 시도해 주세요.";
                }
            } catch (Exception e) {
                e.printStackTrace();
                errorMsg = "✖ 서버 오류가 발생했습니다.";
            } finally {
                if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
                if (conn  != null) try { conn.close();  } catch (SQLException ignored) {}
            }
        } else {
            errorMsg = "이름과 전화번호를 모두 입력해 주세요.";
        }
    }
%>

<jsp:include page="header.jsp" flush="true" />

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원가입</title>
    <style>
        .register-page {
            min-height: 100vh;
            display: flex; 
            flex-direction: column;
            align-items: center; 
            justify-content: center;
            background: #fffdf5;
            margin: 0; 
            padding: 0;
        }
        .register-page * {
            box-sizing: border-box;
            font-family: 'Nanum Gothic', sans-serif;
        }
        .register-page .login-box {
            background: #fff;
            padding: 36px 28px;
            border-radius: 18px;
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.09);
            width: 340px;
            margin-bottom: 24px;
            border: 1.5px solid #f4ede5;
        }
        .register-page .login-box h1 {
            text-align: center;
            margin-bottom: 26px;
            font-size: 26px;
            font-weight: bold;
            letter-spacing: 2px;
        }
        .register-page .login-box label {
            display: block;
            margin-bottom: 7px;
            color: #333;
            font-weight: bold;
            font-size: 15px;
        }
        .register-page .login-box input[type="text"] {
            width: 100%;
            padding: 11px;
            border: 1.5px solid #eee6d9;
            border-radius: 10px;
            margin-bottom: 18px;
            font-size: 15px;
            background: #fffdf5;
            transition: border 0.2s;
        }
        .register-page .login-box input[type="text"]:focus {
            border-color: #e94826;
            outline: none;
            background: #fff;
        }
        .register-page .login-box button[type="submit"] {
            width: 100%;
            padding: 13px 0;
            background: #e94826;
            color: #fff;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.2s;
            margin-bottom: 7px;
        }
        .register-page .login-box button[type="submit"]:hover {
            background: #c33c1d;
        }
        .register-page .message {
            margin: 12px 0;
            color: #e94826; /* 에러 메시지는 붉은색으로 표시 */
            text-align: center;
            font-size: 16px;
        }
    </style>
</head>
<body>
    <div class="register-page">
        <div class="login-box">
            <h1>
                <span style="color: #e94826;">회</span>
                <span style="color: #222;">원</span>
                <span style="color: #22b573;">가</span>
                <span style="color: #e94826;">입</span>
            </h1>

            <!-- 에러 메시지 출력 -->
            <% if (errorMsg != null) { %>
                <div class="message"><%= errorMsg %></div>
            <% } %>

            <!-- 회원가입 폼: action="" → 현재 JSP로 POST -->
            <form method="post" action="">
                <label for="name">이름</label>
                <input
                    type="text"
                    id="name"
                    name="name"
                    value="<%= request.getParameter("name") != null ? request.getParameter("name") : "" %>"
                    required
                >

                <label for="phone">휴대폰번호</label>
                <input
                    type="text"
                    id="phone"
                    name="phone"
                    value="<%= request.getParameter("phone") != null ? request.getParameter("phone") : "" %>"
                    required
                >

                <button type="submit">회원가입</button>
            </form>
        </div>
    </div>
</body>
</html>
