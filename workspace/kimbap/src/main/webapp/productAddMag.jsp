<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="globalVar.jsp"%>
<jsp:include page="header.jsp" />

<h2>메뉴 등록</h2>
<form id="frmProductSave" name="frmProductSave" action="productSaveMag.jsp" method="post" onsubmit="return false;">
	<input type="hidden" name="actionMethod" value="I" />
	<table class="form-table">
		<tr>
			<td>카테고리</td>
			<td>
				<select name="categoryCd">
					<option value="">선택</option>
					<option value="01">김밥류</option>
					<option value="02">분식류</option>
					<option value="03">식사류</option>
					<option value="04">돈까스류</option>
				</select>
			</td>
		</tr>
		<tr><td>메뉴명</td><td><input type="text" name="productName" /></td></tr>
		<tr><td>가격</td><td><input type="number" name="productPrice" /></td></tr>
		<tr><td>수량</td><td><input type="number" name="productQuantity" value="100" /></td></tr>
		<tr><td>설명</td><td><textarea name="productDesc" rows="3" cols="30"></textarea></td></tr>
		<tr><td>정렬순서</td><td><input type="text" name="productSort" placeholder="예: 01, 02" /></td></tr>
		<tr>
			<td colspan="2" style="text-align: center">
				<input type="button" value="저장" onclick="save();" />
				<input type="button" value="취소" onclick="history.back();" />
			</td>
		</tr>
	</table>
</form>

<script>
	function save() {
		var f = document.frmProductSave;
		if (!frmChk()) return;
		f.submit();
	}
	function frmChk() {
		var f = document.frmProductSave;
		if (f.categoryCd.value == "") { alert("카테고리를 선택하세요."); return false; }
		if (f.productName.value.trim() == "") { alert("메뉴명을 입력하세요."); return false; }
		if (f.productPrice.value.trim() == "") { alert("가격을 입력하세요."); return false; }
		if (f.productQuantity.value.trim() == "") { alert("수량을 입력하세요."); return false; }
		if (f.productSort.value.trim() == "") { alert("정렬순서를 입력하세요."); return false; }
		return true;
	}
</script>

<jsp:include page="footer.jsp" />
