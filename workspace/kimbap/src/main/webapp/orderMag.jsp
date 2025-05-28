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
body {
    font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
    background-color: #f7f0e5; /* 전체 배경색 */
    margin: 0;
    padding: 0;
    color: #333;
}

/* 페이지 제목 스타일 */
.page-title {
    text-align: center;
    margin: 30px 0 25px 0;
    font-size: 2rem; /* 크기 증가 */
    font-weight: bold;
    color: #27ae60; /* 키오스크 메인 녹색 */
}

/* 검색 폼 컨테이너 */
.search-container {
    width: 90%;
    max-width: 1000px; /* 너비 조정 */
    margin: 0 auto 25px auto; /* 하단 마진 증가 */
    padding: 20px;
    background-color: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    display: flex; /* Flexbox 레이아웃 사용 */
    gap: 15px; /* 요소 간 간격 */
    align-items: center; /* 수직 중앙 정렬 */
    flex-wrap: wrap; /* 작은 화면에서 줄 바꿈 허용 */
}

.search-container label {
    font-weight: bold;
    font-size: 0.9rem;
    margin-right: 5px;
}

.search-container input[type="date"],
.search-container select {
    padding: 8px 10px;
    border: 1px solid #ccc;
    border-radius: 6px;
    font-size: 0.9rem;
    min-width: 150px; /* 최소 너비 설정 */
}

.search-container input[type="button"].search-btn {
    background-color: #3498db; /* 검색 버튼 파란색 계열 */
    color: white;
    padding: 9px 18px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 0.9rem;
    font-weight: bold;
    transition: background-color 0.3s ease;
}
.search-container input[type="button"].search-btn:hover {
    background-color: #2980b9;
}

/* 주문 목록 테이블 스타일 */
table.kiosk-style-table {
    width: 90%;
    max-width: 1200px; /* 테이블 최대 너비 증가 */
    margin: 0 auto 30px auto;
    border-collapse: collapse;
    background-color: #ffffff;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    border-radius: 8px;
    overflow: hidden; /* border-radius 적용을 위해 */
    font-size: 0.9rem; /* 기본 폰트 크기 약간 줄임 */
}

table.kiosk-style-table th,
table.kiosk-style-table td {
    padding: 10px 12px; /* 패딩 약간 줄임 */
    text-align: center;
    border-bottom: 1px solid #eeeeee;
    border-left: 1px solid #eeeeee; /* 왼쪽 테두리 추가 */
}
table.kiosk-style-table th:first-child,
table.kiosk-style-table td:first-child {
    border-left: none; /* 첫 번째 열의 왼쪽 테두리 제거 */
}

table.kiosk-style-table th {
    background-color: #e74c3c; /* 키오스크 헤더 빨간색 */
    color: white;
    font-weight: bold;
    border-bottom: 2px solid #c0392b; /* 헤더 하단 강조선 */
}

table.kiosk-style-table tr:last-child td {
    border-bottom: none;
}
table.kiosk-style-table td {
    color: #333333;
}
table.kiosk-style-table td[rowspan] {
    vertical-align: middle; /* rowspan 셀 내용 수직 중앙 정렬 */
}

table.kiosk-style-table tbody tr:hover td {
    background-color: #f9f9f9; /* 마우스 오버 시 행 배경색 변경 */
}

/* 테이블 내 관리 버튼 스타일 */
table.kiosk-style-table .action-button {
    color: white;
    padding: 6px 10px;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-size: 0.85rem;
    transition: background-color 0.3s ease;
    margin: 2px;
}
.action-button.comp-btn {
    background-color: #27ae60; /* 지급처리: 녹색 */
}
.action-button.comp-btn:hover {
    background-color: #2ecc71;
}
.action-button.cancel-btn {
    background-color: #e67e22; /* 취소처리: 주황색 */
}
.action-button.cancel-btn:hover {
    background-color: #f39c12;
}

/* 테이블 푸터 스타일 */
table.kiosk-style-table tfoot td {
    background-color: #f5f5f5;
    font-weight: bold;
    color: #555;
    border-top: 2px solid #ddd;
}
</style>
</head>
<body>
	<jsp:include page="header.jsp" flush="true" />
	<section>
		<jsp:include page="menuMag.jsp" flush="true" />
	</section>

	<h2 class="page-title">주문 관리</h2>

	<div class="search-container">
		<form id="frmOrderSearch" method="post" action="orderMag.jsp">
			<label for="sOrderDt">주문일자</label>
            <input type="date" id="sOrderDt" name="sOrderDt" value="<%=request.getParameter("sOrderDt") != null ? request.getParameter("sOrderDt") : ""%>">
			
            <label for="sOrderStatus">주문상태</label>
            <select id="sOrderStatus" name="sOrderStatus">
				<option value="">전체</option>
				<option value="PC" <%="PC".equals(request.getParameter("sOrderStatus")) ? "selected" : ""%>>결제완료</option>
				<option value="DC" <%="DC".equals(request.getParameter("sOrderStatus")) ? "selected" : ""%>>지급완료</option>
				<option value="CC" <%="CC".equals(request.getParameter("sOrderStatus")) ? "selected" : ""%>>취소완료</option>
			</select>
            <input type="button" onclick="search();" value="검색" class="search-btn">
		</form>
	</div>

	<table class="kiosk-style-table">
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
			sql.append("SELECT A.ORDER_UUID, ")
               .append("       C.PRODUCT_NAME, ")
               .append("       B.PRICE, B.QUANTITY, ")
			   .append("       TO_CHAR(A.REG_DT, 'YYYY-MM-DD HH24:MI:SS') AS REG_DT_FORMATTED, ") // 날짜 포맷팅
			   .append("       DECODE(A.ORDER_STATUS, 'PC','결제완료','DC','지급완료','CC','취소완료') AS ORDER_STATUS_NM, ")
			   .append("       A.ORDER_STATUS, ")
               .append("       COUNT(*) OVER (PARTITION BY A.ORDER_UUID) AS ROW_CNT ")
			   .append("  FROM KB_Order_Master A ")
			   .append("  JOIN KB_Order_Item B ON A.ORDER_UUID = B.ORDER_UUID AND A.SHOP_UUID = B.SHOP_UUID ")
			   .append("  JOIN KB_Product C ON B.PRODUCT_UUID = C.PRODUCT_UUID AND B.SHOP_UUID = C.SHOP_UUID ")
			   .append(" WHERE A.SHOP_UUID = ? ");
			if (!"".equals(sOrderStatus))
				sql.append(" AND A.ORDER_STATUS = ? ");
			if (!"".equals(sOrderDt))
				sql.append(" AND TO_CHAR(A.REG_DT,'YYYY-MM-DD') = ? ");
			sql.append(" ORDER BY A.REG_DT DESC, A.ORDER_UUID DESC, C.PRODUCT_SORT ASC"); // 주문 UUID로도 정렬 추가

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
            boolean hasData = false;
			while (rs.next()) {
                hasData = true;
				String uuid = rs.getString("ORDER_UUID");
				String name = rs.getString("PRODUCT_NAME");
				int price = rs.getInt("PRICE");
				int qty = rs.getInt("QUANTITY");
				String regDtFormatted = rs.getString("REG_DT_FORMATTED"); // 포맷팅된 날짜 사용
				String statusCode = rs.getString("ORDER_STATUS");
				String statusNm = rs.getString("ORDER_STATUS_NM");
				int rowCnt = rs.getInt("ROW_CNT");

				if ("DC".equals(statusCode)) { // 지급완료 건만 합계에 포함
					totalPrice += (price * qty); // 수량 * 가격으로 합계
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
				<td style="text-align: right;"><%=String.format("%,d", price)%></td>
				<td><%=qty%></td>
				<%
				if (!uuid.equals(prevUuid)) {
				%>
				<td rowspan="<%=rowCnt%>"><%=regDtFormatted%></td>
				<td rowspan="<%=rowCnt%>"><%=statusNm%></td>
				<td rowspan="<%=rowCnt%>">
					<%
					if ("PC".equals(statusCode)) { // 결제완료 상태일 때만 버튼 표시
					%>
					<button class="action-button comp-btn" onclick="orderComp('<%=uuid%>')">지급처리</button>
					<button class="action-button cancel-btn" onclick="orderCancel('<%=uuid%>')">취소처리</button> 
                    <%
					} else {
                        out.print("-"); // 다른 상태일 경우 '-' 표시
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
            if (!hasData) {
            %>
            <tr>
                <td colspan="7" style="text-align:center; padding: 20px;">조회된 주문 내역이 없습니다.</td>
            </tr>
            <%
            }
			%>
		</tbody>
        <% if (hasData) { %>
		<tfoot>
			<tr>
				<td colspan="2" style="text-align: right; font-weight:bold;">합계 (지급완료 건)</td>
				<td style="text-align: right; font-weight:bold;"><%=String.format("%,d", totalPrice)%></td>
				<td style="font-weight:bold;"><%=totalQty%></td>
				<td colspan="3"></td>
			</tr>
		</tfoot>
        <% } %>
	</table>

	<form id="frmOrder" method="post" action="orderComp.jsp">
		<input type="hidden" name="orderUuid"> <input type="hidden" name="orderStatus">
	</form>
	
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