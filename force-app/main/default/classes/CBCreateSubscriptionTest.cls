public with sharing class CBCreateSubscription {

public String response {get; set;}
public Contact cont {get; set;}
public String con_id {get; set;}
public Integer pquan {get; set;}
public boolean sameBillAddress {get; set;}
public String planPrice {get; set;}
public String planCur {get; set;}
public String planSetupCost {get; set;}
public String msg {get; set;}
public Integer values {get; set;}
public Opportunity opp {get; set;}
public boolean checkout {get; set;}
public List<AddonObject> selList {get; set;}
public boolean invNow {get; set;}
public String bCycle {get; set;}
public DateTime sDate {get; set;}
public String plans {get; set;}
public String coupen {get; set;}
public String ponum {get; set;}
public String sState {get; set;}
public String sCity {get; set;}
public String sCountry {get; set;}
public String sAddress1 {get; set;}
public String sAddress2 {get; set;}
public String sAddress3 {get; set;}
public String sPhone {get; set;}
public String sCompany {get; set;}
public String sFname {get; set;}
public String sDateStr {get; set;}
public String sLname {get; set;}
public String sZipcode {get; set;}
public String sEmail {get; set;}
public String opp_id {get; set;}
public String opp_name {get; set;}
public List<SelectOption> optionsAuto {get; set;}
public List<SelectOption> optionsCountry {get; set;}
public List<SelectOption>  optionsInvoiceNow {get; set;}
public CBURLUtil urlUtil {get; set;}
public String autocol {get; set;}
public boolean showPopup {get; set;}
public PricebookEntry sltd {get; set;}
public String status {get; set;}
public Long nextbillat {get; set;}
public List<LineItem> lts {get; set;}
public Double disc_amt {get; set;}
public String disc_desc {get; set;}
public String cc {get; set;}
public Double tot {get; set;}
public Double subt {get; set;}
public String displayText {get; set;}
public String tabName {get; set;}
public boolean stdate {get; set;}
public boolean tab {get; set;}
public String selectedTab {get; set;}
public boolean tab1 {get; set;}
public String subId {get; set;}
//
public boolean error {get; set;}
public String style {get; set;}
public String tabStyle1 {get; set;}
public String tabStyle2 {get; set;}
public boolean disc {get; set;}
public BaseError er {get; set;}
public String secondtab {get; set;}
public List<UnbilledEstimate> ue {get; set;}
public boolean isMultiSite {get; set;}
public boolean isSiteConnected {get; set;}
public boolean disableSelectedSite {get; set;}
public string selectedSiteName;
public List<chargebeeapps__Contact_Associate_Site__c> existingConSite {get; set;}
public String selectedSites {get; set;}
public string CbPriceBookEntry {get; set;}
public integer addonId {get; set;}
public string addon {get; set;}
public integer addonqty {get; set;}
public decimal addonprice {get; set;}
public string addonCurrency {get; set;}
public boolean displayQty {get; set;}

public boolean planOverridePriceType {get; set;}
public PricebookEntry selectedProduct;
public string addonType {get; set;}
public boolean displayTiers {get; set;}
public boolean showUnit {get; set;}
public boolean displayIcon {get; set;}
public string addontrigger {get; set;}
public string qtyChanged {get; set;}
public boolean displaytiericonplan {get; set;}
public List<Map<String,Object> > tierdata {get; set;}
public String siteId {get; set;}
public boolean planDisplayQuantity {get; set;}
public boolean planHasSetupCost {get; set;}
public Map<String, Object> sf_to_cb_values {get; set;}

public PageReference checkPermissions(){
	List<String> fields1 = new List<String> {'LastName', 'FirstName','Email', 'AccountId', 'Phone', 'MailingStreet', 'MailingCity', 'MailingState', 'MailingCountry', 'MailingPostalCode', 'chargebeeapps__Auto_collection__c', 'chargebeeapps__External_Id__c'};
	List<String> fields2 = new List<String> {'ExternalId','name','chargebeeapps__Recurring_charge_model__c','chargebeeapps__Addon_Type__c','chargebeeapps__Currency__c','chargebeeapps__Status__c','chargebeeapps__Product_Type__c'};
	List<String> fields3 = new List<String> {'Id','name','chargebeeapps__Setup_Cost__c','UnitPrice'};

	List<String> fields4 = new List<String> {'chargebeeapps__CB_Coupon_Id__c','Name','chargebeeapps__Status__c'};
	List<String> fields5 = new List<String> {'Name','Id', 'AccountId'};
	List<String> fields6 = new List<String> {'Name','Name' };
	List<String> fields7 = new List<String> {'chargebeeapps__Contact__c','chargebeeapps__External_Id__c','chargebeeapps__CB_Site__c'};
	List<String> objNames = new List<String>();
	String fs;
	if(!FlsUtil.isPermitable(fields1,'contact')) {
		fs = FlsUtil.getNotAccessibleFields(fields1,'contact','access');
		objNames.add('contact');
	}
	if(!FlsUtil.isPermitable(fields2,'product2')) {
		fs += FlsUtil.getNotAccessibleFields(fields2,'product2','access');
		objNames.add('product2');
	}
	if(!FlsUtil.isPermitable(fields3,'pricebookentry')) {
		fs += FlsUtil.getNotAccessibleFields(fields3,'pricebookentry','access');
		objNames.add('pricebookentry');
	}
	if(!FlsUtil.isPermitable(fields4,'chargebeeapps__Coupon__c')) {
		fs += FlsUtil.getNotAccessibleFields(fields4,'chargebeeapps__Coupon__c','access');
		objNames.add('chargebeeapps__Coupon__c');
	}
	if(!FlsUtil.isPermitable(fields5,'opportunity')) {
		fs += FlsUtil.getNotAccessibleFields(fields5,'opportunity','access');
		objNames.add('opportunity');
	}

	if(!FlsUtil.isPermitable(fields6,'Pricebook2')) {
		fs += FlsUtil.getNotAccessibleFields(fields6,'Pricebook2','access');
		objNames.add('Pricebook2');
	}
	if(!FlsUtil.isPermitable(fields7,'chargebeeapps__Contact_Associate_Site__c')) {
		fs += FlsUtil.getNotAccessibleFields(fields7,'chargebeeapps__Contact_Associate_Site__c','access');
		objNames.add('chargebeeapps__Contact_Associate_Site__c');
	}
	System.debug('fs-----'+fs);
	if(fs==null)
	{
		return null;
	}
	else
		return redirectToError(fs,String.join(objNames,','));
}

private boolean isFlatPlan(String pname){
	System.debug('flat---'+PlanExternalIdVsChargeModel.get(pname+'_CHARGE_MODEL'));
	if(PlanExternalIdVsChargeModel.get(pname+'_CHARGE_MODEL')!=null) {
		if(PlanExternalIdVsChargeModel.get(pname+'_CHARGE_MODEL')=='FLAT_FEE') {
			return true;
		}
	}
	return false;

}

public List<selectOption> getSiteDetails()
{    
	List<selectOption> multiSites = UIUtil.getSiteDetails(con_id);
	isSiteConnected = multiSites.size()==1;
	return multiSites;
}
public PageReference ChangeselectedSiteName()
{
    System.debug('ChangeSelectedSiteName invoked');
	plans ='';
	planCur = '';
	planPrice = '';
	displayIcon = false;
	addon= '';
	addonqty = 0;
	addonprice = 0;
	addonCurrency = '';
	selList = new List<AddonObject>();
	AddonObject ax = new AddonObject('-1',1,1,0,false,2);
	selList.add(ax);
	selectedSiteName = selectedSites;
	siteId=SiteUtil.getSiteId(selectedSites);
	system.debug('siteId:'+siteId);
	system.debug('Site:'+selectedSites);
	reloadCustomFieldMapping();
	options3Cache=CBSubscriptionUtil.getProductSelectOptions('PLAN',siteId,null);
	addonOptionsCache=CBSubscriptionUtil.getProductSelectOptions('ADDON',siteId,null);
	fillPlanExternalIdVsChargeModelCache();
	return null;
}
public PageReference selectedSiteName()
{
    System.debug('SelectedSiteName invoked');
	selectedSiteName = selectedSites;
	siteId=SiteUtil.getSiteId(selectedSites);
	reloadCustomFieldMapping();
	options3Cache=CBSubscriptionUtil.getProductSelectOptions('PLAN',siteId,null);
	addonOptionsCache=CBSubscriptionUtil.getProductSelectOptions('ADDON',siteId,null);
	fillPlanExternalIdVsChargeModelCache();
	system.debug('Site:'+selectedSites);
	return null;
}
public PageReference preview(){
	showPopup=true;
	populate();
	return null;
}
public void selecttab(){
	tabStyle1='cb-btn cb-btn--selected';
	tabStyle2='cb-btn cb-btn--righttab';
	tab1 = true;
}
public void selecttab1(){
	tabStyle2='cb-btn cb-btn--selected';
	tabStyle1='cb-btn cb-btn--lefttab';
	tab1 = false;
	ApexPages.currentPage().getParameters().put('con_id',ApexPages.currentPage().getParameters().get('con_id'));
	ApexPages.currentPage().getParameters().put('opp_id',ApexPages.currentPage().getParameters().get('opp_id'));
}

public void populate(){
	urlUtil = new CBURLUtil(selectedSites);
	String sid=SiteUtil.getSiteId(selectedSites);

	existingConSite = [SELECT Id,chargebeeapps__Contact__c,chargebeeapps__External_Id__c,chargebeeapps__CB_Site__c FROM chargebeeapps__Contact_Associate_Site__c WHERE (chargebeeapps__Contact__c =: cont.Id AND chargebeeapps__CB_Site__c =:sid)];

	String responseFromNet;
	response=null;
	String bodyData='';

	EndPoint ep = EndPointsIndex.create_sub_est_url;
	ep.domainName(selectedSites);
	List<String> liststr = new List<String>();
	system.debug('ext id-- '+existingConSite[0].chargebeeapps__External_Id__c);
	liststr.add(EncodingUtil.urlEncode(existingConSite[0].chargebeeapps__External_Id__c,'UTF-8'));
	ep.replace(liststr);
	CreateSubEstUrlBuilder br = new CreateSubEstUrlBuilder(ep);
	Integer quan = isFlatPlan(plans) ? 1 : pquan;
	br.Id(subId).planId(plans).planQuan(String.valueOf(quan)).billingCycles(bCycle).couponId(coupen).autoCol(autocol).poNum(ponum).stDate(sDateStr).invoiceImmediately(String.valueOf(invNow));
	stdate = false;

	if(sDateStr!=null && !sDateStr.equals('')) {
		stdate = true;
	}

	if( canOverRide ) {
		if(planPrice != null && !planPrice.equals('') && !IsNewPricingModel(plans)) {
			try{
				br.planUnitPrice(String.valueOf(ChargebeeUtil.convertToLowerOrderCurrency(planCur,Double.valueOf(planPrice))));
			}
			catch(Exception e) {
				showPopup=false;
				er = new BaseError(e.getMessage());
				return;
			}

		}
		if(planSetupCost != null&& !planSetupCost.equals('') && !IsNewPricingModel(plans)) {
			try{
				br.planSetupFee(String.valueOf(ChargebeeUtil.convertToLowerOrderCurrency(planCur,Double.valueOf(planSetupCost))));
			}catch(Exception e) {
				showPopup=false;
				er = new BaseError(e.getMessage());
				return;
			}
		}
	}
	if(sameBillAddress == false) {
		br.fnSA(sFname).lnSA(sLname).eSA(sEmail).pSA(sPhone).cSA(sCompany).l1SA(sAddress1).l2SA(sAddress2).l3SA(sAddress3).ciSA(sCity).sSA(sState).coSA(sCountry).zSA(sZipcode);
	}
	br.ustring = CBSubscriptionUtil.getAddonURL(selList,br.ustring, PlanExternalIdVsChargeModel, canOverRide);
	UpdateSubEstController ctllr = new UpdateSubEstController(br);
	Map<String, Object> responseMap = ctllr.makeRequest();
	System.debug(' Response Map for CreateSubscription ' + responseMap);
	try
	{
		Map<String, Object> estimate = (Map<String, Object>)responseMap.get('estimate');
		Map<String, Object> subEstimate = (Map<String, Object>)estimate.get('subscription_estimate');
		String jst = (String)subEstimate.get('status');
		cc = (String)subEstimate.get('currency_code');
		Map<String, Object> invEst = null;
		invEst = (Map<String, Object>)estimate.get('invoice_estimate');
		if(invEst==null) {
			invEst = (Map<String, Object>)estimate.get('next_invoice_estimate');
		}
		List<Object> lineItems = new List<Object>();
		if(invEst!=null) {
			lineItems = (List<Object>)invEst.get('line_items');
			subt = ChargebeeUtil.convertToHigherOrderCurrency(cc,Integer.valueOf(invEst.get('amount_due')));
			tot = ChargebeeUtil.convertToHigherOrderCurrency(cc,Integer.valueOf(invEst.get('total')));
            System.debug('!!!!!!!Subscirption Total and SubTotal ' + tot + ' ' + subt);
		}else{
			tot = 0.0;
			subt = 0.0;
			if(estimate != null && estimate.get('unbilled_charge_estimates') != null ) {
				lineItems = (List<Object>)estimate.get('unbilled_charge_estimates');
				for(Object lt:lineItems) {
					cc = String.valueOf(((Map<String, Object>)lt).get('currency_code'));
					String unitAmount = String.valueOf(((Map<String, Object>)lt).get('amount'));
					tot += decimal.valueOf(unitAmount);
					String discount = String.valueOf(((Map<String, Object>)lt).get('discount_amount'));
					subt = tot - decimal.valueOf(discount);
				}
				if(tot != null) {
					tot = ChargebeeUtil.convertToHigherOrderCurrency(cc,Integer.valueOf(tot));
					subt = ChargebeeUtil.convertToHigherOrderCurrency(cc,Integer.valueOf(subt));
				}
			}
            System.debug('*************Subscirption Total and SubTotal ' + tot + ' ' + subt);
		}

		long lv=0;
		for(Object lt:lineItems) {
			String unitAmount = String.valueOf(((Map<String, Object>)lt).get('unit_amount'));
			String quantity =   String.valueOf(((Map<String, Object>)lt).get('quantity'));
			String amt = String.valueOf(((Map<String, Object>)lt).get('amount'));
			String descrip = String.valueOf(((Map<String, Object>)lt).get('description'));
			String et = String.valueOf(((Map<String, Object>)lt).get('entity_type'));
			String e_id = String.valueOf(((Map<String, Object>)lt).get('entity_id'));
			String recur_type = PlanExternalIdVsChargeModel.get(e_id+'_CHARGE_MODEL');
			boolean ir=true;
			if(et=='plan_setup')
			{
				ir=false;
			}
			if(recur_type!=null)
			{
				if(recur_type=='NON_RECURRING')
				{
					ir=false;
				}
			}
			LineItem linet = new LineItem(unitAmount,quantity,descrip,amt,cc,et,ir);
			lts.add(linet);
		}
		if(jst=='in_trial')
		{
			system.debug('Date:'+sDate);
			displayText= CBSubscriptionUtil.getImmediateChargeDisplayText(cc,sDate, tot);
			status = 'in_trial';
			tabName = 'CHARGES ON ACTIVATION';
			tab=true;
			style += ' cb-status--trial';
		}
		else{
			if(invNow) {
				if(stdate) {
					displayText= CBSubscriptionUtil.getImmediateChargeDisplayText(cc,sDate, tot);
					tabName = 'CHARGES ON ACTIVATION';
					status = 'future';
					tab=true;
					style += ' cb-status--future';
				}
				else{
					displayText= CBSubscriptionUtil.getInvDisplayText(cc,tot);
					tabName = 'IMMEDIATE CHARGES';
					status='active';
					tab=true;
				}
			}
			else{
				if(stdate) {
					displayText= CBSubscriptionUtil.getNoChargeDisplayText();
					tabName = 'false';
					tab=false;
					status = 'future';
					style += ' cb-status--future';
				}
				else{
					displayText= CBSubscriptionUtil.getNoChargeWithTotDisplayText(cc,tot);
					tabName = 'UNBILLED CHARGES';
					status='active';
					tab=true;

				}
			}
		}
		List<Object> discounts =null;
		if(invEst!=null) {
			discounts = (List<Object>)invEst.get('discounts');
		}
		if(discounts!=null) {
			Integer sl = (Integer)((Map<String, Object>)discounts[0]).get('amount');
			disc=true;
			long l = (long)(sl);
			disc_amt = ChargebeeUtil.convertToHigherOrderCurrency(cc,l);
			disc_desc = (String)((Map<String, Object>)discounts[0]).get('description');
		}
        System.debug('Subscirption Total and SubTotal ' + tot + ' ' + subt);
	}
	catch(Exception ex)
	{
		showPopup=false;
		er = new BaseError(responseMap);
		return;
	}
}


public PageReference save(){

	String is_error =null;
	String responseFromNet;

	String bodyData = 'plan_id='+EncodingUtil.urlEncode(plans,'UTF-8');

	EndPoint ep = EndPointsIndex.create_sub_url;
	ep.domainName(selectedSites);
	List<String> liststr = new List<String>();
	liststr.add(EncodingUtil.urlEncode(existingConSite[0].chargebeeapps__External_Id__c,'UTF-8'));
	ep.replace(liststr);
	CreateSubUrlBuilder br = new CreateSubUrlBuilder(ep);
	Integer quan = isFlatPlan(plans) ? 1 : pquan;
	br.Id(subId).planId(plans).planQuan(String.valueOf(quan)).billingCycles(bCycle).couponId(coupen).autoCol(autocol.toLowerCase()).poNum(ponum).stDate(sDateStr).invoiceImmediately(String.valueOf(invNow));

	if( canOverRide ) {
		if(planPrice != null && !planPrice.equals('') && !IsNewPricingModel(plans)) {
			br.planUnitPrice(String.valueOf(ChargebeeUtil.convertToLowerOrderCurrency(planCur,Double.valueOf(planPrice))));
		}
		if(planSetupCost != null&& !planSetupCost.equals('') && !IsNewPricingModel(plans)) {
			br.planSetupFee(String.valueOf(ChargebeeUtil.convertToLowerOrderCurrency(planCur,Double.valueOf(planSetupCost))));
		}
	}

	if(sameBillAddress == false)
	{
		br.fnSA(sFname).lnSA(sLname).eSA(sEmail).pSA(sPhone).cSA(sCompany).l1SA(sAddress1).l2SA(sAddress2).l3SA(sAddress3).ciSA(sCity).sSA(sState).coSA(sCountry).zSA(sZipcode);
	}

	br.ustring = CBSubscriptionUtil.getAddonURL(selList,br.ustring, PlanExternalIdVsChargeModel, canOverRide);

	//custom field mapping handling start
	if(opp_id!=null && opp_id!='-1') {
		Map<String, Object> sf_to_cb_mapping=CBCustomFieldMappingUtil.getFieldMapping(selectedSites);
		sf_to_cb_values=CBCustomFieldMappingUtil.getCustomFieldDataForSubscription(opp_id,sf_to_cb_mapping);
		if(sf_to_cb_values!=null) {
			for(String fieldName :sf_to_cb_values.keySet()) {
				if(sf_to_cb_values.get(fieldName).toString()!=CBCustomFieldMappingUtil.NO_VALUE_SET)
					br.ustring = CBURLUtil.buildURLString(br.ustring, fieldName, sf_to_cb_values.get(fieldName).toString());
			}
		}
	}
	//custom field mapping handling ends

	UpdateSubEstController ctllr = new UpdateSubEstController(br);
	Map<String, Object> responseMap = ctllr.makeRequest();
	system.debug('Response:'+responseMap);
	er = new BaseError(responseMap);
	if(!er.isErr) {
		String sub_id = (String)((Map<String, Object>)responseMap.get('subscription')).get('id');
		system.debug('sub_id'+sub_id);
		bodyData='';
		bodyData = CBURLUtil.buildURLString(bodyData, 'entity_id',sub_id);
		if(sub_id != null && sub_id != '')
		{
			String updateTPEndpoint = CBSubscriptionUtil.getUpdateTPEndPoint(urlUtil);
			try {
				bodyData = CBSubscriptionUtil.getDataForTpSync(opp_id, bodyData,'CREATE_FAILED');
				responseFromNet = CBURLUtil.sendRequest(updateTPEndpoint, bodyData, urlUtil, true);
				response=null;
			}catch(Exception exp) {
				responseFromNet = 'CB Exception '+exp;
				response = responseFromNet;
				is_error=response;
			}

			String subSyncEndPoint = CBSubscriptionUtil.getSyncSubsEndPoint(urlUtil);
			bodyData = '';
			bodyData = CBURLUtil.buildURLString(bodyData, 'id', sub_id);
			bodyData = CBURLUtil.buildURLString(bodyData,'api_key',urlUtil.getApiKey());
			try
			{
				responseFromNet = CBURLUtil.sendRequest(subSyncEndPoint, bodyData, urlUtil, true);
				System.debug('tp responseFromNet--' + responseFromNet);
				response=null;
			}catch(Exception exp) {
				System.debug('exception '+exp);
				responseFromNet = 'CB Exception '+exp;
			}

		}
	}else{
		return null;
	}
	return page_redirect();
}

public PageReference page_redirect(){
	String url = con_id;
	if(opp_id !=null && opp_id != '-1') {url=opp_id;}
	PageReference pageRef = new PageReference('/'+url);
	pageRef.setRedirect(true);
	return pageRef;
}

public PageReference cancel_page(){
	return page_redirect();
}

public static boolean IsNewPricingModel(String planId){
	if(planId != '-1') {
		Product2 Product = [Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c From Product2 where Product2.ExternalId =:planId];
		String plantype=Product.chargebeeapps__Recurring_charge_model__c;
		return (plantype=='Tiered' || plantype=='Stairstep' || plantype=='Volume');
	}
	return false;
}

public PageReference checkout(){

	urlUtil = new CBURLUtil(selectedSites);
	String responseFromNet;
	String sid=SiteUtil.getSiteId(selectedSites);
	existingConSite = [SELECT Id,chargebeeapps__Contact__c,chargebeeapps__External_Id__c, chargebeeapps__CB_Site__c FROM chargebeeapps__Contact_Associate_Site__c WHERE (chargebeeapps__Contact__c =: cont.Id AND chargebeeapps__CB_Site__c=:sid)];
	string endpointURL = CBSubscriptionUtil.getCheckoutURL(urlUtil,selectedSites);
	system.debug('checkout endpoint:'+endpointURL);

	EndPoint ep = EndPointsIndex.checkout_new_url;
	ep.domainName(selectedSites);
	CheckoutNewURLB br = new CheckoutNewURLB(EndPointsIndex.checkout_new_url);
	String bodyData = '';
	Integer quan = isFlatPlan(plans) ? 1 : pquan;
	br.Id(subId).custId(existingConSite[0].chargebeeapps__External_Id__c).planId(plans).planQuan(String.valueOf(quan)).billingCycles(bCycle).couponId(coupen).autoCol(autocol).poNum(ponum).stDate(sDateStr);

	if( canOverRide ) {
		if(planPrice != null && !planPrice.equals('') && !IsNewPricingModel(plans)) {
			br.planUnitPrice(String.valueOf(ChargebeeUtil.convertToLowerOrderCurrency(planCur,Double.valueOf(planPrice))));
		}
		if(planSetupCost != null && !planSetupCost.equals('') && !IsNewPricingModel(plans)) {
			br.planSetupFee(String.valueOf(ChargebeeUtil.convertToLowerOrderCurrency(planCur,Double.valueOf(planSetupCost))));
		}
	}
	br.ustring = CBSubscriptionUtil.getAddonURL(selList,br.ustring, PlanExternalIdVsChargeModel, canOverRide);
	UpdateSubEstController ctllr = new UpdateSubEstController(br);
	Map<String, Object> responseMap = ctllr.makeRequest();
    system.debug('responseMap checkout--'+responseMap);
	er = new BaseError(responseMap);

	if(er.isErr) {
		return null;
	}
	String link = (String)((Map<String, Object>)responseMap.get('hosted_page')).get('url');
	String uid = (String)((Map<String, Object>)responseMap.get('hosted_page')).get('id');

	if(link==null) {
		return null;
	}
	PageReference pageRef = new PageReference('/apex/CBCheckoutLink?id='+cont.id+'&link_url='+link+'&link_id='+uid+'&domain='+selectedSites);
	if(opp_id!=null && opp_id!='-1') {
		pageRef.getParameters().put('opp_id',opp_id);
	}

	pageRef.setRedirect(true);

	return pageRef;
}

public PageReference Cancel(){
	showPopup = false;
	PageReference pr = new PageReference('/apex/Create_Subscription');
	pr.getParameters().put('con_id',ApexPages.currentPage().getParameters().get('con_id'));
	pr.getParameters().put('opp_id',ApexPages.currentPage().getParameters().get('opp_id'));
	system.debug('opp_id-->'+ApexPages.currentPage().getParameters().get('opp_id'));
	pr.setRedirect(true);
	return pr;
}

public List<SelectOption> options3Cache;
public List<SelectOption> options3 {
	get
	{
		if(options3Cache!=null) return options3Cache;
		system.debug('Sitename from Options3:'+selectedSites);
		System.debug('check siteId--'+ siteId);
        
		options3Cache=CBSubscriptionUtil.getProductSelectOptions('PLAN',siteId,null);
		return options3Cache;
	} set;
}

public PageReference redirectToError(String err,String obj){
	PageReference pageRef = new PageReference('/apex/error');
	pageRef.getParameters().put('err',err);
	pageRef.getParameters().put('obj',obj);
	pageRef.setRedirect(true);
	return pageRef;
}

public Boolean isMultiCurrencyEnabled {
	get {
		return UIUtil.isMultiCurrencyEnabled();
	} set;
}

public PageReference CbPriceBookEntry()
{
	planOverridePriceType=true;
	CbPriceBookEntry =plans;
	System.debug('Selected Plan in CBPriceBookEntry() ' + plans + ' QtyChanged ' + qtyChanged);
	if(plans != '-1') {
		if(isMultiCurrencyEnabled) {
			selectedProduct = Database.query('Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice,PricebookEntry.CurrencyIsoCode From PricebookEntry  where Product2.ExternalId =:plans  And Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c=\'ACTIVE\' and (product2.chargebeeapps__Product_Type__c=\'PLAN\' or product2.chargebeeapps__Product_Type__c=\'ADDON\')');
			planCur = (String)selectedProduct.get('CurrencyIsoCode');
		}else{
			selectedProduct = [Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice,product2.chargebeeapps__Currency__c From PricebookEntry where Product2.ExternalId =:plans And Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' and (product2.chargebeeapps__Product_Type__c='PLAN' or product2.chargebeeapps__Product_Type__c='ADDON')];
			planCur = selectedProduct.product2.chargebeeapps__Currency__c;
		}

		string pbId = string.valueOf(selectedProduct.Id);
		String plantype=selectedProduct.product2.chargebeeapps__Recurring_charge_model__c;
		if(qtyChanged!='changed')
		{
			planPrice = string.valueOf(selectedProduct.UnitPrice);
		}
		qtyChanged =null;

		displayIcon = plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('Stairstep');
		if(plantype != null && ( plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')||plantype.equalsIgnoreCase('Volume')))
		{
			planOverridePriceType=false;
			List<chargebeeapps__CB_Pricing_Tiers__c> pricingTiers = ProductService.getPricingTiers(pbId); 

			showUnit = plantype.equalsIgnoreCase('Tiered');

			tierdata=UIUtil.getTierMetric(pbId,plantype,pquan, pricingTiers);

			planPrice = string.valueOf(ProductService.getPrice(planType, pricingTiers, pquan));
			if(pquan == 0 || pquan == null)
			{
				displayIcon =false;
			}
		}
	}
	return null;
}

public PageReference CbPriceBookEntryAddon()
{
	AddonObject selectedAddon;
    System.debug('AddonId ' + addonId);
	selectedAddon=selList.get(addonId-1);
	String addonName=selectedAddon.addon;
	addonqty = selectedAddon.qty;
	if(addonName != null && addonName !='-1')
	{
		if(isMultiCurrencyEnabled) {
			selectedProduct = Database.query('Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice,PricebookEntry.CurrencyIsoCode From PricebookEntry  where Product2.ExternalId =:addonName And Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c=\'ACTIVE\' and product2.chargebeeapps__Product_Type__c=\'ADDON\'');
			selectedAddon.addonCurrency = (String)selectedProduct.get('CurrencyIsoCode');
		}else{
			selectedProduct = [Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice,product2.chargebeeapps__Currency__c From PricebookEntry where Product2.ExternalId =:addonName And Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' and product2.chargebeeapps__Product_Type__c='ADDON'];
			selectedAddon.addonCurrency = selectedProduct.product2.chargebeeapps__Currency__c;
		}

		string pbId = string.valueOf(selectedProduct.Id);
		String plantype=selectedProduct.product2.chargebeeapps__Addon_Type__c;
		selectedAddon.model=plantype;

		if(plantype == null || plantype.equalsIgnoreCase('Flat_Fee') ||
		   plantype.equalsIgnoreCase('per_unit')||plantype.equalsIgnoreCase('quantity'))
		{
			if(qtyChanged!='changed')
			{
				selectedAddon.price = selectedProduct.UnitPrice;
			}
		}
		if(plantype != null && ( plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')||plantype.equalsIgnoreCase('Volume')))
		{
			List<chargebeeapps__CB_Pricing_Tiers__c> pricingTiers = ProductService.getPricingTiers(pbId); 
			if(plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep'))
			{
				List<Map<String,Object>> tierdataAddon=UIUtil.getTierMetric(pbId,plantype,addonqty, pricingTiers);
				if(tierdataAddon != null & !tierdataAddon.isEmpty())
				{
					selectedAddon.tierdata=tierdataAddon;
				}
			}
			selectedAddon.price = ProductService.getPrice(planType, pricingTiers, addonqty);
		}
		qtyChanged =null;
	}
	return null;
}

public Map<String,String> PlanExternalIdVsChargeModelCache;

public Map<String,String> PlanExternalIdVsChargeModel {get {
							       Long benchMark=System.currentTimeMillis();
							       if(PlanExternalIdVsChargeModelCache!=null) {
								       system.debug('PlanExternalIdVsChargeModeltime:'+(system.currentTimeMillis()-benchMark));
								       return PlanExternalIdVsChargeModelCache;
							       }
							       fillPlanExternalIdVsChargeModelCache();
							       return PlanExternalIdVsChargeModelCache;
						       } set;}

public void fillPlanExternalIdVsChargeModelCache(){
	Long benchMark=System.currentTimeMillis();
	List<PricebookEntry> prodList = new List<PricebookEntry>();
	if(isMultiCurrencyEnabled) {
		prodList = Database.query('Select id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, PricebookEntry.CurrencyIsoCode From PricebookEntry  where Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c=\'ACTIVE\' and (product2.chargebeeapps__Product_Type__c=\'PLAN\' or product2.chargebeeapps__Product_Type__c=\'ADDON\') limit 999');
	}else{
		prodList = [Select id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, product2.chargebeeapps__Currency__c From PricebookEntry where Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' and (product2.chargebeeapps__Product_Type__c='PLAN' or product2.chargebeeapps__Product_Type__c='ADDON') limit 999];
	}

	PlanExternalIdVsChargeModelCache = new Map<String,String>();

	for(PricebookEntry temp : prodList)
	{
		if(temp.Product2.chargebeeapps__Product_Type__c == 'PLAN' && temp.Product2.ExternalId!= null)
		{
			PlanExternalIdVsChargeModelCache.put(temp.Product2.ExternalId+'_CHARGE_MODEL',temp.Product2.chargebeeapps__Recurring_charge_model__c);
		}
		else if(temp.Product2.chargebeeapps__Product_Type__c == 'ADDON' && temp.Product2.ExternalId!= null
		        && temp.Product2.chargebeeapps__Addon_Type__c != null ) {
			PlanExternalIdVsChargeModelCache.put(temp.Product2.ExternalId+'_CHARGE_MODEL',temp.Product2.chargebeeapps__Addon_Type__c);
		}
		PlanExternalIdVsChargeModelCache.put(temp.Product2.ExternalId+'_UNIT_PRICE',String.valueOf(temp.UnitPrice));

		if( temp.chargebeeapps__Setup_Cost__c != null ) {
			PlanExternalIdVsChargeModelCache.put(temp.Product2.ExternalId+'_SETUP_COST',String.valueOf(temp.chargebeeapps__Setup_Cost__c));
		}
		if(isMultiCurrencyEnabled) {
			if( temp.get('CurrencyIsoCode')!= null ) {
				PlanExternalIdVsChargeModelCache.put(temp.Product2.ExternalId+'_CURRENCY',String.valueOf(temp.get('CurrencyIsoCode')));
			}
		}else{
			if( temp.Product2.chargebeeapps__Currency__c!= null ) {
				PlanExternalIdVsChargeModelCache.put(temp.Product2.ExternalId+'_CURRENCY',String.valueOf(temp.Product2.chargebeeapps__Currency__c));
			}
		}
	}
	system.debug('PlanExternalIdVsChargeModeltime:'+(system.currentTimeMillis()-benchMark));
}
public String JsonMap {get {
			       return JSON.serialize(PlanExternalIdVsChargeModel);
		       } set;}



public Boolean canOverride {
	get {
		System.debug('ovvv--'+urlUtil.canOverRide());
		return urlUtil.canOverRide();

	} set;
}

public List<SelectOption> addonOptionsCache;
public List<SelectOption> addonOptions {
	get
	{
		Long benchMark=System.currentTimeMillis();
		if(addonOptionsCache!=null) {
			system.debug('optionsaddon:'+(system.currentTimeMillis()-benchMark));
			return addonOptionsCache;
		}
		addonOptionsCache=CBSubscriptionUtil.getProductSelectOptions('ADDON',siteId,null);
		return addonOptionsCache;

	}
}

public List<SelectOption> oppOptions {get; set;}

public List<SelectOption> coupenOptions {
	get {
		return UIUtil.getCouponOptions(siteId);
	}
	set;
}

public PageReference updateStartDate(Date val){
	sDate=val;
	return null;
}

public PageReference saveAccount(){
	sameBillAddress = !sameBillAddress;
	return null;
}

public PageReference saveAddons(){

	Integer i = values;
	AddonObject ax = new AddonObject('-1',1,i+1,0,false,2);
	selList.add(ax);
	AddonObject old = selList.get(i-1);
	old.setStatus(3);
	system.debug('seList for saveAddon'+selList);
	return null;
}

public PageReference delAddons(){
	Integer i = values;
	AddonObject old = selList.get(i-1);
	//TODO: Check
	old.displaytiericon=false;
	old.displaytier=false;
	old.displayQuantity=false;

	old.setStatus(4);
	return null;
}

public void reloadCustomFieldMapping(){
	System.debug('opp:::'+opp_id+'::site::'+selectedSiteName);
	if(opp_id!=null && opp_id!='-1') {
		Map<String, Object> sf_to_cb_mapping=CBCustomFieldMappingUtil.getFieldMapping(selectedSites);
		sf_to_cb_values=CBCustomFieldMappingUtil.getCustomFieldDataForSubscription(opp_id,sf_to_cb_mapping);
	}
	else{
		sf_to_cb_values=null;
	}
	System.debug('sf_to_cb_values:::'+sf_to_cb_values);
}

public CBCreateSubscription()
{
	isMultiSite=CBURLUtil.isMultiSite();
	disableSelectedSite = false;
	selectedSites = System.currentPageReference().getParameters().get('domain');

	system.debug(selectedSites);

	if(isMultiSite)
	{
		system.debug(isMultiSite);
		urlUtil = new CBURLUtil(selectedSites);
		system.debug(urlUtil);

	}else{
		urlUtil = new CBURLUtil();
	}
	planDisplayQuantity=false;
	planHasSetupCost=false;
	displayQty = false;
	displayTiers=false;
	showUnit = false;
	qtyChanged =null;
	selectedProduct = new PricebookEntry();
	existingConSite = new List<Contact_Associate_Site__c>();
	showPopup=false;
	bCycle=null;
	sameBillAddress = true;
	sDate=null;
	plans='-1';
	invNow=true;
	//urlUtil = new CBURLUtil();
	autocol = urlUtil.autoCollectionFlag();

	optionsAuto = new List<SelectOption>();
	optionsAuto.add(new SelectOption('OFF','OFF'));
	optionsAuto.add(new SelectOption('ON','ON'));
	sltd = new PricebookEntry();
	optionsInvoiceNow = new List<SelectOption>();
	optionsInvoiceNow.add(new SelectOption('true','Invoice now'));
	optionsInvoiceNow.add(new SelectOption('false','Add to unbilled charges'));
	lts = new List<LineItem>();
	selectedTab ='NewSubscriptionPreview';
	tab1=true;
	error=false;
	isSiteConnected=false;
	secondtab='secondtab';
	con_id = ApexPages.currentPage().getParameters().get('con_id');
	con_id = String.escapeSingleQuotes(con_id);
	String que = 'select Account.Name,Name,LastName, FirstName,Email, AccountId, Phone, MobilePhone, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, chargebeeapps__Auto_collection__c, chargebeeapps__External_Id__c from contact where id=\''+con_id+'\'';
	cont=Database.query(que);
	selList = new List<AddonObject>();
	style = 'cb-status';
	opp_id = ApexPages.currentPage().getParameters().get('opp_id');
	er = new BaseError();
	tabStyle1='cb-btn cb-btn--selected';
	tabStyle2='cb-btn cb-btn--righttab';

	pquan=1;
	if(opp_id == null || opp_id == 'null' || opp_id == '-1') {
		List<Opportunity> oppList = new List<Opportunity>();

		oppList = [select id,name from Opportunity where AccountId=:cont.AccountId];
		oppOptions =  new List<SelectOption>();
		oppOptions.add(new SelectOption('-1','Select'));
		for(Opportunity temp : oppList) {
			if(temp.id != null) {
				oppOptions.add(new SelectOption(temp.id,temp.name));
			}
		}
	}
	else{
		opp_id = String.escapeSingleQuotes(opp_id);
		String que2 = 'select id,name,chargebeeapps__Coupon__c,Pricebook2Id from Opportunity where Id=:opp_id';
		//custom field mapping handling start
		if(opp_id!=null && opp_id!='-1') {
			Map<String, Object> sf_to_cb_mapping=CBCustomFieldMappingUtil.getFieldMapping(selectedSites);
			sf_to_cb_values=CBCustomFieldMappingUtil.getCustomFieldDataForSubscription(opp_id,sf_to_cb_mapping);
		}
		//custom field mapping handling ends
		Opportunity opptemp = Database.query(que2);
		opp_name = opptemp.name;
		//auto fill code starts
		if(opptemp.Pricebook2Id!=null) {
			Pricebook2 pb=[select PriceBook2.chargebeeapps__CB_Site__r.Id, PriceBook2.chargebeeapps__CB_Site__r.Name from PriceBook2 where Id=:opptemp.Pricebook2Id];
			selectedSites=pb.chargebeeapps__CB_Site__r.Name;
			siteId=pb.chargebeeapps__CB_Site__r.Id;
		}
		else{
			siteId=SiteUtil.getSiteId(selectedSites);
		}

		List<OpportunityLineItem> oppitem = Database.query('select Product2Id,PricebookEntry.chargebeeapps__Setup_Cost__c,Product2.Name,Product2.ExternalId,Product2.chargebeeapps__Currency__c,Product2.chargebeeapps__Product_Type__c,Product2.chargebeeapps__Addon_Type__c,Product2.chargebeeapps__Addon_Applicability__c,Quantity,UnitPrice, Discount ,Product2.chargebeeapps__Recurring_charge_model__c,TotalPrice,OpportunityId from OpportunityLineItem where PricebookEntry.Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c=\'ACTIVE\' and OpportunityId =:opp_id');
        System.debug(' Associated Addons/Plans for Opportunity ' + oppitem + ' PlanPrice ' + planPrice);
		if(!oppitem.isEmpty() && planPrice==null)
		{
            System.debug('!!!1 Associated Addons/Plans for Opportunity ' + oppitem + ' PlanPrice ' + planPrice);
			Integer addonCount=1;
			if(opptemp.Coupon__c!=null) {
				chargebeeapps__Coupon__c c=[select Id,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__Coupon__c where chargebeeapps__CB_Site__c=:siteId and Id=:opptemp.Coupon__c];
				coupen=c.chargebeeapps__CB_Coupon_Id__c;
			}
			for(OpportunityLineItem oitem:oppitem)
			{
                System.debug('**** Associated Addons/Plans for Opportunity ' + oppitem + ' PlanPrice ' + planPrice);
				if(oitem.product2.chargebeeapps__Product_Type__c =='PLAN')
				{
                    
					plans = oitem.Product2.ExternalId;
					pquan = Integer.valueOf(oitem.Quantity);
					qtyChanged=null;
					planDisplayQuantity=true;
					if(oitem.PricebookEntry.chargebeeapps__Setup_Cost__c!=null) {
						planHasSetupCost=true;
						planSetupCost=String.valueOf(oitem.PricebookEntry.chargebeeapps__Setup_Cost__c);
					}
					CbPriceBookEntry();

					if(oitem.product2.chargebeeapps__Recurring_charge_model__c=='QUANTITY'
					   ||oitem.product2.chargebeeapps__Recurring_charge_model__c=='PER_UNIT') {
						planPrice=String.valueOf(oitem.UnitPrice);
					}
					else if(oitem.product2.chargebeeapps__Recurring_charge_model__c=='FLAT_FEE') {
						planDisplayQuantity=false;
						planPrice=String.valueOf(oitem.UnitPrice);
					}
                    System.debug('*** AutoFill Plan ' + plans + ' Plan Quantity ' + pquan + ' PlanPrice ' + planPrice);
				}
				else{
					addonId=addonCount;
					AddonObject temp = new AddonObject(oitem.Product2.ExternalId,Integer.valueOf(oitem.Quantity),addonCount++,0,true);
					temp.setStatus(3);
					selList.add(temp);
					values=selList.size();
					CbPriceBookEntryAddon();
                    System.debug('*** AutoFill Addon ' + temp + ' TotalAddon ' + values );
				}
			}
		}
		//autofill code ends
	}

	AddonObject ax = new AddonObject('-1',1,1,0,false,2);
	selList.add(ax);
    System.debug('SelList initialization ' + selList);
	optionsCountry = ChargebeeUtil.getCountrySelectOptions();
}

}