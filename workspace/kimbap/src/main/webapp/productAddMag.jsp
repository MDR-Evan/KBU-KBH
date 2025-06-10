<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="globalVar.jsp"%>
<jsp:include page="header.jsp" />

<head>
<meta charset="UTF-8">
<title>메뉴 등록</title>
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
    margin: 35px 0 28px 0;
    font-size: 2rem;
    font-weight: bold;
    color: #e74c3c;
}
/* 폼 전체를 감싸는 영역 */
.form-container {
    width: 90%;
    max-width: 600px;
    margin: 0 auto 40px auto;
    padding: 32px 28px 22px 28px;
    background-color: #fff;
    border-radius: 10px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.13);
}

/* 테이블 폼 스타일 */
.form-table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0 13px; /* 줄 간격 */
    font-size: 1rem;
}
.form-table td {
    padding: 8px 6px;
    vertical-align: middle;
}
.form-table td:first-child {
    width: 120px;
    font-weight: bold;
    text-align: right;
    color: #444;
    background: none;
}
.form-table input[type="text"],
.form-table input[type="number"],
.form-table select,
.form-table textarea {
    width: 95%;
    padding: 9px 10px;
    border: 1.5px solid #e0e0e0;
    border-radius: 6px;
    font-size: 1rem;
    background-color: #faf7f2;
    transition: border 0.2s;
}
.form-table input:focus,
.form-table select:focus,
.form-table textarea:focus {
    outline: none;
    border: 1.5px solid #e74c3c;
    background-color: #fff8f6;
}
.form-table textarea {
    resize: vertical;
    min-height: 50px;
    font-family: inherit;
}

/* 버튼 스타일 */
.form-table input[type="button"] {
    color: #fff;
    padding: 11px 30px;
    margin: 0 8px;
    border: none;
    border-radius: 6px;
    font-size: 1rem;
    font-weight: bold;
    cursor: pointer;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    transition: background 0.23s;
}
.form-table input[type="button"]:first-child {
    background-color: #e74c3c; /* 저장: 빨강 */
}
.form-table input[type="button"]:first-child:hover {
    background-color: #c0392b;
}
.form-table input[type="button"]:last-child {
    background-color: #bababa; /* 취소: 회색 */
}
.form-table input[type="button"]:last-child:hover {
    background-color: #7f8c8d;
}
@media (max-width: 700px) {
    .form-container {
        padding: 15px 4px 16px 4px;
    }
    .form-table td {
        font-size: 0.96rem;
        padding: 7px 3px;
    }
}
</style>
</head>
<body>
    <h2 class="page-title">메뉴 등록</h2>
    <div class="form-container">
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
            <tr>
                <td>메뉴명</td>
                <td><input type="text" name="productName" /></td>
            </tr>
            <tr>
                <td>가격</td>
                <td><input type="number" name="productPrice" /></td>
            </tr>
            <tr>
                <td>수량</td>
                <td><input type="number" name="productQuantity" value="100" /></td>
            </tr>
            <tr>
                <td>설명</td>
                <td><textarea name="productDesc" rows="3" cols="30"></textarea></td>
            </tr>
            <tr>
                <td>정렬순서</td>
                <td><input type="text" name="productSort" placeholder="예: 01, 02" /></td>
            </tr>
            <tr>
                <td colspan="2" style="text-align:center; padding-top:15px;">
                    <input type="button" value="저장" onclick="save();" />
                    <input type="button" value="취소" onclick="history.back();" />
                </td>
            </tr>
        </table>
    </form>
    </div>
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
</body>
