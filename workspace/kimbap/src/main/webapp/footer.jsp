<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*, java.text.DecimalFormat" %>
<%@ include file="globalVar.jsp" %>
<%@ include file="dbconn.jsp" %>

<%
DecimalFormat df = new DecimalFormat("###,###");
String sCategoryCd = request.getParameter("categoryCd");
long lTotPrice = 0;
int totalQuantity = 0; // 전체 상품 수량을 저장할 변수 추가
%>

<form id="frmCartDel" method="post" action="cartDel.jsp">
	<input type="hidden" name="shopDeviceId" value="<%=sShopDeviceId%>">
	<input type="hidden" name="categoryCd" value="<%=sCategoryCd%>">
	<input type="hidden" name="cartUuid" value="">
	<input type="hidden" name="processType" value="">
</form>

<form id="frmPay" method="post" action="point.jsp">
	<input type="hidden" name="shopDeviceId" value="<%=sShopDeviceId%>">
	<input type="hidden" name="categoryCd" value="<%=sCategoryCd%>">
</form>

<script>
	function delCart(cartUuid) {
		const frm = document.getElementById("frmCartDel");
		frm.processType.value = "P";
		frm.cartUuid.value = cartUuid;
		frm.submit();
	}
	function delCartAll() {
		const frm = document.getElementById("frmCartDel");
		frm.processType.value = "A";
		frm.submit();
	}
	function processPayment(currentTotalPrice) {
	    if (currentTotalPrice <= 0) {
	        alert("장바구니에 상품을 담아주세요.");
	        return false;
	    }
	    if (confirm("결제 하시겠습니까?")) {
	      document.getElementById("frmPay").submit();
	    }
	    // submit()이 호출되지 않는 경우를 위해 false를 반환할 수 있습니다 (선택 사항)
	    // return false; 
	  }
</script>

<div class="cart-wrapper">
  <div class="cart-left">
    <ul class="cart-list">
      <%
        int itemLineCount = 0; // 상품 라인 수를 위한 변수 (기존 itemIndex 역할)
        boolean hasItem = false;
        ResultSet rs = null;
        PreparedStatement pstmt = null;
        try {
          String sql = "SELECT A.CART_UUID, B.PRODUCT_NAME, B.PRODUCT_PRICE, A.QUANTITY " +
                       "FROM KB_Cart A " +
                       "JOIN KB_Product B ON A.PRODUCT_UUID = B.PRODUCT_UUID " +
                       "WHERE A.SHOP_UUID = ? AND A.SHOP_DEVICE_ID = ? " +
                       "ORDER BY A.REG_DT ASC";
          pstmt = conn.prepareStatement(sql);
          pstmt.setString(1, sShopUuid);
          pstmt.setString(2, sShopDeviceId);
          rs = pstmt.executeQuery();
          while (rs.next()) {
            hasItem = true;
            itemLineCount++; // 상품 라인 수 증가
            String sCartUuid = rs.getString("CART_UUID");
            String sProductName = rs.getString("PRODUCT_NAME");
            long lPrice = rs.getLong("PRODUCT_PRICE");
            int quantity = rs.getInt("QUANTITY");
            long lineTotal = lPrice * quantity;
            lTotPrice += lineTotal;
            totalQuantity += quantity; // 각 상품의 수량을 전체 수량에 더함
      %>
        <li class="cart-item">
          <div class="index"><%= itemLineCount %>.</div>
          <div class="product-name"><strong><%= sProductName %></strong></div>
          <div class="cart-control">
            <form method="post" action="cartDel.jsp">
              <input type="hidden" name="shopDeviceId" value="<%=sShopDeviceId%>">
              <input type="hidden" name="processType" value="U-" />
              <input type="hidden" name="cartUuid" value="<%= sCartUuid %>" />
              <input type="hidden" name="categoryCd" value="<%= sCategoryCd %>" />
              <button type="submit" class="qty-button minus">-</button>
            </form>

            <span class="quantity"><strong><%= quantity %></strong></span>

            <form method="post" action="cartDel.jsp">
              <input type="hidden" name="shopDeviceId" value="<%=sShopDeviceId%>">
              <input type="hidden" name="processType" value="U+" />
              <input type="hidden" name="cartUuid" value="<%= sCartUuid %>" />
              <input type="hidden" name="categoryCd" value="<%= sCategoryCd %>" />
              <button type="submit" class="qty-button plus">+</button>
            </form>

            <span class="price"><%= df.format(lineTotal) %>원</span>
          </div>
        </li>
      <%
          }
          if (!hasItem) {
      %>
        <li class="cart-item empty">
          <span class="empty-icon">🛒</span>
          <span class="empty-text">메뉴를 담아주세요!</span>
        </li>
      <%
          }
        } catch (SQLException e) {
          out.println("장바구니 오류: " + e.getMessage());
        } finally {
          if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
          if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
          if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
      %>
    </ul>
  </div>

  <div class="cart-right">
    <button class="delete-all" onclick="delCartAll()">전체 삭제</button>
    <div class="divider"></div>
    <div class="item-count"><strong>선택한 상품:</strong> <%= totalQuantity %>개</div>
    <div class="total-section">
      <button class="pay-button" onclick="processPayment()">
        💳 <%= df.format(lTotPrice) %>원
      </button>
    </div>
  </div>
</div>
