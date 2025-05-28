<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
  #menuArea {
    background-color: #cc0000;
    padding: 10px 0;
    text-align: center;
  }
  #menuArea ul {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
    justify-content: center;
    gap: 30px;
  }
  #menuArea li {
    display: inline-block;
  }
  #menuArea a {
    color: white;
    text-decoration: none;
    font-weight: bold;
    padding: 10px 15px;
    transition: background-color 0.3s;
  }
  #menuArea a:hover {
    background-color: #ff9900;
    border-radius: 5px;
  }
</style>

<nav id="menuArea">
  <ul>
    <li><a href="index.jsp">주문 페이지</a></li>
    <li><a href="orderMag.jsp">주문 관리</a></li>
    <li><a href="productMag.jsp">상품 관리</a></li>
    <li><a href="salesStatus.jsp">매출 현황</a></li>
  </ul>
</nav>
