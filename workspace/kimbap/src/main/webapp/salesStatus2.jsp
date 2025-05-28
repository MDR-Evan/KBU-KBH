<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.DecimalFormat" %>
<%@ include file="globalVar.jsp" %>
<%@ include file="dbconn.jsp"   %>

<%
request.setCharacterEncoding("UTF-8");

String sCategoryCd = request.getParameter("sCategoryCd");
String sRegDt = request.getParameter("sRegDt"); // yyyy-MM 형식

if (sRegDt == null || sRegDt.trim().isEmpty()) {
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM");
    sRegDt = sdf.format(new java.util.Date());
}

StringBuffer sql = new StringBuffer();
sql.append("SELECT C.PRODUCT_NAME, SUM(B.QUANTITY) AS TOTAL_QUANTITY, SUM(B.PRICE * B.QUANTITY) AS TOTAL_SALES_AMOUNT ");
sql.append("FROM KB_Order_Master A ");
sql.append("INNER JOIN KB_Order_Item B ON A.ORDER_UUID = B.ORDER_UUID AND A.SHOP_UUID = B.SHOP_UUID ");
sql.append("INNER JOIN KB_Product C ON B.PRODUCT_UUID = C.PRODUCT_UUID AND B.SHOP_UUID = C.SHOP_UUID ");
sql.append("WHERE A.ORDER_STATUS = 'DC' AND A.SHOP_UUID = ? ");
if (sCategoryCd != null && !sCategoryCd.trim().isEmpty()) {
	sql.append("AND C.CATEGORY_CD = ? ");
}
if (sRegDt != null && !sRegDt.trim().isEmpty()) {
	sql.append("AND TO_CHAR(A.REG_DT,'YYYY-MM') = ? ");
}
sql.append("GROUP BY C.PRODUCT_NAME, C.PRODUCT_SORT ");
sql.append("ORDER BY SUM(B.PRICE * B.QUANTITY) DESC, C.PRODUCT_SORT ASC");

PreparedStatement pstmt = null;
ResultSet rs = null;
List<String[]> dataRows = new ArrayList<>();
long grandTotalQty = 0;
long grandTotalPrice = 0;
DecimalFormat df = new DecimalFormat("#,###");

try {
	pstmt = conn.prepareStatement(sql.toString());
	int idx = 1;
	pstmt.setString(idx++, sShopUuid);
	if (sCategoryCd != null && !sCategoryCd.trim().isEmpty()) pstmt.setString(idx++, sCategoryCd);
	if (sRegDt != null && !sRegDt.trim().isEmpty()) pstmt.setString(idx++, sRegDt);
	
	rs = pstmt.executeQuery();
	while (rs.next()) {
		String name = rs.getString("PRODUCT_NAME");
		long qty = rs.getLong("TOTAL_QUANTITY");
		long priceAmount = rs.getLong("TOTAL_SALES_AMOUNT");
		grandTotalQty += qty;
		grandTotalPrice += priceAmount;
		dataRows.add(new String[]{name, String.valueOf(qty), String.valueOf(priceAmount)});
	}
} catch (Exception e) {
	e.printStackTrace(); // 서버 로그에 오류 출력
} finally {
	if (rs != null) try { rs.close(); } catch (Exception e) {}
	if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
	if (conn != null) try { conn.close(); } catch (Exception e) {}
}
// 디버깅을 위해 데이터 출력 (개발 완료 후 제거)
System.out.println("salesStatus2.jsp - dataRows.size(): " + dataRows.size());
for(String[] rowDebug : dataRows) {
    System.out.println("Product: " + rowDebug[0] + ", Qty: " + rowDebug[1] + ", Amount: " + rowDebug[2]);
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>매출현황 - 상품별목록</title>
<%-- <link rel="stylesheet" href="style.css"> --%>
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<style>
body {
    font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
    background-color: #f7f0e5;
    margin: 0;
    padding: 0;
    color: #333;
}
.page-container {
    padding: 0 20px 20px 20px;
}
.navigation-links {
    margin: 15px 0 25px 0;
    padding-left: 5%;
    font-size: 0.9rem;
    border-bottom: 1px solid #e0e0e0;
    padding-bottom: 15px;
}
.navigation-links a {
    text-decoration: none;
    color: #3498db;
    margin-right: 15px;
    padding: 5px 0;
    font-weight: 500;
}
.navigation-links a:hover, .navigation-links a.active {
    color: #e74c3c;
    border-bottom: 2px solid #e74c3c;
}

.page-title {
    text-align: center;
    margin: 0 0 25px 0;
    font-size: 2rem;
    font-weight: bold;
    color: #27ae60;
}

.search-container {
    width: 90%;
    max-width: 800px;
    margin: 0 auto 25px auto;
    padding: 20px;
    background-color: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    display: flex;
    gap: 15px;
    align-items: center;
    flex-wrap: wrap;
    justify-content: center;
}
.search-container label {
    font-weight: bold;
    font-size: 0.9rem;
    margin-right: 5px;
}
.search-container select,
.search-container input[type="month"],
.search-container input[type="submit"] {
    padding: 8px 10px;
    border: 1px solid #ccc;
    border-radius: 6px;
    font-size: 0.9rem;
}
.search-container input[type="month"] {
    width: 150px;
}
.search-container input[type="submit"].search-btn {
    background-color: #3498db;
    color: white;
    font-weight: bold;
    cursor: pointer;
    transition: background-color 0.3s ease;
}
.search-container input[type="submit"].search-btn:hover {
    background-color: #2980b9;
}

.data-display-section {
    display: flex;
    justify-content: space-between;
    gap: 20px;
    width: 90%;
    max-width: 1300px; 
    margin: 0 auto;
    flex-wrap: wrap;
}

table.kiosk-style-table {
    flex-basis: 40%; 
    min-width: 320px;
    border-collapse: collapse;
    background-color: #ffffff;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    border-radius: 8px;
    overflow: hidden;
    font-size: 0.9rem;
    align-self: flex-start; 
}
table.kiosk-style-table th,
table.kiosk-style-table td {
    padding: 10px 12px;
    text-align: center;
    border: 1px solid #eeeeee;
}
table.kiosk-style-table th {
    background-color: #e74c3c;
    color: white;
    font-weight: bold;
}
table.kiosk-style-table td.product-name-cell {
    text-align: left; 
}
table.kiosk-style-table td.number-cell {
    text-align: right; 
}
table.kiosk-style-table tr.totals-row td {
    font-weight: bold;
    background-color: #f9f9f9;
    color: #2c3e50;
    border-top: 2px solid #e74c3c;
}

.charts-area-container { 
    flex-basis: 58%; 
    min-width: 320px;
    display: flex;
    gap: 20px; 
    flex-wrap: wrap; 
}
.chart-container {
    flex: 1; 
    min-width: 280px; 
    height: 380px;
    padding: 15px;
    background-color: #fff;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    display: flex; 
    align-items: center;
    justify-content: center;
}
.chart-container > div { 
    width:100% !important; 
    height:100% !important;
}

@media (max-width: 992px) { 
    .data-display-section {
        flex-direction: column;
        align-items: center; 
    }
    table.kiosk-style-table, .charts-area-container {
        flex-basis: auto; 
        width: 100%; 
        max-width: 600px; 
        margin-bottom: 20px;
    }
    .charts-area-container {
        justify-content: center; 
    }
    .chart-container {
        height: 320px; 
    }
}
@media (max-width: 768px) {
    .search-container {
        flex-direction: column;
        align-items: stretch;
    }
    .search-container input[type="month"], .search-container select {
        width: 100%;
    }
}
</style>
</head>
<body>
	<jsp:include page="header.jsp" flush="true" />
    <div class="page-container">
        <jsp:include page="menuMag.jsp" flush="true" />
        <div class="navigation-links">
            <a href="salesStatus.jsp">월별 일 판매량 및 판매금액</a> |
            <a href="salesStatus2.jsp" class="active">월별 제품별 판매량 및 판매금액</a>
        </div>

        <h2 class="page-title">월별 제품별 판매량 및 판매금액</h2>
        <div class="search-container">
            <form id="frmSearch" name="frmSearch" action="salesStatus2.jsp" method="post" style="display:contents;">
                <label for="sCategoryCdSales2">카테고리</label>
                <select name="sCategoryCd" id="sCategoryCdSales2">
                    <option value="" <%= (sCategoryCd == null || "".equals(sCategoryCd)) ? "selected" : "" %>>전체</option>
                    <option value="01" <%= "01".equals(sCategoryCd) ? "selected" : "" %>>김밥류</option>
                    <option value="02" <%= "02".equals(sCategoryCd) ? "selected" : "" %>>분식류</option>
                    <option value="03" <%= "03".equals(sCategoryCd) ? "selected" : "" %>>식사류</option>
                    <option value="04" <%= "04".equals(sCategoryCd) ? "selected" : "" %>>돈까스류</option>
                </select>
                <label for="sRegDtSales2" style="margin-left: 20px;">년월</label>
                <input type="month" id="sRegDtSales2" name="sRegDt" value="<%= sRegDt %>">
                <input type="submit" value="검색" class="search-btn" style="margin-left: 10px;">
            </form>
        </div>

        <div class="data-display-section">
            <table class="kiosk-style-table">
                <thead>
                    <tr>
                        <th>제품</th>
                        <th>수량</th>
                        <th>금액</th>
                    </tr>
                </thead>
                <tbody>
                <% if (dataRows.isEmpty()) { %>
                    <tr>
                        <td colspan="3" style="padding: 20px; text-align:center;">해당 조건의 매출 데이터가 없습니다.</td>
                    </tr>
                <% } else { %>
                    <% for (String[] r : dataRows) { %>
                    <tr>
                        <td class="product-name-cell"><%= (r[0] == null ? "N/A" : r[0]) %></td>
                        <td class="number-cell"><%= df.format(Long.parseLong(r[1])) %></td>
                        <td class="number-cell"><%= df.format(Long.parseLong(r[2])) %></td>
                    </tr>
                    <% } %>
                    <tr class="totals-row">
                        <td>합계</td>
                        <td class="number-cell"><%= df.format(grandTotalQty) %></td>
                        <td class="number-cell"><%= df.format(grandTotalPrice) %></td>
                    </tr>
                <% } %>
                </tbody>
            </table>

            <div class="charts-area-container">
                <div id="piechart_3d" class="chart-container"></div>
                <div id="piechart_3d2" class="chart-container"></div>
            </div>
        </div>
    </div>

<script>
	google.charts.load('current', { packages: ['corechart'] });
	google.charts.setOnLoadCallback(drawCharts);

	function drawCharts() {
        console.log("drawCharts function called.");
        drawAmountChart();
        drawQuantityChart();
	}

    function drawAmountChart() {
        console.log("Attempting to draw Amount Chart (piechart_3d).");
        var chartDiv = document.getElementById('piechart_3d');
        if (chartDiv == null) {
            console.error("Chart DIV 'piechart_3d' not found.");
            return;
        }

        var data = new google.visualization.DataTable();
		data.addColumn('string', '제품');
		data.addColumn('number', '금액');
        
        var chartDataArray = [];
        <% if (!dataRows.isEmpty()) { %>
            console.log("Amount Chart: dataRows is not empty. Size: <%= dataRows.size() %>");
			<%
			for (int i = 0; i < dataRows.size(); i++) {
				String[] r = dataRows.get(i); // r[0]: 제품명, r[1]: 수량, r[2]: 금액
                String productName = r[0];
                if (productName == null) {
                    productName = "N/A"; 
                }
                // JavaScript 문자열 내에 사용되므로, 백슬래시와 작은따옴표 이스케이프
                productName = productName.replace("\\", "\\\\").replace("'", "\\'");
                
                // r[2] (금액)는 이미 숫자 형태의 문자열 (예: "6000")
				out.print("chartDataArray.push(['" + productName + "', " + r[2] + "]);\n");
			}
			%>
            console.log("Amount Chart: Generated chartDataArray:", chartDataArray);
            if (chartDataArray.length > 0) {
                 data.addRows(chartDataArray);
            } else {
                 console.log("Amount Chart: chartDataArray is empty after processing dataRows.");
            }
        <% } else { %>
            console.log("Amount Chart: dataRows is empty (JSP check).");
        <% } %>

		var options = {
			title: '<%= sRegDt %> 제품별 판매금액 비율',
            titleTextStyle: { fontSize: 16, bold: true, color: '#333' },
			is3D: true,
            legend: { position: 'labeled', textStyle: {fontSize: 12} },
            pieSliceText: 'percentage',
            pieSliceTextStyle: { fontSize: 11, color: 'black' },
            chartArea: {left:20, top:50, width:'90%', height:'80%'},
            tooltip: { textStyle: {fontSize: 12} }
		};
        
        // 데이터가 실제로 추가되었는지 확인 후 차트 그리기
        if (data.getNumberOfRows() === 0){
            console.log("Amount Chart: No data rows in DataTable, displaying message.");
            chartDiv.innerHTML = '<div style="text-align:center; padding-top:100px; color:#888;">판매금액 데이터가 없습니다.</div>';
            return;
        }
        try {
            console.log("Amount Chart: Attempting to draw.");
            var chart = new google.visualization.PieChart(chartDiv);
            chart.draw(data, options);
            console.log("Amount Chart: Drawn successfully.");
        } catch (e) {
            console.error("Error drawing Amount Chart:", e);
            chartDiv.innerHTML = '<div style="text-align:center; padding-top:100px; color:red;">차트 로딩 중 오류 발생 (금액)</div>';
        }
    }

    function drawQuantityChart() {
        console.log("Attempting to draw Quantity Chart (piechart_3d2).");
        var chartDiv = document.getElementById('piechart_3d2');
        if (chartDiv == null) {
            console.error("Chart DIV 'piechart_3d2' not found.");
            return;
        }

        var data = new google.visualization.DataTable();
		data.addColumn('string', '제품');
		data.addColumn('number', '수량');
        
        var chartDataArray = [];
        <% if (!dataRows.isEmpty()) { %>
            console.log("Quantity Chart: dataRows is not empty. Size: <%= dataRows.size() %>");
			<%
			for (int i = 0; i < dataRows.size(); i++) {
				String[] r = dataRows.get(i); // r[0]: 제품명, r[1]: 수량, r[2]: 금액
                String productName = r[0];
                if (productName == null) {
                    productName = "N/A"; 
                }
                productName = productName.replace("\\", "\\\\").replace("'", "\\'");
                
				out.print("chartDataArray.push(['" + productName + "', " + r[1] + "]);\n");
			}
			%>
            console.log("Quantity Chart: Generated chartDataArray:", chartDataArray);
             if (chartDataArray.length > 0) {
                 data.addRows(chartDataArray);
            } else {
                 console.log("Quantity Chart: chartDataArray is empty after processing dataRows.");
            }
        <% } else { %>
             console.log("Quantity Chart: dataRows is empty (JSP check).");
        <% } %>

		var options = {
			title: '<%= sRegDt %> 제품별 판매수량 비율',
            titleTextStyle: { fontSize: 16, bold: true, color: '#333' },
			pieHole: 0.4, 
            legend: { position: 'labeled', textStyle: {fontSize: 12} },
            pieSliceText: 'percentage',
            pieSliceTextStyle: { fontSize: 11, color: 'black' },
            chartArea: {left:20, top:50, width:'90%', height:'80%'},
            tooltip: { textStyle: {fontSize: 12} }
		};

        if (data.getNumberOfRows() === 0){
            console.log("Quantity Chart: No data rows in DataTable, displaying message.");
            chartDiv.innerHTML = '<div style="text-align:center; padding-top:100px; color:#888;">판매수량 데이터가 없습니다.</div>';
            return;
        }
        try {
            console.log("Quantity Chart: Attempting to draw.");
            var chart = new google.visualization.PieChart(chartDiv);
            chart.draw(data, options);
            console.log("Quantity Chart: Drawn successfully.");
        } catch (e) {
            console.error("Error drawing Quantity Chart:", e);
            chartDiv.innerHTML = '<div style="text-align:center; padding-top:100px; color:red;">차트 로딩 중 오류 발생 (수량)</div>';
        }
    }
    window.addEventListener('resize', drawCharts, false);
</script>
</body>
</html>