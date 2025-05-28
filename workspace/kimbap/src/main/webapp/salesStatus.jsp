<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.DecimalFormat" %>
<%@ include file="globalVar.jsp" %>
<%@ include file="dbconn.jsp"   %>

<%
request.setCharacterEncoding("UTF-8"); // 요청 인코딩 설정

String sCategoryCd = request.getParameter("sCategoryCd");
String sRegDt = request.getParameter("sRegDt"); // YYYY-MM 형식

// sRegDt가 null이거나 비어있을 경우, 현재 월로 기본값 설정 (선택 사항)
if (sRegDt == null || sRegDt.trim().isEmpty()) {
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM");
    sRegDt = sdf.format(new java.util.Date());
}


StringBuffer sql = new StringBuffer();
sql.append("SELECT TO_CHAR(A.REG_DT,'MM-DD') REG_DAY, SUM(B.QUANTITY) QUANTITY, SUM(B.PRICE * B.QUANTITY) TOTAL_PRICE "); // PRICE * QUANTITY 로 수정
sql.append("FROM KB_Order_Master A ");
sql.append("INNER JOIN KB_Order_Item B ON A.ORDER_UUID = B.ORDER_UUID AND A.SHOP_UUID = B.SHOP_UUID ");
sql.append("INNER JOIN KB_Product C ON B.PRODUCT_UUID = C.PRODUCT_UUID AND B.SHOP_UUID = C.SHOP_UUID ");
sql.append("WHERE A.ORDER_STATUS = 'DC' AND A.SHOP_UUID = ? "); // 지급완료(DC)된 주문만 집계
if (sCategoryCd != null && !sCategoryCd.trim().isEmpty()) {
	sql.append("AND C.CATEGORY_CD = ? ");
}
if (sRegDt != null && !sRegDt.trim().isEmpty()) {
	sql.append("AND TO_CHAR(A.REG_DT,'YYYY-MM') = ? "); // ORDER_MASTER의 REG_DT 사용
}
sql.append("GROUP BY TO_CHAR(A.REG_DT,'MM-DD') ORDER BY REG_DAY ASC");

PreparedStatement pstmt = null;
ResultSet rs = null;
List<String[]> dataRows = new ArrayList<>();
long totalQty = 0; // long 타입으로 변경 (큰 값 대비)
long totalPrice = 0; // long 타입으로 변경
DecimalFormat df = new DecimalFormat("#,###"); // 숫자 포맷팅

try {
	pstmt = conn.prepareStatement(sql.toString());
	int idx = 1;
	pstmt.setString(idx++, sShopUuid); // sShopUuid는 globalVar.jsp 등에서 설정되어야 함
	if (sCategoryCd != null && !sCategoryCd.trim().isEmpty()) pstmt.setString(idx++, sCategoryCd);
	if (sRegDt != null && !sRegDt.trim().isEmpty()) pstmt.setString(idx++, sRegDt);
	
	rs = pstmt.executeQuery();
	while (rs.next()) {
		String day = rs.getString("REG_DAY");
		long qty = rs.getLong("QUANTITY"); // long 타입으로 받음
		long price = rs.getLong("TOTAL_PRICE"); // long 타입으로 받음
		totalQty += qty;
		totalPrice += price;
		dataRows.add(new String[]{day, String.valueOf(price), String.valueOf(qty)});
	}
} catch (Exception e) {
	e.printStackTrace(); // 개발 중에는 스택 트레이스 확인, 운영 시 로깅 처리
} finally {
	if (rs != null) try { rs.close(); } catch (Exception e) {}
	if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
	if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>매출현황 - 일별목록</title>
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
.page-container { /* 전체 페이지 컨텐츠를 감싸는 래퍼 */
    padding: 0 20px 20px 20px; /* 좌우하단 패딩 */
}
.navigation-links {
    margin: 15px 0 25px 0; /* 상단 네비게이션 링크 여백 */
    padding-left: 5%; /* 기존 스타일과 유사하게 */
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
    justify-content: center; /* 중앙 정렬 */
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
    width: 150px; /* 년월 선택 필드 너비 */
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
    gap: 20px; /* 테이블과 차트 사이 간격 */
    width: 90%;
    max-width: 1200px; /* 최대 너비 설정 */
    margin: 0 auto; /* 중앙 정렬 */
    flex-wrap: wrap; /* 작은 화면에서 줄 바꿈 */
}

table.kiosk-style-table {
    flex: 1; /* flex 아이템으로 설정, 비율에 따라 너비 조절 가능 */
    min-width: 300px; /* 최소 너비 */
    border-collapse: collapse;
    background-color: #ffffff;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    border-radius: 8px;
    overflow: hidden;
    font-size: 0.9rem;
}
table.kiosk-style-table th,
table.kiosk-style-table td {
    padding: 10px 12px;
    text-align: center;
    border: 1px solid #eeeeee; /* 모든 셀에 테두리 */
}
table.kiosk-style-table th {
    background-color: #e74c3c;
    color: white;
    font-weight: bold;
}
table.kiosk-style-table td {
    color: #333333;
}
table.kiosk-style-table tr:last-child td { /* 합계 행 스타일 */
    font-weight: bold;
    background-color: #f9f9f9;
    color: #2c3e50;
    border-top: 2px solid #e74c3c;
}
table.kiosk-style-table td.number-cell {
    text-align: right; /* 숫자 오른쪽 정렬 */
}

.chart-container {
    flex: 1; /* flex 아이템 */
    min-width: 300px; /* 최소 너비 */
    height: 380px; /* 차트 높이 (옵션에서 350px + 여유) */
    padding: 10px;
    background-color: #fff;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

/* 모바일 등 작은 화면 대응 */
@media (max-width: 768px) {
    .data-display-section {
        flex-direction: column; /* 작은 화면에서는 수직으로 쌓음 */
    }
    table.kiosk-style-table, .chart-container {
        width: 100%; /* 작은 화면에서는 너비 100% */
        flex: none; /* flex 비율 해제 */
    }
    .search-container {
        flex-direction: column;
        align-items: stretch; /* 검색폼 요소들도 수직으로 */
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
            <a href="salesStatus.jsp" class="active">월별 일 판매량 및 판매금액</a> | &nbsp;&nbsp;
            <a href="salesStatus2.jsp">월별 제품별 판매량 및 판매금액</a>
        </div>

        <h2 class="page-title">월별 일 판매량 및 판매금액</h2>

        <div class="search-container">
            <form id="frmSearch" name="frmSearch" action="salesStatus.jsp" method="post" style="display:contents;">
                <label for="sCategoryCdSales">카테고리</label>
                <select name="sCategoryCd" id="sCategoryCdSales">
                    <option value="" <%= (sCategoryCd == null || "".equals(sCategoryCd)) ? "selected" : "" %>>전체</option>
                    <option value="01" <%= "01".equals(sCategoryCd) ? "selected" : "" %>>김밥류</option>
                    <option value="02" <%= "02".equals(sCategoryCd) ? "selected" : "" %>>분식류</option>
                    <option value="03" <%= "03".equals(sCategoryCd) ? "selected" : "" %>>식사류</option>
                    <option value="04" <%= "04".equals(sCategoryCd) ? "selected" : "" %>>돈까스류</option>
                </select>
                <label for="sRegDtSales" style="margin-left: 20px;">년월</label>
                <input type="month" id="sRegDtSales" name="sRegDt" value="<%= sRegDt %>">
                <input type="submit" value="검색" class="search-btn" style="margin-left: 10px;">
            </form>
        </div>

        <div class="data-display-section">
            <table class="kiosk-style-table">
                <thead>
                    <tr>
                        <th>일자</th>
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
                    <% for (String[] row : dataRows) { %>
                    <tr>
                        <td><%= row[0] %></td>
                        <td class="number-cell"><%= df.format(Long.parseLong(row[2])) %></td>
                        <td class="number-cell"><%= df.format(Long.parseLong(row[1])) %></td>
                    </tr>
                    <% } %>
                    <tr class="totals-row">
                        <td>합계</td>
                        <td class="number-cell"><%= df.format(totalQty) %></td>
                        <td class="number-cell"><%= df.format(totalPrice) %></td>
                    </tr>
                <% } %>
                </tbody>
            </table>

            <div id="columnchart_values" class="chart-container"></div>
        </div>
    </div>
<script>
	google.charts.load('current', { packages: ['corechart', 'bar'] }); // 'bar' 패키지 추가 (ComboChart에 필요할 수 있음)
	google.charts.setOnLoadCallback(drawChart);

	function drawChart() {
        if (document.getElementById('columnchart_values') == null) return; // 차트 div 없으면 실행 안 함
        
		var data = new google.visualization.DataTable();
		data.addColumn('string', '일자');
		data.addColumn('number', '금액');
        data.addColumn({type: 'string', role: 'annotation'}); // 금액 annotation
		data.addColumn('number', '수량');
        data.addColumn({type: 'string', role: 'annotation'}); // 수량 annotation

        <% if (!dataRows.isEmpty()) { %>
		data.addRows([
			<%
			DecimalFormat noCommaDf = new DecimalFormat("###0"); // 차트용 숫자 포맷 (콤마 없음)
			for (int i = 0; i < dataRows.size(); i++) {
				String[] r = dataRows.get(i);
                String priceStr = noCommaDf.format(Long.parseLong(r[1]));
                String qtyStr = noCommaDf.format(Long.parseLong(r[2]));
				// 차트에 표시될 annotation (값 자체)
                String priceAnnotation = df.format(Long.parseLong(r[1]));
                String qtyAnnotation = df.format(Long.parseLong(r[2]));

				out.print("['" + r[0] + "', " + priceStr + ", '" + priceAnnotation + "', " + qtyStr + ", '" + qtyAnnotation + "']");
				if (i < dataRows.size() - 1) out.print(",");
			}
			%>
		]);
        <% } else { %>
            // 데이터가 없을 경우 차트에 빈 데이터나 메시지 표시 (선택적)
            // data.addRows([["데이터 없음", 0, "0", 0, "0"]]);
             document.getElementById('columnchart_values').innerHTML = '<div style="text-align:center; padding-top:100px; color:#888;">차트를 표시할 데이터가 없습니다.</div>';
            return; // 데이터 없으면 차트 그리지 않음
        <% } %>


		var options = {
			title: '<%= sRegDt %> 매출 현황', // 동적 타이틀
			titleTextStyle: { fontSize: 16, bold: true },
			height: 350, // 차트 영역 높이
            legend: { position: 'top', alignment: 'center' },
			vAxes: { // 다중 Y축 설정
				0: { title: '금액 (원)', format: '#,###원', textStyle: {fontSize: 11}, titleTextStyle: {fontSize: 13, bold:true} }, // 왼쪽 Y축 (금액)
				1: { title: '수량 (개)', format: '#,###개', textStyle: {fontSize: 11}, titleTextStyle: {fontSize: 13, bold:true}, gridlines: {color: 'transparent'} }  // 오른쪽 Y축 (수량)
			},
			series: { // 시리즈별 설정
				0: { targetAxisIndex: 0, type: 'bars', color: '#e74c3c', annotations: { textStyle: {fontSize: 10, color: 'black', auraColor: 'transparent'}, alwaysOutside: true } }, // 금액: 막대 그래프
				1: { targetAxisIndex: 1, type: 'line', color: '#3498db', lineWidth: 2, pointSize: 5, annotations: { textStyle: {fontSize: 10, color: 'black', auraColor: 'transparent'}, alwaysOutside: true } }  // 수량: 선 그래프
			},
			hAxis: {
				title: '일자',
                showTextEvery: 1, // 모든 X축 레이블 표시
                textStyle: {fontSize: 11},
                titleTextStyle: {fontSize: 13, bold:true}
			},
            chartArea: {left:80, top:50, width:'85%', height:'65%'}, // 차트 내부 영역 조절
            tooltip: { isHtml: true } // 툴팁 HTML 사용 가능
		};

		var chart = new google.visualization.ComboChart(document.getElementById('columnchart_values'));
		chart.draw(data, options);
	}
    // 창 크기 변경 시 차트 다시 그리기 (반응형)
    window.addEventListener('resize', drawChart, false);
</script>
</body>
</html>