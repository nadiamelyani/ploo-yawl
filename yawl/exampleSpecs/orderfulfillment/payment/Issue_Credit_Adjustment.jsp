<%@ page import="org.yawlfoundation.orderfulfilment.issue_credit_adjustment.*"%>
<%@ page import="org.jdom2.Element" %>
<%@ page import="org.yawlfoundation.yawl.resourcing.rsInterface.WorkQueueGatewayClient" %>
<%@ page import="org.yawlfoundation.yawl.util.*" %>
<%@ page import="com.sun.org.apache.xerces.internal.jaxp.datatype.XMLGregorianCalendarImpl" %>
<%@ page import="java.math.BigInteger" %>
<%@ page import="javax.xml.bind.*" %>
<%@ page import="javax.xml.stream.*" %>
<%@ page import="javazoom.upload.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page buffer="1024kb" %>

<%

//-------------------------online code-------------------------//
	String itemid = request.getParameter("workitem");
	String handle = request.getParameter("handle");
	String url = "http://localhost:8080/resourceService/workqueuegateway";
	WorkQueueGatewayClient client = new WorkQueueGatewayClient(url);

	String wir = (String) session.getAttribute("wir");
	if (wir == null) {
		wir = client.getWorkItem(itemid, handle);
		session.setAttribute("wir", wir);
	}

	String source = (String) session.getAttribute("source");
    if (source == null) {
        session.setAttribute("source", request.getParameter("source"));
    }

	String xml = (String) wir.substring(wir.indexOf("<updateddata>")+13, wir.indexOf("</updateddata>"));
	if(xml.length()==0){
		xml = (String) wir.substring(wir.indexOf("<data>")+6,wir.indexOf("</data>"));
	}
	xml = xml.replaceAll("<Issue_Credit_Adjustment", "<ns2:Issue_Credit_Adjustment xmlns:ns2='http://www.yawlfoundation.org/OrderFulfilment/Issue_Credit_Adjustment'");
	xml = xml.replaceAll("</Issue_Credit_Adjustment","</ns2:Issue_Credit_Adjustment");

%>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" type="text/css" href="../style.css">
<script type="text/javascript" src="../orderfulfilment.js"></script>
<title>Issue Credit Adjustment</title>
</head>

<body>

<%
	if (MultipartFormDataRequest.isMultipartFormData(request)) {
         MultipartFormDataRequest mrequest = new MultipartFormDataRequest(request);
         String todo = null;
		 StringBuffer result = new StringBuffer();

         if (mrequest != null) todo = mrequest.getParameter("todo");

	     if ( (todo != null) && (todo.equalsIgnoreCase("upload")) ){
            Hashtable files = mrequest.getFiles();
            if ( (files != null) && (!files.isEmpty()) ){
                UploadFile file = (UploadFile) files.get("uploadfile");
				InputStream in = file.getInpuStream();

				int i = in.read();
				while (i != -1) {
					result.append((char) i);
					i = in.read();
				}
			}

            int beginOfFile = result.indexOf("<?xml");
            int endOfFile = result.indexOf("</ns2:Issue_Credit_Adjustment>");
            if(beginOfFile != -1 && endOfFile != -1) xml = result.substring(beginOfFile,endOfFile + 30);
		}
	}

	ByteArrayInputStream xmlBA = new ByteArrayInputStream(xml.getBytes("UTF-8"));
	JAXBContext jc1 = JAXBContext.newInstance("org.yawlfoundation.orderfulfilment.issue_credit_adjustment");
	Unmarshaller u = jc1.createUnmarshaller();
	JAXBElement icaElement1 = (JAXBElement) u.unmarshal(xmlBA);	//creates the root element from XML file
	IssueCreditAdjustmentType icat1 = (IssueCreditAdjustmentType) icaElement1.getValue();
	CreditAdjustmentType cat1 = icat1.getCreditAdjustment();
	ShipmentPaymentOrderType spot1 = icat1.getShipmentPaymentOrder();

	BeneficiaryType bt1 = null;
	if(!(spot1==null)) {
		bt1 = spot1.getBeneficiary();
	}
	CompanyType ct1 = null;
	if(!(bt1==null)) {
		ct1 = bt1.getBeneficiary();
	}

	BeneficiaryType bt2 = null;
	if(!(spot1==null)) {
		bt2 = cat1.getBeneficiary();
	}
	CompanyType ct2 = null;
	if(!(bt2==null)) {
		ct2 = bt2.getBeneficiary();
	}
%>

<div id="logo"></div>
<h2>Issue Credit Adjustment</h2>
<form id="IssueCreditAdjustment" name="IssueCreditAdjustment" method="post" novalidate="novalidate">

<fieldset>
	<legend>Shipment Details</legend>
	<div id="entry">
		<div id="label">Shipment Payment Order Number</div>
		<div id="field"><input name="shipmentpaymentordernumber" type="text" id="shipmentpaymentordernumber" pattern="textValidation" <%if (spot1!=null) out.println("value='"+spot1.getShipmentPaymentOrderNumber()+"'");%> readonly/></div>
	</div>
	<div id="entry">
		<div id="label">Order Number</div>
		<div id="field"><input name="ordernumber" type="text" id="ordernumber" pattern="textValidation" <%if (spot1!=null) out.println("value='"+spot1.getOrderNumber()+"'");%> readonly/></div>
	</div>
	<div id="entry">
		<div id="label">Shipment Number</div>
		<div id="field"><input name="shipmentnumber" type="text" id="shipmentnumber" pattern="textValidation" <%if (spot1!=null) out.println("value='"+spot1.getShipmentNumber()+"'");%> readonly/></div>
	</div>
	<div id="entry">
		<div id="label">Shipment Cost</div>
		<div id="field"><input name="shipmentcost" type="text" id="shipmentcost" pattern="doubleValidation" <%if (spot1!=null) out.println("value='"+spot1.getShipmentCost()+"'");%> readonly/></div>
	</div>
	<div id="entry"></div>
</fieldset>

<fieldset>
	<legend>Beneficiary</legend>
	<div id="entry">
		<div id="label">Bank</div>
		<div id="field"><input name="bank" type="text" id="bank" pattern="textValidation" <%if (bt1!=null) out.println("value='"+bt1.getBank()+"'");%> readonly/></div>
	</div>
	<div id="entry">
		<div id="label">Bank Code</div>
		<div id="field"><input name="bankcode" type="text" id="bankcode" pattern="textValidation" <%if (bt1!=null) out.println("value='"+bt1.getBankCode()+"'");%> readonly/></div>
	</div>
	<div id="entry">
		<div id="label">Account Name</div>
		<div id="field"><input name="accountname" type="text" id="accountname" pattern="textValidation" <%if (bt1!=null) out.println("value='"+bt1.getAccountName()+"'");%> readonly/></div>
	</div>
	<div id="entry">
		<div id="label">Account Number</div>
		<div id="field"><input name="accountnumber" type="text" id="accountnumber" pattern="textValidation" <%if (bt1!=null) out.println("value='"+bt1.getAccountNumber()+"'");%> readonly/></div>
	</div>
	<div id="entry"></div>
	<fieldset>
		<legend>Company Details</legend>
		<div id="entry">
			<div id="name">Name</div>
			<div id="name"><input type="text" name="companyname" id="companyname" pattern="textValidation" <%if (ct1!=null) out.println("value='"+ct1.getName()+"'");%> readonly/> </div>
		</div>
		<div id="entry">
			<div id="address">Address</div>
			<div id="address"><input type="text" name="companyaddress" id="companyaddress" pattern="textValidation" <%if (ct1!=null) out.println("value='"+ct1.getAddress()+"'");%> readonly/> </div>
		</div>
		<div id="entry">
			<div id="city">City</div>
			<div id="state">State</div>
			<div id="postcode">Postcode</div>
		</div>
		<div id="entry">
			<div id="city"><input type="text" name="companycity" id="companycity" pattern="textValidation" <%if (ct1!=null) out.println("value='"+ct1.getCity()+"'");%> readonly/> </div>
			<div id="state"><input type="text" name="companystate" id="companystate" pattern="textValidation" <%if (ct1!=null) out.println("value='"+ct1.getState()+"'");%> readonly/> </div>
			<div id="postcode"><input type="text" name="companypostcode" id="companypostcode" pattern="textValidation" <%if (ct1!=null) out.println("value='"+ct1.getPostCode()+"'");%> readonly/> </div>
		</div>
		<div id="entry">
			<div id="phone">Phone</div>
			<div id="fax">Fax</div>
			<div id="businessnumber">Business Number</div>
		</div>
		<div id="entry">
			<div id="phone"><input type="text" name="companyphone" id="companyphone" pattern="phoneValidation" <%if (ct1!=null) out.println("value='"+ct1.getPhone()+"'");%> readonly/> </div>
			<div id="fax"><input type="text" name="companyfax" id="companyfax" pattern="textValidation" <%if (ct1!=null) out.println("value='"+ct1.getFax()+"'");%> readonly/> </div>
			<div id="businessnumber"><input type="text" name="companybusinessnumber" id="companybusinessnumber" pattern="textValidation" <%if (ct1!=null) out.println("value='"+ct1.getBusinessNumber()+"'");%> readonly/> </div>
		</div>
		<div id="entry"></div>
	</fieldset>
</fieldset>

<fieldset>
	<legend>Credit Adjustment</legend>
	<div id="label">Reimbursement</div>
	<div id="field"><input type="text" name="reimbursement" id="reimbursement" pattern="doubleValidation" <%if (cat1!=null) out.println("value='"+cat1.getReimbursement()+"'");%>/></div>
	<div id="entry"></div>
	<fieldset>
	<legend>Beneficiary</legend>
		<div id="entry">
			<div id="label">Bank</div>
		  <div id="field"><input name="credit_bank" type="text" id="credit_bank" pattern="textValidation" <%if (bt2!=null) out.println("value='"+bt2.getBank()+"'");%>/>
		  </div>
		</div>
		<div id="entry">
			<div id="label">Bank Code</div>
		  <div id="field"><input name="credit_bankcode" type="text" id="credit_bankcode" pattern="textValidation" <%if (bt2!=null) out.println("value='"+bt2.getBankCode()+"'");%>/>
		  </div>
		</div>
		<div id="entry">
			<div id="label">Account Name</div>
		  <div id="field"><input name="credit_accountname" type="text" id="credit_accountname" pattern="textValidation" <%if (bt2!=null) out.println("value='"+bt2.getAccountName()+"'");%>/>
		  </div>
		</div>
		<div id="entry">
			<div id="label">Account Number</div>
		  <div id="field"><input name="credit_accountnumber" type="text" id="credit_accountnumber" pattern="textValidation" <%if (bt2!=null) out.println("value='"+bt2.getAccountNumber()+"'");%>/>
		  </div>
		</div>
		<div id="entry"></div>
		<fieldset>
			<legend>Company Details</legend>
			<div id="entry">
				<div id="name">Name</div>
				<div id="name"><input type="text" name="credit_companyname" id="credit_companyname" pattern="textValidation" <%if (ct2!=null) out.println("value='"+ct2.getName()+"'");%>/>
				</div>
			</div>
			<div id="entry">
				<div id="address">Address</div>
				<div id="address"><input type="text" name="credit_companyaddress" id="credit_companyaddress" pattern="textValidation" <%if (ct2!=null) out.println("value='"+ct2.getAddress()+"'");%>/>
				</div>
			</div>
			<div id="entry">
				<div id="city">City</div>
				<div id="state">State</div>
				<div id="postcode">Postcode</div>
			</div>
			<div id="entry">
				<div id="city"><input type="text" name="credit_companycity" id="credit_companycity" pattern="textValidation" <%if (ct2!=null) out.println("value='"+ct2.getCity()+"'");%>/>
				</div>
				<div id="state"><input type="text" name="credit_companystate" id="credit_companystate" pattern="textValidation" <%if (ct2!=null) out.println("value='"+ct2.getState()+"'");%>/>
				</div>
				<div id="postcode"><input type="text" name="credit_companypostcode" id="credit_companypostcode" pattern="textValidation" <%if (ct2!=null) out.println("value='"+ct2.getPostCode()+"'");%>/>
				</div>
			</div>
			<div id="entry">
				<div id="phone">Phone</div>
				<div id="fax">Fax</div>
				<div id="businessnumber">Business Number</div>
			</div>
			<div id="entry">
				<div id="phone"><input type="text" name="credit_companyphone" id="credit_companyphone" pattern="phoneValidation" <%if (ct2!=null) out.println("value='"+ct2.getPhone()+"'");%>/>
				</div>
				<div id="fax"><input type="text" name="credit_companyfax" id="credit_companyfax" pattern="textValidation" <%if (ct2!=null) out.println("value='"+ct2.getFax()+"'");%>/>
				</div>
				<div id="businessnumber"><input type="text" name="credit_companybusinessnumber" id="credit_companybusinessnumber" pattern="textValidation" <%if (ct2!=null) out.println("value='"+ct2.getBusinessNumber()+"'");%> />
				</div>
			</div>
			<div id="entry"></div>
		</fieldset>
	</fieldset>
</fieldset>

<div id="entry">&nbsp;</div>

<div>
	<input type="submit" name="Cancel" value="Cancel" />
	<input type="submit" name="Save" value="Save"/>
	<input type="submit" name="SaveToFile" value="Save To File" onClick="return validateForm('IssueCreditAdjustment');"/>
	&nbsp;
	<input type="submit" name="Complete" value="Complete" onClick="return validateForm('IssueCreditAdjustment');"/>

</div>

</form>

<!-- LOAD -->
<form method="post" action="Issue_Credit_Adjustment.jsp?formType=load&amp;workitem=<%= itemid %>&amp;handle=<%= handle %>&amp;submit=htmlForm" name="upform" enctype="MULTIPART/FORM-DATA">
    <div id="entry">&nbsp;</div>
	<div><strong>Select a file to upload :</strong></div>
	<div><input type="file" name="uploadfile" size="50"></div>
	<div>
		<input type="hidden" name="todo" value="upload">
		<input type="submit" name="Submit" value="Upload">
		<input type="reset" name="Reset" value="Cancel">
	</div>
</form>
<!-- END LOAD -->


<%
if(request.getParameter("Cancel") != null){
	//String redirectURL = "http://localhost:8080/resourceService/faces/userWorkQueues.jsp";
	//response.sendRedirect(response.encodeURL(redirectURL));
	session.removeAttribute("wir");
	String redirectURL = (String) session.getAttribute("source");
    session.removeAttribute("source");
    response.sendRedirect(response.encodeURL(redirectURL));
}else if(request.getParameter("Save") != null || request.getParameter("SaveToFile")!=null || request.getParameter("Complete") != null){

	CompanyType ct = new CompanyType();
	ct.setName(request.getParameter("companyname"));
	ct.setAddress(request.getParameter("companyaddress"));
	ct.setCity(request.getParameter("companycity"));
	ct.setState(request.getParameter("companystate"));
	ct.setPostCode(request.getParameter("companypostcode"));
	ct.setPhone(request.getParameter("companyphone"));
	ct.setFax(request.getParameter("companyfax"));
	ct.setBusinessNumber(request.getParameter("companybusinessnumber"));

	BeneficiaryType bt = new BeneficiaryType();
	bt.setBeneficiary(ct);
	bt.setBank(request.getParameter("bank"));
	bt.setBankCode(request.getParameter("bankcode"));
	bt.setAccountName(request.getParameter("accountname"));
	bt.setAccountNumber(request.getParameter("accountnumber"));

	ShipmentPaymentOrderType spot = new ShipmentPaymentOrderType();
	spot.setShipmentPaymentOrderNumber(request.getParameter("shipmentpaymentordernumber"));
	spot.setOrderNumber(request.getParameter("ordernumber"));
	spot.setShipmentNumber(request.getParameter("shipmentnumber"));
	spot.setShipmentCost(Double.parseDouble(request.getParameter("shipmentcost")));
	spot.setBeneficiary(bt);


	CompanyType cct = new CompanyType();
	cct.setName(request.getParameter("credit_companyname"));
	cct.setAddress(request.getParameter("credit_companyaddress"));
	cct.setCity(request.getParameter("credit_companycity"));
	cct.setState(request.getParameter("credit_companystate"));
	cct.setPostCode(request.getParameter("credit_companypostcode"));
	cct.setPhone(request.getParameter("credit_companyphone"));
	cct.setFax(request.getParameter("credit_companyfax"));
	cct.setBusinessNumber(request.getParameter("credit_companybusinessnumber"));

	BeneficiaryType cbt = new BeneficiaryType();
	cbt.setBeneficiary(cct);
	cbt.setBank(request.getParameter("credit_bank"));
	cbt.setBankCode(request.getParameter("credit_bankcode"));
	cbt.setAccountName(request.getParameter("credit_accountname"));
	cbt.setAccountNumber(request.getParameter("credit_accountnumber"));

	CreditAdjustmentType cat = new CreditAdjustmentType();
	cat.setReimbursement(Double.parseDouble(request.getParameter("reimbursement")));
	cat.setBeneficiary(cbt);

	IssueCreditAdjustmentType icat = new IssueCreditAdjustmentType();
	icat.setShipmentPaymentOrder(spot);
	icat.setCreditAdjustment(cat);

	ObjectFactory factory = new org.yawlfoundation.orderfulfilment.issue_credit_adjustment.ObjectFactory();

	JAXBElement icaElement = factory.createIssueCreditAdjustment(icat);

	JAXBContext jc = JAXBContext.newInstance("org.yawlfoundation.orderfulfilment.issue_credit_adjustment" );
	Marshaller m = jc.createMarshaller();
	m.setProperty( javax.xml.bind.Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE );

	ByteArrayOutputStream xmlOS = new ByteArrayOutputStream();
	m.marshal(icaElement, xmlOS);//out to ByteArray

	if (request.getParameter("SaveToFile") != null){
		response.setHeader("Content-Disposition", "attachment;filename=\"IssueCreditAdjustment.xml\";");
		response.setHeader("Content-Type", "text/xml");

		ServletOutputStream outs = response.getOutputStream();
		xmlOS.writeTo(outs);
		outs.close();

	}else if (request.getParameter("Save") != null){
		// update the data list to be returned to the engine
		xml = xmlOS.toString("UTF-8");
		xml = xml.replaceAll("<ns2:Issue_Credit_Adjustment xmlns:ns2=\"http://www.yawlfoundation.org/OrderFulfilment/Issue_Credit_Adjustment\"","<Issue_Credit_Adjustment");
		xml = xml.replaceAll("</ns2:Issue_Credit_Adjustment","</Issue_Credit_Adjustment");

		String result = client.updateWorkItemData(itemid, xml, handle);

		session.removeAttribute("wir");

		// Now we can redirect back to the worklist
		//String redirectURL = "http://localhost:8080/resourceService/faces/userWorkQueues.jsp";
		//response.sendRedirect(response.encodeURL(redirectURL));
		String redirectURL = (String) session.getAttribute("source");
        session.removeAttribute("source");
        response.sendRedirect(response.encodeURL(redirectURL));

	}else if (request.getParameter("Complete") != null){
		// update the data list to be returned to the engine
		xml = xmlOS.toString("UTF-8");
		xml = xml.replaceAll("<ns2:Issue_Credit_Adjustment xmlns:ns2=\"http://www.yawlfoundation.org/OrderFulfilment/Issue_Credit_Adjustment\"","<Issue_Credit_Adjustment");
		xml = xml.replaceAll("</ns2:Issue_Credit_Adjustment","</Issue_Credit_Adjustment");

		String result = client.updateWorkItemData(itemid, xml, handle);
		// If you want the workitem to complete when it posts back, set this attribute to true;
		// if it's false or commented out, the workitem will update and remain on the worklist's 'started' queue
		//session.setAttribute("complete_on_post", true);

		session.removeAttribute("wir");

		// Now we can redirect back to the worklist
		//String redirectURL = "http://localhost:8080/resourceService/faces/userWorkQueues.jsp?complete=true";
		//response.sendRedirect(response.encodeURL(redirectURL));
		String redirectURL = (String) session.getAttribute("source") + "?complete=true";
        session.removeAttribute("source");
        response.sendRedirect(response.encodeURL(redirectURL));
	}

}
%>
</body>
</html>
