<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="globalVar.jsp" %> 
<%@ include file="dbconn.jsp" %>
<%@ page import="java.sql.*" %>

<%
    // ────────────────────────────────────────────
    // 1) 결제 후 이 페이지를 호출할 때, PHONE_NUM 파라미터가 반드시 넘어와야 함
    // ────────────────────────────────────────────
    String phone = request.getParameter("PHONE_NUM");
    if (phone == null || phone.trim().isEmpty()) {
        // PHONE_NUM 파라미터가 없으면 포인트 적립을 할 수 없으므로, 바로 오류 처리
        out.println("<script>alert('전화번호 정보가 전달되지 않았습니다.'); location.href='product.jsp';</script>");
        return;
    }

    // ────────────────────────────────────────────
    // 2) 포인트 적립 팝업 제어 변수
    // ────────────────────────────────────────────
    boolean showPopup   = false;
    long    pointAmount = 0L;

    // ────────────────────────────────────────────
    // 3) 주문 관련 변수 선언
    // ────────────────────────────────────────────
    ResultSet        rs     = null;
    PreparedStatement pstmt = null;

    String sOrderUuid   = "";
    int    iMasterResult  = 0;
    int    iItemResult    = 0;
    int    iCartDelResult = 0;
    long   iTotalPrice    = 0;

    try {
        // ────────────────────────────────────────────
        // 4) 주문 UUID 생성 (SYS_GUID)
        // ────────────────────────────────────────────
        String keySql = "SELECT SYS_GUID() AS UUID FROM DUAL";
        pstmt = conn.prepareStatement(keySql);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            sOrderUuid = rs.getString("UUID");
        }
        rs.close();
        pstmt.close();

        // ────────────────────────────────────────────
        // 5) 장바구니에서 합계 금액(iTotalPrice) 가져오기
        //    ─ A. SUM(B.PRODUCT_PRICE * A.QUANTITY)
        //    ─ B. A.SHOP_UUID, A.SHOP_DEVICE_ID 필터링
        // ────────────────────────────────────────────
        String totPriceSql =
          "SELECT NVL(SUM(B.PRODUCT_PRICE * A.QUANTITY), 0) AS TOT_PRICE " +
          "  FROM KB_Cart A " +
          " INNER JOIN KB_Product B " +
          "    ON A.PRODUCT_UUID = B.PRODUCT_UUID AND A.SHOP_UUID = B.SHOP_UUID " +
          " WHERE A.SHOP_UUID = ? AND A.SHOP_DEVICE_ID = ?";
        pstmt = conn.prepareStatement(totPriceSql);
        pstmt.setString(1, sShopUuid);
        pstmt.setString(2, sShopDeviceId);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            iTotalPrice = rs.getLong("TOT_PRICE");
        }
        rs.close();
        pstmt.close();

        if (iTotalPrice <= 0) {
            out.println("<script>alert('장바구니에 담긴 상품이 없습니다.'); history.back();</script>");
            return;
        }

        // ────────────────────────────────────────────
        // 6) 주문 마스터 등록 (KB_Order_Master)
        // ────────────────────────────────────────────
        String masterSql =
          "INSERT INTO KB_Order_Master (SHOP_UUID, ORDER_UUID, ORDER_STATUS, TOT_PRICE, REG_DT) " +
          "VALUES (?, ?, 'PC', ?, SYSDATE)";
        pstmt = conn.prepareStatement(masterSql);
        pstmt.setString(1, sShopUuid);
        pstmt.setString(2, sOrderUuid);
        pstmt.setLong(3, iTotalPrice);
        iMasterResult = pstmt.executeUpdate();
        pstmt.close();

        if (iMasterResult > 0) {
            // ────────────────────────────────────────────
            // 7) 주문 상세(아이템) 등록 (KB_Order_Item)
            // ────────────────────────────────────────────
            String itemSql =
              "INSERT INTO KB_Order_Item " +
              "  (ORDER_ITEM_UUID, SHOP_UUID, ORDER_UUID, PRODUCT_UUID, QUANTITY, PRICE, REG_DT) " +
              "SELECT SYS_GUID(), A.SHOP_UUID, ?, A.PRODUCT_UUID, A.QUANTITY, B.PRODUCT_PRICE, SYSDATE " +
              "  FROM KB_Cart A " +
              " INNER JOIN KB_Product B " +
              "    ON A.PRODUCT_UUID = B.PRODUCT_UUID AND A.SHOP_UUID = B.SHOP_UUID " +
              " WHERE A.SHOP_UUID = ? AND A.SHOP_DEVICE_ID = ?";
            pstmt = conn.prepareStatement(itemSql);
            pstmt.setString(1, sOrderUuid);
            pstmt.setString(2, sShopUuid);
            pstmt.setString(3, sShopDeviceId);
            iItemResult = pstmt.executeUpdate();
            pstmt.close();

            // ────────────────────────────────────────────
            // 8) 재고 차감 (KB_Product 테이블)
            // ────────────────────────────────────────────
            String updateSql =
              "UPDATE KB_Product A SET A.PRODUCT_QUANTITY = A.PRODUCT_QUANTITY - " +
              "  (SELECT B.QUANTITY FROM KB_Cart B " +
              "   WHERE B.SHOP_UUID = ? AND B.SHOP_DEVICE_ID = ? AND A.PRODUCT_UUID = B.PRODUCT_UUID) " +
              "WHERE EXISTS (SELECT 1 FROM KB_Cart B " +
              "               WHERE B.SHOP_UUID = ? AND B.SHOP_DEVICE_ID = ? AND A.PRODUCT_UUID = B.PRODUCT_UUID)";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setString(1, sShopUuid);
            pstmt.setString(2, sShopDeviceId);
            pstmt.setString(3, sShopUuid);
            pstmt.setString(4, sShopDeviceId);
            pstmt.executeUpdate();
            pstmt.close();
        }

        if (iItemResult > 0) {
            // ────────────────────────────────────────────
            // 9) 장바구니 비우기 (KB_Cart 테이블)
            // ────────────────────────────────────────────
            String cartDelSql = 
              "DELETE FROM KB_Cart WHERE SHOP_UUID = ? AND SHOP_DEVICE_ID = ?";
            pstmt = conn.prepareStatement(cartDelSql);
            pstmt.setString(1, sShopUuid);
            pstmt.setString(2, sShopDeviceId);
            iCartDelResult = pstmt.executeUpdate();
            pstmt.close();
        }

        // ────────────────────────────────────────────
        // 10) 주문 성공 시 알림창 → 포인트 적립 준비
        // ────────────────────────────────────────────
        if (iItemResult > 0 && iCartDelResult > 0) {
            //out.println("<script>alert('주문이 정상적으로 완료되었습니다.');</script>");

            // (10-1) 포인트 적립 비율: 총합의 1% 예시
            long calculatedPoints = iTotalPrice / 100L;
            pointAmount = calculatedPoints;

            // (10-2) 사용자 PHONE_NUM 이 파라미터로 넘어왔으므로,
            //        이 값을 이용해 USERS 테이블에 포인트 적립
            String pointSql =
              "UPDATE USERS SET POINT = NVL(POINT,0) + ? WHERE PHONE_NUM = ?";
            pstmt = conn.prepareStatement(pointSql);
            pstmt.setLong(1, calculatedPoints);
            pstmt.setString(2, phone);
            int updatedRows = pstmt.executeUpdate();
            pstmt.close();

            // ────────────────────────────────────────────
            // 10-3) 디버깅: 업데이트된 행(row) 수 확인
            // ────────────────────────────────────────────
            out.println("<script>console.log('DEBUG: updatedRows = ' + " + updatedRows + ");</script>");

            if (updatedRows > 0) {
                // 포인트 적립 팝업 표시
                showPopup = true;
            } else {
                // (만약 phone 값이 USERS에 존재하지 않으면)
                out.println("<script>alert('포인트 적립 대상이 없습니다. 전화번호=" + phone + "');</script>");
            }
        }
    } catch (SQLException ex) {
        out.println("SQLException: " + ex.getMessage());
        ex.printStackTrace();
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn  != null) try { conn.close(); } catch (Exception e) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>주문 및 포인트 적립 결과</title>
  <style>
    /* 팝업 박스 CSS */
    #pointPopup {
      position: fixed;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      background-color: rgba(0, 0, 0, 0.8);
      color: #fff;
      padding: 20px 30px;
      font-size: 18px;
      border-radius: 8px;
      text-align: center;
      z-index: 1000;
      display: none;
    }
  </style>
  <script>
    function showPointPopup(point) {
      var popup = document.getElementById('pointPopup');
      if (!popup) return;
      popup.innerText = point + "포인트가 적립되었습니다.";
      popup.style.display = 'block';
      // 3초 후 팝업 숨긴 뒤 리다이렉트
      setTimeout(function() {
        popup.style.display = 'none';
        document.redirectForm.submit();
      }, 3000);
    }
  </script>
</head>

<body<% if (showPopup) { %> onload="showPointPopup(<%= pointAmount %>);"<% } %>>
  <!-- 화면 중앙에 뜨는 ‘포인트 적립 완료’ 팝업 -->
  <div id="pointPopup"></div>

  <!-- 3초 후 product.jsp 로 넘어가기 위한 폼 -->
  <form id="redirectForm" name="redirectForm" action="product.jsp" method="post">
    <input type="hidden" name="categoryCd" value="01" />
  </form>
</body>
</html>
