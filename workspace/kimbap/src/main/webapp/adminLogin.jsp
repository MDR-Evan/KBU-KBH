<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>관리자 로그인</title>
    <style>
        * {
            box-sizing: border-box;
            font-family: 'Nanum Gothic', sans-serif;
        }

        body {
            margin: 0;
            padding: 0;
            background: linear-gradient(120deg, #fceabb, #f8b500);
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-box {
            background-color: #ffffff;
            padding: 40px 30px;
            border-radius: 16px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
            width: 320px;
        }

        .login-box h2 {
            text-align: center;
            margin-bottom: 24px;
            color: #333;
        }

        .login-box label {
            display: block;
            margin-bottom: 6px;
            font-weight: bold;
            color: #555;
        }

        .login-box input[type="text"],
        .login-box input[type="password"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 8px;
            margin-bottom: 16px;
            transition: border 0.2s ease;
        }

        .login-box input:focus {
            border-color: #f8b500;
            outline: none;
        }

        .login-box button {
            width: 100%;
            padding: 12px;
            background-color: #f8b500;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.3s ease;
        }

        .login-box button:hover {
            background-color: #e89e00;
        }
    </style>
</head>
<body>
    <div class="login-box">
        <h2>관리자 로그인</h2>
        <form method="post" action="adminLoginProcess.jsp">
            <div>
                <label for="adminId">아이디</label>
                <input type="text" id="adminId" name="adminId" required>
            </div>
            <div>
                <label for="adminPw">비밀번호</label>
                <input type="password" id="adminPw" name="adminPw" required>
            </div>
            <div>
                <button type="submit">로그인</button>
            </div>
        </form>
    </div>
</body>
</html>
