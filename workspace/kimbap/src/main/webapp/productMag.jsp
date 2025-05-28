<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*"%>
<%@ include file="globalVar.jsp" %>
<%@ include file="dbconn.jsp"   %>
<jsp:include page="header.jsp"  />
<jsp:include page="menuMag.jsp" />

<%
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
            .append("       DECODE(CATEGORY_CD,'01','김밥류','02','분식류','03','식사류','04','돈까스류') CATEGORY_NM, ")
            .append("       PRODUCT_NAME, PRODUCT_PRICE, PRODUCT_QUANTITY, PRODUCT_DESC ")
            .append("  FROM KB_Product WHERE SHOP_UUID = ? ");
        if (!sCategoryCd.isEmpty())  sql.append(" AND CATEGORY_CD = ? ");
        if (!sProductName.isEmpty()) sql.append(" AND PRODUCT_NAME LIKE '%' || ? || '%' ");
        sql.append(" ORDER BY CATEGORY_CD, PRODUCT_SORT");

        pstmt = conn.prepareStatement(sql.toString());
        int idx = 1;
        pstmt.setString(idx++, sShopUuid);
        if (!sCategoryCd.isEmpty())  pstmt.setString(idx++, sCategoryCd);
        if (!sProductName.isEmpty()) pstmt.setString(idx++, sProductName);

        rs = pstmt.executeQuery();
        while (rs.next()) {
            Map<String,String> row = new HashMap<>();
            row.put("PRODUCT_UUID",     rs.getString("PRODUCT_UUID"));
            row.put("CATEGORY_NM",      rs.getString("CATEGORY_NM"));
            row.put("PRODUCT_NAME",     rs.getString("PRODUCT_NAME"));
            row.put("PRODUCT_PRICE",    rs.getString("PRODUCT_PRICE"));
            row.put("PRODUCT_QUANTITY", rs.getString("PRODUCT_QUANTITY"));
            row.put("PRODUCT_DESC",     rs.getString("PRODUCT_DESC"));
            productList.add(row);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs    != null) try { rs.close();    } catch(SQLException ignore){}
        if (pstmt != null) try { pstmt.close(); } catch(SQLException ignore){}
        if (conn  != null) try { conn.close();  } catch(SQLException ignore){}
    }
%>

<h2>김밥천국 메뉴 목록</h2>
<form id="frmProductSearch" action="productMag.jsp" method="post">
    카테고리:
    <select name="sCategoryCd">
        <option value="">전체</option>
        <option value="01" <%= "01".equals(sCategoryCd) ? "selected" : "" %>>김밥류</option>
        <option value="02" <%= "02".equals(sCategoryCd) ? "selected" : "" %>>분식류</option>
        <option value="03" <%= "03".equals(sCategoryCd) ? "selected" : "" %>>식사류</option>
        <option value="04" <%= "04".equals(sCategoryCd) ? "selected" : "" %>>돈까스류</option>
    </select>
    메뉴명:
    <input type="search" name="sProductName" value="<%= sProductName %>" />
    <input type="submit" value="검색" />
    <input type="button" value="상품 추가" onclick="location.href='productAddMag.jsp';" style="background:#00f;color:#fff;" />
</form>

<table class="product-table" style="width: 100%; border-collapse: collapse;" border="1">
    <tr>
        <th>카테고리</th>
        <th>메뉴명</th>
        <th>가격</th>
        <th>수량</th>
        <th>설명</th>
        <th>관리</th>
    </tr>
    <% for (Map<String,String> p : productList) { %>
    <tr>
        <td><%= p.get("CATEGORY_NM")      %></td>
        <td><%= p.get("PRODUCT_NAME")     %></td>
        <td><%= p.get("PRODUCT_PRICE")    %></td>
        <td><%= p.get("PRODUCT_QUANTITY") %></td>
        <td><%= p.get("PRODUCT_DESC")     %></td>
        <td style="text-align:center; vertical-align:middle;">
            <button type="button" onclick="location.href='productEditMag.jsp?productUuid=<%=p.get("PRODUCT_UUID")%>';" 
            style="background:#f00;color:#fff; margin-right:5px;">수정</button>
            <button type="button" onclick="location.href='productDelMag.jsp?productUuid=<%=p.get("PRODUCT_UUID")%>';" 
            style="background:#999;color:#fff;">삭제</button>
        </td>
    </tr>
    <% } %>
</table>

<jsp:include page="footer.jsp" />
