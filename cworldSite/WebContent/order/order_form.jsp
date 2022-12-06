<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<%@ include file="../_inc/inc_header.jsp" %>
<%
if(!isLogin){
	out.println("<script>");
	out.println("alert('잘못된 경로로 들어오셨습니다.'); history.back();");
	out.println("</script>");
	out.close();	
}
request.setCharacterEncoding("utf-8");
ArrayList<OrderCart> buyList = (ArrayList<OrderCart>)request.getAttribute("buyList");
ArrayList<MemberAddr> addrList = (ArrayList<MemberAddr>)request.getAttribute("addrList");
int mipoint = (int)request.getAttribute("mipoint");

if(!isLogin || buyList.size() == 0 || addrList.size() == 0){
// 로그인이 안됐거나, 구매할 상품이 없거나, 배송지 정보가 없으면
	out.println("<script> alert('잘못된 경로로 들어오셨습니다.'); history.back(); </script>");
	out.close();	
}

%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script>
function chkJVal(fr){
	var name = fr.oi_rname.value;
	var p1 = fr.p2.value;
	var p2 = fr.p3.value;
	var zip = fr.oi_rzip.value;
	var addr1 = fr.oi_raddr1.value;
	var payment = fr.oi_payment.value;
	if (name.length < 2){		alert('이름을 확인하세요.');		return false;	}
	if (p1.length < 3 || p2.length < 3){ alert('전화번호를 확인하세요.');		return false; }
	if (zip.length != 5 || addr1.length < 2){ alert('주소를 확인하세요.');		return false; }
	if (payment == null || payment == ""){  alert('결제방법을 선택하세요.');		return false;  }
		return true;
}
function chAddr(val){
	var frm = document.frmOrder;
	var arr = val.split("|");
	frm.oi_rname.value = arr[0];
	frm.p1.value = arr[1];
	frm.p2.value = arr[2];
	frm.p3.value = arr[3];
	frm.oi_rzip.value = arr[4];
	frm.oi_raddr1.value = arr[5];
	frm.oi_raddr2.value = arr[6];
}
$(document).ready(function(){
	$("#upoint").change(function(){
		$("#upoint").val($("#upoint").val().replace(/[^0-9]/g,''));
		if ($("#upoint").val() > <%=mipoint %>){
			$("#upoint").val(<%=mipoint %>);
		}
		$("#uPointView").html($("#upoint").val());
		$("#orderPrice").html($("#total").html() - $("#upoint").val());
	});
});
</script>
</head>
<body>
<div class="content" align="center">
<h2>대여 및 판매 상품 주문</h2>
<table width="800" cellpadding="5" border="1">
<tr align="center"><td>상품이미지</td><td>상품명</td><td>구매/대여</td><td>옵션</td><td>수량</td><td>가격</td><td>배송료</td></tr>
<%	
String ocidxs = "";
int total = 0; // 총 구매가격의 누적치를 저장할 변수
int totalP = 0;	// 총 상품가격
int totalD = 0;	// 총 배송비용
for (int i = 0 ; i < buyList.size(); i++){ 
	OrderCart oc = buyList.get(i);
	int ocidx = oc.getOc_idx();
	ocidxs += "," + ocidx;
	int realPrice = oc.getPi_price() * oc.getOc_cnt();
	int dfeeByCnt = oc.getPi_dfee() * oc.getOc_cnt();
	if (oc.getPi_dc() > 0){
		realPrice = (oc.getPi_price()*(100 - oc.getPi_dc())/100) * oc.getOc_cnt();
	}
	String optName = "";
	String rentOrBuy = "구매";
	  if(oc.getPs_opt().equals("a"))  		optName = "빨강";
	  else if(oc.getPs_opt().equals("b"))	optName = "파랑";
	  else if(oc.getPs_opt().equals("c"))	optName = "검정";
	  else if(oc.getPs_opt().equals("d"))	optName = "텐트 외 상품";
	  else {
		  realPrice = realPrice/2 * oc.getOcr_period();
		  optName = "(" + oc.getOcr_sdate() + " ~ " + oc.getOcr_edate() + ")" +
		  "<br/>" + oc.getOcr_period() + "박" + (oc.getOcr_period() + 1) + "일";
		  rentOrBuy = "대여";
		  
	  }
%>
<tr align="center">
<%
   String pdtImg = oc.getPi_img1();
   if (oc.getPs_opt().equals("b")) pdtImg = pdtImg.substring(0, 6) + 2 + pdtImg.substring(7);
   else if (oc.getPs_opt().equals("c")) pdtImg = pdtImg.substring(0, 6) + 3 + pdtImg.substring(7);%>
<td width="15%"><img src="pdt_img/<%=pdtImg %>" width="100" height="100"/></td>
<td width="15%"><%=oc.getPi_name()%></td>
<td width="10%"><%=rentOrBuy %></td>
<td width="20%"><%=optName %></td>
<td width="5%"><%=oc.getOc_cnt() %></td>
<td width="10%"><%=realPrice %>원</td>
<td width="10%"><%=dfeeByCnt%>원</td>
</tr>
<%		totalP += realPrice;
		totalD += dfeeByCnt; 
		total = totalP + totalD; 
} 
ocidxs = (ocidxs.indexOf(',') >= 0 ? ocidxs.substring(1) : ocidxs);
%>
</table>
<br/><p align="center" style="width:500px; font-size:20px;">
선택상품 금액&nbsp;&nbsp;&nbsp;+&nbsp;&nbsp;&nbsp;총 배송비&nbsp;&nbsp;&nbsp;=&nbsp;&nbsp;&nbsp;주문금액
<br> <%=totalP %>원&nbsp;&nbsp;&nbsp;+&nbsp;&nbsp;&nbsp;<%=totalD %>원&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;<%=total %>원 </p><br/><br/><br/>
<hr/>
<h2>배송지 정보</h2>
<form name="frmOrder" action="order_proc_in" method="post" onsubmit="return chkJVal(this);">
<input type="hidden" name="total" value="<%=total %>" />
<input type="hidden" name="kind" value="<%=request.getParameter("kind") %>" />
<input type="hidden" name="piid" value="<%=request.getParameter("piid") %>" />
<input type="hidden" name="opt" value="<%=request.getParameter("opt") %>" />
<input type="hidden" name="ocidxs" value="<%=ocidxs %>" />
<input type="hidden" name="ps_idx" value="<%=buyList.get(0).getPs_idx() %>" />
<input type="hidden" name="baro_cnt" value="<%=buyList.get(0).getOc_cnt() %>" />
<input type="hidden" name="period" value="<%=buyList.get(0).getOcr_sdate()%> ~ <%=buyList.get(0).getOcr_edate()%>"/>


<table width="800" cellpadding="5">
<tr height="50"><th width="30%" align="center">배송지 선택</th>
<td width="*">
	<select onchange="chAddr(this.value);">
<%
String rname = "", zip = "", addr1 = "", addr2 = "";
String[] phone = new String[3];
for (int i = 0; i < addrList.size() ; i++ ){
	MemberAddr ma = addrList.get(i);
	if ( i == 0){
		rname = ma.getMa_receiver();
		phone = ma.getMa_phone().split("-");
		zip = ma.getMa_zip();
		addr1 = ma.getMa_addr1();
		addr2 = ma.getMa_addr2();
	}
	String tmp = ma.getMa_receiver() + "|" + ma.getMa_phone().replace('-','|');
	tmp += "|" + ma.getMa_zip() + "|" + ma.getMa_addr1() + "|" + ma.getMa_addr2();
	
	out.println("<option value = \"" + tmp + "\">");
	out.println(ma.getMa_name() + " - " + ma.getMa_addr1() + " " + ma.getMa_addr2());
	out.println("</option>");
}
%>
	</select>
</td>
</tr>
<tr height="50">
<th >수취인명</th><td><input type="text" name="oi_rname" size="12" value="<%=rname %>" /></td>
</tr>
<tr height="50"><th>전화번호</th>
<td >
	<select name="p1">
		<option value="010" <%if(phone[0].equals("010")){%> selected="selected" <% } %>>010</option>
		<option value="011" <%if(phone[0].equals("011")){%> selected="selected" <% } %>>011</option>
		<option value="016" <%if(phone[0].equals("016")){%> selected="selected" <% } %>>016</option>
		<option value="019" <%if(phone[0].equals("019")){%> selected="selected" <% } %>>019</option>	
	</select> -
	<input type="text" name="p2" value="<%=phone[1] %>" onkeyup="onlyNum(this);" size="1" maxlength="4"/>
	- <input type="text" name="p3" value="<%=phone[2] %>" onkeyup="onlyNum(this);" size="1" maxlength="4"/>
</td>
</tr>
<tr height="50">
<th>우편번호</th><td><input type="text" name="oi_rzip" value="<%=zip %>" size="2" maxlength="5"/></td>
</tr>
<tr height="50">
<th rowspan="2">주소</th><td>	<input type="text" name="oi_raddr1" size="60" value="<%=addr1 %>" /></td>
</tr>
<tr height="50">
<td><input type="text" name="oi_raddr2" size="60" value="<%=addr2 %>" /></td>
</tr>
<tr>
<th>택배 메모</th>
<td><br/><textarea name="oi_memo" placeholder="배송시 요청사항을 입력해주세요."></textarea><br/></td>
</tr>
</table>
<br/><br/><br/>
<h2>결제 정보</h2>
<table width="800" cellpadding="5" border="1">
<tr align="center" height="50">
<td width="35%">총 추문 금액</td><td width="30%">소모 포인트</td><td width="30%">총 결제예정금액</td>
</tr>
<tr align="center" height="50"><td><span id="total"><%=total %></span> 원 </td>
<td><span id="uPointView">0</span> pt</td>
<td><span id="orderPrice"><%=total %></span> 원</td></tr>
<tr align="center">
	<td width="100%" height="50" colspan="3" align="center">
	포인트 사용 : <input type="text" name="upoint" id="upoint" style="text-align:right" value="0"/>pt
	(보유 포인트 :<%=mipoint %> pt )</td>
</tr>
<tr>
<td colspan="3" align="center" height="50">적립 예정 포인트 : <%=total/100*2 %> pt(총 주문금액의 2%)</td>
<input type="hidden" name="spoint" value="<%=total/100*2 %>"/>
</tr>
<tr  align="center"><td colspan="3">( 포인트 사용시 주의사항) </td></tr>
<tr><td colspan="3" align="center">결제 방법<br/><br/>
	<input type="radio" name="oi_payment" value="a" id="payA"/> 
	<label for="payA"> 카드 결제 </label> &nbsp;&nbsp;&nbsp;
	<input type="radio" name="oi_payment" value="b" id="payB"/>
	<label for="payB"> 휴대폰 결제 </label> &nbsp;&nbsp;&nbsp;
	<input type="radio" name="oi_payment" value="c" id="payC"/>
	<label for="payC"> 무통장 입금 </label><br/>
</td></tr>

</table>
<br/>
<p style="width:800px; text-align:center;">
	<input type="submit" value="결제하기"/>
	<br/><br/>
</p>
</form>
</div>
</body>
</html>
<%@ include file="../_inc/inc_footer.jsp" %>