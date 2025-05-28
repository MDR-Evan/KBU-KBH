<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="globalVar.jsp"%>
<%@ include file="dbconn.jsp"%>
<%
PreparedStatement pstmt = null;
ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>주문관리</title>
<link href="style.css" rel="stylesheet" type="text/css">
<script>
	function search() {
		document.getElementById("frmOrderSearch").submit();
	}
	function orderComp(uuid) {
		var f = document.getElementById("frmOrder");
		f.orderUuid.value = uuid;
		f.orderStatus.value = "DC";
		f.submit();
	}
	function orderCancel(uuid) {
		var f = document.getElementById("frmOrder");
		f.orderUuid.value = uuid;
		f.orderStatus.value = "CC";
		f.submit();
	}
</script>
<style>
.container {
	width: 50vw;
	margin: 0 auto;
}
</style>
</head>
<body>
	<jsp:include page="header.jsp" flush="true" />
	<section>
		<jsp:include page="menuMag.jsp" flush="true" />
	</section>

	<h2
		style="text-align: center; margin: 20px 0; font-size: 1.5rem; font-weight: bold;">
		주문 관리</h2>

	<div class="container">
		<!-- 검색 폼 -->
		<form id="frmOrderSearch" method="post" action="orderMag.jsp">
			<label>주문일자</label> <input type="date" name="sOrderDt"
				value="<%=request.getParameter("sOrderDt") != null ? request.getParameter("sOrderDt") : ""%>">
			<label>주문상태</label> <select name="sOrderStatus">
				<option value="">전체</option>
				<option value="PC"
					<%="PC".equals(request.getParameter("sOrderStatus")) ? "selected" : ""%>>결제완료</option>
				<option value="DC"
					<%="DC".equals(request.getParameter("sOrderStatus")) ? "selected" : ""%>>지급완료</option>
				<option value="CC"
					<%="CC".equals(request.getParameter("sOrderStatus")) ? "selected" : ""%>>취소완료</option>
			</select> <input type="button" onclick="search();" value="검색">
		</form>

		<!-- 주문 목록 -->
		<table class="order-table" border="1">
			<thead>
				<tr>
					<th>주문번호</th>
					<th>상품명</th>
					<th>가격</th>
					<th>수량</th>
					<th>주문일시</th>
					<th>주문상태</th>
					<th>관리</th>
				</tr>
			</thead>
			<tbody>
				<%
				String sOrderDt = request.getParameter("sOrderDt") == null ? "" : request.getParameter("sOrderDt");
				String sOrderStatus = request.getParameter("sOrderStatus") == null ? "" : request.getParameter("sOrderStatus");

				StringBuffer sql = new StringBuffer();
				sql.append("SELECT A.ORDER_UUID, ").append("       C.PRODUCT_NAME, ").append("       B.PRICE, B.QUANTITY, ")
						.append("       A.REG_DT, ")
						.append("       DECODE(A.ORDER_STATUS, 'PC','결제완료','DC','지급완료','CC','취소완료') AS ORDER_STATUS_NM, ")
						.append("       A.ORDER_STATUS, ").append("       COUNT(*) OVER (PARTITION BY A.ORDER_UUID) AS ROW_CNT ")
						.append("  FROM KB_Order_Master A ")
						.append("  JOIN KB_Order_Item B ON A.ORDER_UUID = B.ORDER_UUID AND A.SHOP_UUID = B.SHOP_UUID ")
						.append("  JOIN KB_Product C ON B.PRODUCT_UUID = C.PRODUCT_UUID AND B.SHOP_UUID = C.SHOP_UUID ")
						.append(" WHERE A.SHOP_UUID = ? ");
				if (!"".equals(sOrderStatus))
					sql.append(" AND A.ORDER_STATUS = ? ");
				if (!"".equals(sOrderDt))
					sql.append(" AND TO_CHAR(A.REG_DT,'YYYY-MM-DD') = ? ");
				sql.append(" ORDER BY A.REG_DT DESC, C.PRODUCT_SORT ASC");

				pstmt = conn.prepareStatement(sql.toString());
				int idx = 1;
				pstmt.setString(idx++, sShopUuid);
				if (!"".equals(sOrderStatus))
					pstmt.setString(idx++, sOrderStatus);
				if (!"".equals(sOrderDt))
					pstmt.setString(idx++, sOrderDt);

				rs = pstmt.executeQuery();

				String prevUuid = "";
				int totalPrice = 0, totalQty = 0;
				while (rs.next()) {
					String uuid = rs.getString("ORDER_UUID");
					String name = rs.getString("PRODUCT_NAME");
					int price = rs.getInt("PRICE");
					int qty = rs.getInt("QUANTITY");
					String regDt = rs.getString("REG_DT");
					String statusCode = rs.getString("ORDER_STATUS");
					String statusNm = rs.getString("ORDER_STATUS_NM");
					int rowCnt = rs.getInt("ROW_CNT");

					if ("DC".equals(statusCode)) {
						totalPrice += price;
						totalQty += qty;
					}
				%>
				<tr>
					<%
					if (!uuid.equals(prevUuid)) {
					%>
					<td rowspan="<%=rowCnt%>"><%=uuid%></td>
					<%
					}
					%>

					<td><%=name%></td>
					<td><%=price%></td>
					<td><%=qty%></td>

					<%
					if (!uuid.equals(prevUuid)) {
					%>
					<td rowspan="<%=rowCnt%>"><%=regDt%></td>
					<td rowspan="<%=rowCnt%>"><%=statusNm%></td>
					<td rowspan="<%=rowCnt%>">
						<%
						if ("PC".equals(statusCode)) {
						%>
						<button onclick="orderComp('<%=uuid%>')">지급처리</button>
						<button onclick="orderCancel('<%=uuid%>')">취소처리</button> <%
 }
 %>
					</td>
					<%
					}
					%>
				</tr>
				<%
				prevUuid = uuid;
				}
				%>
			</tbody>
			<tfoot>
				<tr>
					<td colspan="2">합계(지급완료)</td>
					<td><%=totalPrice%></td>
					<td><%=totalQty%></td>
					<td colspan="3"></td>
				</tr>
			</tfoot>
		</table>

		<form id="frmOrder" method="post" action="orderComp.jsp">
			<input type="hidden" name="orderUuid"> <input type="hidden"
				name="orderStatus">
		</form>
	</div>

	<%
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
	%>
</body>
</html>
