<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.DecimalFormat"%>
<%@ include file="globalVar.jsp"%>
<%@ include file="dbconn.jsp"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>메뉴 목록</title>
<link rel="stylesheet" href="style.css">
<script>
	function addCart(productUuid) {
		var frm = document.getElementById("frmProduct");
		frm.productUuid.value = productUuid;
		frm.submit();
	}
</script>
</head>

<%
DecimalFormat df = new DecimalFormat("###,###");
String sCategoryCd = request.getParameter("categoryCd");
%>

<body>
	<jsp:include page="header.jsp" flush="true" />
	<section>
		<jsp:include page="menu.jsp" flush="true" />
	</section>

	<section>
		<div>
			<!-- 상품 클릭 시 장바구니에 담기 -->
			<form id="frmProduct" name="frmProduct" action="cartSave.jsp"
				method="post">
				<input type="hidden" name="categoryCd" value="<%=sCategoryCd%>">
				<input type="hidden" name="productUuid">
			</form>

			<ul class="productList" style="list-style: none;">
				<%
				ResultSet rs = null;
				PreparedStatement pstmt = null;
				try {
					String sql = "SELECT PRODUCT_UUID, PRODUCT_NAME, PRODUCT_PRICE, PRODUCT_IMG FROM KB_PRODUCT "
					+ "WHERE CATEGORY_CD = ? AND SHOP_UUID = ? ORDER BY PRODUCT_SORT ASC";
					pstmt = conn.prepareStatement(sql);
					pstmt.setString(1, sCategoryCd);
					pstmt.setString(2, sShopUuid);
					rs = pstmt.executeQuery();

					int resultCount = 0;
					while (rs.next()) {
						String productUuid = rs.getString("PRODUCT_UUID");
						String productName = rs.getString("PRODUCT_NAME");
						String productPrice = df.format(rs.getInt("PRODUCT_PRICE"));
						String productImg = rs.getString("PRODUCT_IMG");
				%>
				<li>
					<div class="item-container" onclick="addCart('<%=productUuid%>');">
						<div class="productImg">
							<img
                        		src="<%=request.getContextPath()%>/images/category_<%=sCategoryCd%>/<%=(productImg != null && !productImg.isEmpty()) ? productImg : "kimbap_default.jpg"%>"
                        		alt="메뉴이미지" style="width: 120px; height: 120px; object-fit: cover;" />

						</div>

						<div class="productName">
							<label><%=productName%></label>
						</div>
						<div class="price">
							<label>&#8361; <%=productPrice%></label>
						</div>
					</div>
				</li>
				<%
				resultCount++;
				}
				if (resultCount == 0) {
				%>
				<li><label>조회된 상품이 없습니다.</label></li>
				<%
				}
				} catch (SQLException ex) {
				out.println("상품 조회 오류 발생: " + ex.getMessage());
				ex.printStackTrace();
				} finally {
				if (rs != null)
				try {
					rs.close();
				} catch (Exception e) {
				}
				if (pstmt != null)
				try {
					pstmt.close();
				} catch (Exception e) {
				}
				if (conn != null)
				try {
					conn.close();
				} catch (Exception e) {
				}
				}
				%>
			</ul>
		</div>
	</section>

	<section>
		<jsp:include page="footer.jsp" flush="true" />
	</section>
</body>
</html>
