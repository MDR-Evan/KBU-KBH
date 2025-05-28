<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*, java.text.DecimalFormat" %>
<%@ include file="globalVar.jsp" %>
<%@ include file="dbconn.jsp" %>

<%
DecimalFormat df = new DecimalFormat("###,###");
String sCategoryCd = request.getParameter("categoryCd");
long lTotPrice = 0;
%>

<form id="frmCartDel" method="post" action="cartDel.jsp">
	<input type="hidden" name="shopDeviceId" value="<%=sShopDeviceId%>">
	<input type="hidden" name="categoryCd" value="<%=sCategoryCd%>">
	<input type="hidden" name="cartUuid" value="">
	<input type="hidden" name="processType" value="">
</form>

<dialog id="pointDialog">
  <p>포인트 적립하시겠습니까?</p>
  <menu>
    <button id="yesBtn">적립할래요</button>
    <button id="noBtn">괜찮아요</button>
  </menu>
</dialog>

<form id="frmPay" method="post" action="paySave.jsp">
	<input type="hidden" name="shopDeviceId" value="<%=sShopDeviceId%>">
	<input type="hidden" name="categoryCd" value="<%=sCategoryCd%>">
</form>

<form id="frmPoint" method="post" action="point.jsp">
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
	function processPayment() {
		if (confirm("결제 하시겠습니까?")) {
			document.getElementById("frmPoint").submit();
		}
	}
	/* function processPoint() {
		  const dlg = document.getElementById('pointDialog');
		  dlg.showModal();
		  
		  const yes = document.getElementById('yesBtn');
		  const no  = document.getElementById('noBtn');

		  const cleanUp = () => {
		    yes.removeEventListener('click', onYes);
		    no.removeEventListener('click', onNo);
		    dlg.close();
		  };

		  function onYes() {
		    cleanUp();
		    document.getElementById('frmPoint').submit();
		  }

		  function onNo() {
		    cleanUp();
		    processPayment();
		  }

		  yes.addEventListener('click', onYes);
		  no.addEventListener('click', onNo);
		}
	*/
	function processPoint() {
		if (confirm("결제 하시겠습니까?")) {
			document.getElementById("frmPay").submit();
		}
	}
</script>

<div class="cart-section">
	<ul class="cart-list">
	<%
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

		int itemCount = 0;
		while (rs.next()) {
			String sCartUuid = rs.getString("CART_UUID");
			String sProductName = rs.getString("PRODUCT_NAME");
			long lPrice = rs.getLong("PRODUCT_PRICE");
			int quantity = rs.getInt("QUANTITY");
			long lineTotal = lPrice * quantity;
			lTotPrice += lineTotal;
	%>
		<li class="cart-item">
			<span><%=sProductName%></span>
			<div class="cart-control">
				<!-- 수량 감소 -->
				<form method="post" action="cartDel.jsp" style="display:inline;">
					<input type="hidden" name="processType" value="U-" />
					<input type="hidden" name="cartUuid" value="<%=sCartUuid%>" />
					<input type="hidden" name="categoryCd" value="<%=sCategoryCd%>" />
					<button type="submit">-</button>
				</form>
				<span><%=quantity%>개</span>
				<!-- 수량 증가 -->
				<form method="post" action="cartDel.jsp" style="display:inline;">
					<input type="hidden" name="processType" value="U+" />
					<input type="hidden" name="cartUuid" value="<%=sCartUuid%>" />
					<input type="hidden" name="categoryCd" value="<%=sCategoryCd%>" />
					<button type="submit">+</button>
				</form>
				<!-- 삭제 버튼 -->
				<button type="button" onclick="delCart('<%=sCartUuid%>')">삭제</button>
			</div>
			<span>&#8361; <%=df.format(lineTotal)%></span>
		</li>
	<%
			itemCount++;
		}
		if (itemCount == 0) {
	%>
		<li class="cart-item">장바구니에 담긴 상품이 없습니다.</li>
	<%
		}
	} catch (SQLException e) {
		out.println("장바구니 조회 오류: " + e.getMessage());
	} finally {
		if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
		if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
		if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
	}
	%>
	</ul>

	<div class="cart-total">
		<p>총 결제 금액: <strong>&#8361; <%=df.format(lTotPrice)%></strong></p>
	</div>

	<div class="cart-actions">
		<button type="button" onclick="delCartAll()">전체 취소</button>
		<!--  <button type="button" onclick="processPayment()">결제</button> -->
		<!-- <button type="button" onclick="processPoint()">결제</button> -->
		<form action="point.jsp" method="post">
			<button type="button" onclick="processPayment()">결제</button>
		</form>
	</div>
</div>
