<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*"%>
<%@ include file="globalVar.jsp"%>
<%@ include file="dbconn.jsp"%>
<jsp:include page="header.jsp" />
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>매출현황1 - 일별목록</title>
	<link rel="stylesheet" href="style.css">
	<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
</head>
<body>
	<jsp:include page="menuMag.jsp" flush="true" />
	<div style="margin: 10px 0 40px 5%; font-size: 12px;">
		<a href="salesStatus.jsp">월별 일 판매량 및 판매금액</a> |
		<a href="salesStatus2.jsp">월별 제품별 판매량 및 판매금액</a>
	</div>

<%
String sCategoryCd = request.getParameter("sCategoryCd");
String sRegDt = request.getParameter("sRegDt");

StringBuffer sql = new StringBuffer();
sql.append("SELECT TO_CHAR(B.REG_DT,'MM-DD') REG_DAY, SUM(B.QUANTITY) QUANTITY, SUM(B.PRICE) PRICE ");
sql.append("FROM KB_Order_Master A ");
sql.append("INNER JOIN KB_Order_Item B ON A.ORDER_UUID = B.ORDER_UUID AND A.SHOP_UUID = B.SHOP_UUID ");
sql.append("INNER JOIN KB_Product C ON B.PRODUCT_UUID = C.PRODUCT_UUID AND B.SHOP_UUID = C.SHOP_UUID ");
sql.append("WHERE A.ORDER_STATUS = 'DC' AND A.SHOP_UUID = ? ");
if (sCategoryCd != null && !"".equals(sCategoryCd)) {
	sql.append("AND C.CATEGORY_CD = ? ");
}
if (sRegDt != null && !"".equals(sRegDt)) {
	sql.append("AND TO_CHAR(B.REG_DT,'YYYY-MM') = ? ");
}
sql.append("GROUP BY TO_CHAR(B.REG_DT,'MM-DD') ORDER BY TO_CHAR(B.REG_DT,'MM-DD') ASC");

PreparedStatement pstmt = null;
ResultSet rs = null;
List<String[]> dataRows = new ArrayList<>();
int totalQty = 0;
int totalPrice = 0;

try {
	pstmt = conn.prepareStatement(sql.toString());
	int idx = 1;
	pstmt.setString(idx++, sShopUuid);
	if (sCategoryCd != null && !"".equals(sCategoryCd)) pstmt.setString(idx++, sCategoryCd);
	if (sRegDt != null && !"".equals(sRegDt)) pstmt.setString(idx++, sRegDt);
	rs = pstmt.executeQuery();
	while (rs.next()) {
		String day = rs.getString("REG_DAY");
		int qty = rs.getInt("QUANTITY");
		int price = rs.getInt("PRICE");
		totalQty += qty;
		totalPrice += price;
		dataRows.add(new String[]{day, String.valueOf(price), String.valueOf(qty)});
	}
} catch (Exception e) {
	e.printStackTrace();
} finally {
	if (rs != null) try { rs.close(); } catch (Exception e) {}
	if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
	if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>

<section style="width: 90%; margin: 20px auto;">
	<h2 style="text-align: center;">월별 일 판매량 및 판매금액</h2>

	<form id="frmSearch" name="frmSearch" action="salesStatus.jsp" method="post" style="text-align: center; margin-bottom: 20px;">
		<label>카테고리</label>
		<select name="sCategoryCd">
			<option value="" <%= (sCategoryCd == null || "".equals(sCategoryCd)) ? "selected" : "" %>>전체</option>
			<option value="01" <%= "01".equals(sCategoryCd) ? "selected" : "" %>>김밥류</option>
			<option value="02" <%= "02".equals(sCategoryCd) ? "selected" : "" %>>분식류</option>
			<option value="03" <%= "03".equals(sCategoryCd) ? "selected" : "" %>>식사류</option>
			<option value="04" <%= "04".equals(sCategoryCd) ? "selected" : "" %>>돈까스류</option>
		</select>
		<label style="margin-left: 20px;">년월</label>
		<input type="month" name="sRegDt" value="<%= sRegDt == null ? "" : sRegDt %>" style="width: 120px;">
		<input type="submit" value="검색" style="margin-left: 10px;">
	</form>

	<div style="display: flex; justify-content: space-between; gap: 20px;">
		<table border="1" style="width: 48%; border-collapse: collapse; text-align: center;">
			<tr>
				<th>일자</th>
				<th>수량</th>
				<th>금액</th>
			</tr>
			<% for (String[] row : dataRows) { %>
			<tr>
				<td><%= row[0] %></td>
				<td><%= row[2] %></td>
				<td><%= row[1] %></td>
			</tr>
			<% } %>
			<tr style="font-weight: bold;">
				<td>합계</td>
				<td><%= totalQty %></td>
				<td><%= totalPrice %></td>
			</tr>
		</table>

		<div id="columnchart_values" style="width: 48%; height: 300px;"></div>
	</div>
</section>

<script>
	google.charts.load('current', { packages: ['corechart'] });
	google.charts.setOnLoadCallback(function () {
		var data = new google.visualization.DataTable();
		data.addColumn('string', '일자');
		data.addColumn('number', '금액');
		data.addColumn('number', '수량');
		data.addRows([
			<%
			for (int i = 0; i < dataRows.size(); i++) {
				String[] r = dataRows.get(i);
				out.print("['" + r[0] + "', " + r[1] + ", " + r[2] + "]");
				if (i < dataRows.size() - 1) out.print(",");
			}
			%>
		]);

		var options = {
			title: '월별 일 판매량 및 판매금액',
			height: 350,
			vAxes: {
				0: { title: '금액' },
				1: { title: '수량' }
			},
			series: {
				0: { targetAxisIndex: 0, type: 'bars' },
				1: { targetAxisIndex: 1, type: 'line' }
			},
			hAxis: {
				title: '일자'
			}
		};

		new google.visualization.ComboChart(document.getElementById('columnchart_values')).draw(data, options);
	});
</script>
</body>
</html>
