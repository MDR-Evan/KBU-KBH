<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.DecimalFormat" %>
<%@ include file="globalVar.jsp" %>
<%@ include file="dbconn.jsp"   %>

<%
    // DecimalFormat для форматирования цен и количеств, если нужно
    DecimalFormat df = new DecimalFormat("#,###");

    request.setCharacterEncoding("UTF-8");
    String sCategoryCd  = request.getParameter("sCategoryCd");
    String sProductName = request.getParameter("sProductName");
    if (sCategoryCd  == null) sCategoryCd  = "";
    if (sProductName == null) sProductName = "";

    PreparedStatement pstmt = null;
    ResultSet rs = null;
    List<Map<String,String>> productList = new ArrayList<>();

    try {
        StringBuilder sql = new StringBuilder()
            .append("SELECT PRODUCT_UUID, ")
            .append("       DECODE(CATEGORY_CD,'01','김밥류','02','분식류','03','식사류','04','돈까스류', CATEGORY_CD) CATEGORY_NM, ") // 카테고리 코드 없을 시 코드값 그대로 표시
            .append("       PRODUCT_NAME, PRODUCT_PRICE, PRODUCT_QUANTITY, PRODUCT_DESC ")
            .append("  FROM KB_Product WHERE SHOP_UUID = ? ");
        if (!sCategoryCd.isEmpty())  sql.append(" AND CATEGORY_CD = ? ");
        if (!sProductName.isEmpty()) sql.append(" AND PRODUCT_NAME LIKE '%' || ? || '%' ");
        sql.append(" ORDER BY CATEGORY_CD, PRODUCT_SORT, PRODUCT_NAME"); // 정렬 기준 추가

        pstmt = conn.prepareStatement(sql.toString());
        int idx = 1;
        pstmt.setString(idx++, sShopUuid); // sShopUuid는 globalVar.jsp 또는 세션 등에서 설정되어 있어야 함
        if (!sCategoryCd.isEmpty())  pstmt.setString(idx++, sCategoryCd);
        if (!sProductName.isEmpty()) pstmt.setString(idx++, sProductName);

        rs = pstmt.executeQuery();
        while (rs.next()) {
            Map<String,String> row = new HashMap<>();
            row.put("PRODUCT_UUID",     rs.getString("PRODUCT_UUID"));
            row.put("CATEGORY_NM",      rs.getString("CATEGORY_NM"));
            row.put("PRODUCT_NAME",     rs.getString("PRODUCT_NAME"));
            row.put("PRODUCT_PRICE",    df.format(rs.getLong("PRODUCT_PRICE"))); // 가격 포맷팅
            row.put("PRODUCT_QUANTITY", df.format(rs.getLong("PRODUCT_QUANTITY"))); // 수량 포맷팅
            row.put("PRODUCT_DESC",     rs.getString("PRODUCT_DESC") == null ? "" : rs.getString("PRODUCT_DESC")); // Null 처리
            productList.add(row);
        }
    } catch (Exception e) {
        e.printStackTrace(); // 실제 운영 환경에서는 로깅 프레임워크 사용 권장
        // out.println("<p style='color:red;'>상품 목록을 불러오는 중 오류가 발생했습니다: " + e.getMessage() + "</p>");
    } finally {
        if (rs    != null) try { rs.close();    } catch(SQLException ignore){}
        if (pstmt != null) try { pstmt.close(); } catch(SQLException ignore){}
        if (conn  != null) try { conn.close();  } catch(SQLException ignore){}
    }
%>
<%-- HTML 구조 시작 가정 (header.jsp에서 <html> <head> 등을 포함할 수 있음) --%>
<head>
    <meta charset="UTF-8">
    <title>상품 관리</title>
    <%-- 외부 CSS를 사용한다면 여기에 링크 --%>
    <%-- <link href="style.css" rel="stylesheet" type="text/css"> --%>
<style>
body {
    font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
    background-color: #f7f0e5;
    margin: 0;
    padding: 0;
    color: #333;
}

.page-title {
    text-align: center;
    margin: 30px 0 25px 0;
    font-size: 2rem;
    font-weight: bold;
    color: #e74c3c; /* 키오스크 메인 빨간색 */
}

.search-form-container { /* 검색폼 감싸는 div에 적용할 클래스 */
    width: 90%;
    max-width: 1000px;
    margin: 0 auto 25px auto;
    padding: 20px;
    background-color: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    display: flex;
    gap: 10px; /* 요소 간 간격 */
    align-items: center;
    flex-wrap: wrap;
}

.search-form-container label {
    font-weight: bold;
    font-size: 0.9rem;
    margin-right: 5px;
}

.search-form-container select,
.search-form-container input[type="search"] {
    padding: 8px 10px;
    border: 1px solid #ccc;
    border-radius: 6px;
    font-size: 0.9rem;
    flex-grow: 1; /* 입력 필드가 남은 공간을 채우도록 */
    min-width: 150px;
}
.search-form-container input[type="search"] {
    flex-grow: 2; /* 메뉴명 검색 필드는 더 넓게 */
}

.search-form-container input[type="submit"],
.search-form-container input[type="button"] {
    color: white;
    padding: 9px 18px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 0.9rem;
    font-weight: bold;
    transition: background-color 0.3s ease;
}

.search-form-container input[type="submit"].search-btn {
    background-color: #3498db; /* 검색: 파란색 */
}
.search-form-container input[type="submit"].search-btn:hover {
    background-color: #2980b9;
}
.search-form-container input[type="button"].add-btn {
    background-color: #27ae60; /* 상품추가: 녹색 */
}
.search-form-container input[type="button"].add-btn:hover {
    background-color: #229954;
}

/* 상품 목록 테이블 스타일 */
table.kiosk-style-table {
    width: 90%;
    max-width: 1200px;
    margin: 0 auto 30px auto;
    border-collapse: collapse;
    background-color: #ffffff;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    border-radius: 8px;
    overflow: hidden;
    font-size: 0.9rem;
}

table.kiosk-style-table th,
table.kiosk-style-table td {
    padding: 10px 12px;
    text-align: center;
    border-bottom: 1px solid #eeeeee;
    border-left: 1px solid #eeeeee;
}
table.kiosk-style-table th:first-child,
table.kiosk-style-table td:first-child {
    border-left: none;
}

table.kiosk-style-table th {
    background-color: #e74c3c; /* 헤더 빨강 */
    color: white;
    font-weight: bold;
}

table.kiosk-style-table td {
    color: #333333;
}
table.kiosk-style-table td.product-desc {
    text-align: left; /* 상품 설명은 왼쪽 정렬 */
    max-width: 300px; /* 설명이 길 경우 대비 */
    white-space: pre-wrap; /* 줄바꿈 유지 */
    word-break: break-all;
}
table.kiosk-style-table td.price-cell,
table.kiosk-style-table td.quantity-cell {
    text-align: right; /* 가격, 수량 오른쪽 정렬 */
}


table.kiosk-style-table tbody tr:hover td {
    background-color: #fdf5e6; /* 마우스 오버 시 행 배경색 (옅은 주황/베이지) */
}

table.kiosk-style-table .action-button {
    color: white;
    padding: 6px 10px;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-size: 0.85rem;
    transition: background-color 0.3s ease;
    margin: 3px;
    min-width: 50px;
}
.action-button.edit-btn {
    background-color: #e67e22; /* 수정: 주황색 */
}
.action-button.edit-btn:hover {
    background-color: #d35400;
}
.action-button.delete-btn {
    background-color: #c0392b; /* 삭제: 진한 빨강 */
}
.action-button.delete-btn:hover {
    background-color: #a93226;
}

.no-data-message td {
    text-align:center; 
    padding: 30px; 
    font-size: 1.1rem; 
    color: #777;
}
</style>
</head>
<body>
    <jsp:include page="header.jsp"  />
    <jsp:include page="menuMag.jsp" />

    <h2 class="page-title">상품 관리 목록</h2>
    <div class="search-form-container">
        <form id="frmProductSearch" action="productMag.jsp" method="post" style="display:flex; flex-grow:1; gap:10px; align-items:center;">
            <label for="sCategoryCd">카테고리:</label>
            <select name="sCategoryCd" id="sCategoryCd">
                <option value="">전체</option>
                <option value="01" <%= "01".equals(sCategoryCd) ? "selected" : "" %>>김밥류</option>
                <option value="02" <%= "02".equals(sCategoryCd) ? "selected" : "" %>>분식류</option>
                <option value="03" <%= "03".equals(sCategoryCd) ? "selected" : "" %>>식사류</option>
                <option value="04" <%= "04".equals(sCategoryCd) ? "selected" : "" %>>돈까스류</option>
            </select>
            <label for="sProductName">메뉴명:</label>
            <input type="search" name="sProductName" id="sProductName" value="<%= sProductName %>" placeholder="메뉴명 검색" />
            <input type="submit" value="검색" class="search-btn" />
        </form>
        <input type="button" value="상품 추가" onclick="location.href='productAddMag.jsp';" class="add-btn" />
    </div>

    <table class="kiosk-style-table">
        <thead>
            <tr>
                <th style="width:10%;">카테고리</th>
                <th style="width:20%;">메뉴명</th>
                <th style="width:10%;">가격</th>
                <th style="width:8%;">수량</th>
                <th style="width:32%;">설명</th>
                <th style="width:20%;">관리</th>
            </tr>
        </thead>
        <tbody>
        <% if (productList.isEmpty()) { %>
            <tr class="no-data-message">
                <td colspan="6">등록된 상품이 없습니다.</td>
            </tr>
        <% } else { %>
            <% for (Map<String,String> p : productList) { %>
            <tr>
                <td><%= p.get("CATEGORY_NM")      %></td>
                <td><%= p.get("PRODUCT_NAME")     %></td>
                <td class="price-cell"><%= p.get("PRODUCT_PRICE")    %></td>
                <td class="quantity-cell"><%= p.get("PRODUCT_QUANTITY") %></td>
                <td class="product-desc"><%= p.get("PRODUCT_DESC")     %></td>
                <td>
                    <button type="button" class="action-button edit-btn" onclick="location.href='productEditMag.jsp?productUuid=<%=p.get("PRODUCT_UUID")%>';">수정</button>
                    <button type="button" class="action-button delete-btn" onclick="if(confirm('정말로 삭제하시겠습니까? \n삭제된 상품은 복구할 수 없습니다.')) { location.href='productDelMag.jsp?productUuid=<%=p.get("PRODUCT_UUID")%>'; } else { return false; }">삭제</button>
                </td>
            </tr>
            <% } %>
        <% } %>
        </tbody>
    </table>
</body>
</html>