<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*, java.util.*"%>
<%@ include file="globalVar.jsp"%>
<%@ include file="dbconn.jsp"%>
<jsp:include page="header.jsp" />
<jsp:include page="menuMag.jsp" />

<%
String sProductUuid = request.getParameter("productUuid");
Map<String, String> data = new HashMap<>();
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
	String sql = "SELECT CATEGORY_CD, PRODUCT_NAME, PRODUCT_PRICE, PRODUCT_QUANTITY, PRODUCT_DESC, PRODUCT_SORT FROM KB_Product WHERE SHOP_UUID = ? AND PRODUCT_UUID = ?";
	pstmt = conn.prepareStatement(sql);
	pstmt.setString(1, sShopUuid);
	pstmt.setString(2, sProductUuid);
	rs = pstmt.executeQuery();
	if (rs.next()) {
		data.put("categoryCd", rs.getString("CATEGORY_CD"));
		data.put("productName", rs.getString("PRODUCT_NAME"));
		data.put("productPrice", rs.getString("PRODUCT_PRICE"));
		data.put("productQuantity", rs.getString("PRODUCT_QUANTITY"));
		data.put("productDesc", rs.getString("PRODUCT_DESC"));
		data.put("productSort", rs.getString("PRODUCT_SORT"));
	}
} catch (Exception e) {
	e.printStackTrace();
} finally {
	if (rs != null)
		try {
	rs.close();
		} catch (SQLException ignore) {
		}
	if (pstmt != null)
		try {
	pstmt.close();
		} catch (SQLException ignore) {
		}
	if (conn != null)
		try {
	conn.close();
		} catch (SQLException ignore) {
		}
}
%>

<style>
body {
	background: #fdfdfd;
	font-family: 'Arial', sans-serif;
}

h2 {
	text-align: center;
	margin-top: 30px;
	font-size: 1.8rem;
	color: #333;
}

.form-container {
	width: 600px;
	margin: 30px auto;
	padding: 25px 30px;
	background: #ffffff;
	border: 1px solid #ddd;
	border-radius: 12px;
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.form-table {
	width: 100%;
	border-collapse: collapse;
}

.form-table td {
	padding: 12px 8px;
	font-size: 14px;
	vertical-align: top;
}

.form-table input[type="text"], .form-table input[type="number"],
	.form-table select, .form-table textarea {
	width: 100%;
	padding: 8px;
	font-size: 14px;
	border: 1px solid #ccc;
	border-radius: 6px;
}

.form-table textarea {
	resize: vertical;
}

.form-table input[type="button"] {
	margin: 5px;
	padding: 10px 20px;
	font-weight: bold;
	font-size: 14px;
	border: none;
	border-radius: 6px;
	cursor: pointer;
	transition: background-color 0.3s;
}

.form-table input[type="button"]:first-child {
	background-color: #4CAF50;
	color: white;
}

.form-table input[type="button"]:first-child:hover {
	background-color: #43a047;
}

.form-table input[type="button"]:last-child {
	background-color: #888;
	color: white;
}

.form-table input[type="button"]:last-child:hover {
	background-color: #666;
}
</style>

<h2>메뉴 수정</h2>
<div class="form-container">
	<form id="frmProductSave" name="frmProductSave"
		action="productSaveMag.jsp" method="post" onsubmit="return false;">
		<input type="hidden" name="actionMethod" value="U" /> <input
			type="hidden" name="productUuid" value="<%=sProductUuid%>" />
		<table class="form-table">
			<tr>
				<td>카테고리</td>
				<td><select name="categoryCd">
						<option value="">선택</option>
						<option value="01"
							<%="01".equals(data.get("categoryCd")) ? "selected" : ""%>>김밥류</option>
						<option value="02"
							<%="02".equals(data.get("categoryCd")) ? "selected" : ""%>>분식류</option>
						<option value="03"
							<%="03".equals(data.get("categoryCd")) ? "selected" : ""%>>식사류</option>
						<option value="04"
							<%="04".equals(data.get("categoryCd")) ? "selected" : ""%>>돈까스류</option>
				</select></td>
			</tr>
			<tr>
				<td>메뉴명</td>
				<td><input type="text" name="productName"
					value="<%=data.get("productName")%>" /></td>
			</tr>
			<tr>
				<td>가격</td>
				<td><input type="number" name="productPrice"
					value="<%=data.get("productPrice")%>" /></td>
			</tr>
			<tr>
				<td>수량</td>
				<td><input type="number" name="productQuantity"
					value="<%=data.get("productQuantity")%>" /></td>
			</tr>
			<tr>
				<td>설명</td>
				<td><textarea name="productDesc" rows="3"><%=data.get("productDesc")%></textarea></td>
			</tr>
			<tr>
				<td>정렬순서</td>
				<td><input type="text" name="productSort"
					value="<%=data.get("productSort")%>" /></td>
			</tr>
			<tr>
				<td colspan="2" style="text-align: center"><input type="button"
					value="저장" onclick="save();" /> <input type="button" value="목록"
					onclick="location.href='productMag.jsp';" /></td>
			</tr>
		</table>
	</form>
</div>

<script>
	function save() {
		if (!frmChk())
			return;
		document.frmProductSave.submit();
	}
	function frmChk() {
		var f = document.frmProductSave;
		if (f.categoryCd.value == "") {
			alert("카테고리 선택");
			return false;
		}
		if (f.productName.value.trim() == "") {
			alert("상품명 입력");
			return false;
		}
		if (f.productPrice.value.trim() == "") {
			alert("가격 입력");
			return false;
		}
		if (f.productQuantity.value.trim() == "") {
			alert("수량 입력");
			return false;
		}
		if (f.productSort.value.trim() == "") {
			alert("정렬순서 입력");
			return false;
		}
		return true;
	}
</script>
