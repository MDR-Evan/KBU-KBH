<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%
    // ✅ 관리자 로그인 상태라면 자동 로그아웃 처리
    if (session.getAttribute("isAdmin") != null) {
        session.removeAttribute("isAdmin");
        session.removeAttribute("adminId");
        System.out.println("👉 index.jsp 접근 시 관리자 자동 로그아웃됨");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>주문</title>
    <style>
        /* 필요한 스타일 여기에 */
    </style>
</head>
<body>
    <jsp:include page="header.jsp" flush="true" />
    <jsp:include page="menu.jsp" flush="true" />
    <section>
        <jsp:include page="main.jsp" flush="true" />
    </section>
    <jsp:include page="footer.jsp" flush="true" />
</body>
</html>
