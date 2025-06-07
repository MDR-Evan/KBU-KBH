<%@ page import="java.sql.*, java.text.DecimalFormat"%>
<%@ include file="globalVar.jsp"%>
<%@ include file="dbconn.jsp"%>

<%
DecimalFormat df = new DecimalFormat("###,###");
String sCategoryCd = request.getParameter("categoryCd");
long lTotPrice = 0;

ResultSet rs = null;
PreparedStatement pstmt = null;
try {
   String sql = "SELECT A.CART_UUID, B.PRODUCT_NAME, B.PRODUCT_PRICE, A.QUANTITY " + 
                        "FROM KB_Cart A "+ 
                        "JOIN KB_Product B ON A.PRODUCT_UUID = B.PRODUCT_UUID "+ 
                        "WHERE A.SHOP_UUID = ? AND A.SHOP_DEVICE_ID = ? " + 
                        "ORDER BY A.REG_DT ASC";

   pstmt = conn.prepareStatement(sql);
   pstmt.setString(1, sShopUuid);
   pstmt.setString(2, sShopDeviceId);
   rs = pstmt.executeQuery();

   int itemCount = 0;
   while (rs.next()) {
      String sCartUuid = rs.getString("CART_UUID");
      String sProductName = rs.getString("PRODUCT_NAME");
      long lPrice = rs.getLong("PRODUCT_PRICE");
      int quantity = rs.getInt("QUANTITY");
      long lineTotal = lPrice * quantity;
      lTotPrice += lineTotal;
      itemCount++;
   }
   if (itemCount == 0) {
   }
} catch (SQLException e) {
   out.println("장바구니 조회 오류: " + e.getMessage());
} finally {
   if (rs != null) rs.close();
   if (pstmt != null) pstmt.close();
   if (conn != null) conn.close();
}
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>결제하기</title>
<style>
* {
   box-sizing: border-box;
   font-family: 'Nanum Gothic', sans-serif;
}

.center {
   margin: 0;
   padding: 0;
   background: #fffdf5;
   min-height: 100vh;
   display: flex;
   flex-direction: row;
   align-items: flex-start;
   justify-content: center;
   gap: 32px;
   padding-top: 80px;
}

.login-box {
   background: #fff;
   padding: 36px 28px;
   border-radius: 18px;
   box-shadow: 0 6px 18px rgba(0, 0, 0, 0.09);
   width: 340px;
   height: 420px; /* ✅ 고정 높이 지정 */
   border: 1.5px solid #f4ede5;
   display: flex; /* ✅ 내부 요소를 수직 정렬 */
   flex-direction: column;
   justify-content: space-between;
}

.login-box h1 {
   text-align: center;
   font-size: 26px;
   font-weight: bold;
   letter-spacing: 2px;
   margin-bottom: 18px;
}

.login-box label {
   margin-bottom: 7px;
   color: #333;
   font-weight: bold;
   font-size: 15px;
}

.login-box input[type="text"] {
   width: 100%;
   padding: 11px;
   border: 1.5px solid #eee6d9;
   border-radius: 10px;
   margin-bottom: 18px;
   font-size: 15px;
   background: #fffdf5;
   transition: border 0.2s;
}

.login-box input[type="text"]:focus {
   border-color: #e94826;
   outline: none;
   background: #fff;
}

.login-box input[type="submit"],
.login-box button[type="button"] {
   width: 100%;
   padding: 13px 0;
   border: none;
   border-radius: 10px;
   font-size: 16px;
   font-weight: bold;
   cursor: pointer;
   transition: background 0.22s;
}

.login-box input[type="submit"] {
   background: #e94826;
   color: #fff;
   padding: 16px 0;         /* ✅ 높이 증가 */
   font-size: 18px;         /* ✅ 글자 크기 증가 */
   border-radius: 12px;     /* ✅ 더 둥글게 */
   margin-bottom: 6px;      /* ✅ 간격 조금 줄임 */
}

.login-box input[type="submit"]:hover {
   background: #c33c1d;
}

.login-box form {
   margin-bottom: 3px;       /* ✅ 버튼들 사이 간격 줄이기 */
}

.login-box button[type="button"] {
   width: 100%;
   height: 50%;
   padding: 20px 0; /* ✅ 버튼 높이 증가 */
   background: #22b573;
   color: #fff;
   border: none;
   border-radius: 12px;
   font-size: 20px;  /* ✅ 글자 크기 증가 */
   font-weight: bold;
   cursor: pointer;
   transition: background 0.2s;
   /** margin-top: auto; */ /* ✅ 여유 공간 아래 정렬 */
}

.login-box button[type="button"]:hover {
   background: #149a49;
}

.login-box form {
   margin-bottom: 7px;
}
</style>

</head>
<script>
   function processPayment() {
      if (confirm("결제 하시겠습니까?")) {
         document.getElementById("frmPay").submit();
      }
   }
</script>
<body>
<jsp:include page="header.jsp" flush="true" />
<div class="center">

   <!-- 📦 왼쪽 박스: 포인트 적립 -->
   <div class="login-box">
      <h1>
         <span style="color: #e94826;">포</span> 
         <span style="color: #222;">인</span>
         <span style="color: #22b573;">트</span> 
         <span style="color: #e94826;">적</span>
         <span style="color: #e94826;">립</span>
      </h1>

      <form action="login_confirm.jsp" method="post">
         <label>전화번호</label>
         <input type="text" name="PHONE_NUM"> 
         <input type="hidden" name="shopDeviceId" value="<%=sShopDeviceId%>">
         <input type="hidden" name="categoryCd" value="<%=sCategoryCd%>">
         <input type="submit" value="전화번호로 포인트 적립" />
      </form>

      <form action="register.jsp" method="post">
         <input type="submit" value="회원가입">
      </form>
   </div>

   <!-- 💳 오른쪽 박스: 적립 없이 결제 -->
   <div class="login-box">
      <h1>
         <span style="color: #22b573;">바</span> 
         <span style="color: #e94826;">로</span>
         <span style="color: #222;">결</span> 
         <span style="color: #e94826;">제</span>
      </h1>
      <button type="button" onclick="processPayment()">적립없이 결제</button>
      <form id="frmPay" method="post" action="paySave.jsp">
         <input type="hidden" name="shopDeviceId" value="<%=sShopDeviceId%>">
         <input type="hidden" name="categoryCd" value="<%=sCategoryCd%>">
      </form>
   </div>

</div>
</body>
</html>
