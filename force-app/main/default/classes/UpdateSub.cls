public with sharing class UpdateSub {

public Map<String,Object> mp {get; set;}
public BaseEstimateController cont {get; set;}
public String sfId {get; set;}

public String oldPlan {get; set;}
public String oldPlanCur {get; set;}
public Integer oldPlanQuan {get; set;}
public String oldPlanPrice {get; set;}
public boolean planOverridePriceType {get; set;}
//Added to retain overriden price
public String oldPlanBackup {get; set;}
public String oldPlanPriceBackup {get; set;}

public String ponum {get; set;}
public String bCycle {get; set;}
public String coupId {get; set;}
public boolean invNow {get; set;}
public boolean immd {get; set;}
public boolean prorate {get; set;}

public boolean multiCn {get; set;}
public boolean showPopup {get; set;}
public List<SelectOption> optionsInvoiceNow {get; set;}
public List<SelectOption> renewalOpts {get; set;}
public String sltdCoup {get; set;}
public List<AddonResp> addons {get; set;}
public Integer values {get; set;}


public BaseError errObj {get; set;}

public BaseError apierrObj {get; set;}
public CB_Subscription__c sub {get; set;}
public CBURLUtil urlUtil {get; set;}

public InvEstimate ie {get; set;}
public InvEstimate iie {get; set;}
public List<CreditNoteEstimate> cne {get; set;}
public List<UnbilledEstimate> ue {get; set;}
public List<CBProd> se {get; set;}
public String style {get; set;}
public String nstyle {get; set;}
public List<String> dispTxt {get; set;}
public String tabStyle1 {get; set;}
public String tabStyle2 {get; set;}
public List<SelectOption> addonOptions {get; set;}
public boolean tab1 {get; set;}
public String pname {get; set;}
public Integer val {get; set;}
public List<String> tab {get; set;}
public boolean swapObj {get; set;}
public String oldStatus {get; set;}
public String newStatus {get; set;}
public String subText {get; set;}
public Integer addonSize {get; set;}

public string CbPriceBookEntry {get; set;}
public integer addonId {get; set;}

public integer addonqty {get; set;}
public decimal addonprice {get; set;}
public boolean displayTiers {get; set;}

public boolean displaytiericonplan {get; set;}
public boolean showUnit {get; set;}
public string addontrigger {get; set;}
public string qtyChanged {get; set;}
public List<Map<String,Object> > tierdata {get; set;}
public List<Map<String,Object> > tierdataAddon {get; set;}
public String domain {get; set;}
public String curCode {get; set;}
public String sid {get; set;}
public Map<String, Object> sf_to_cb_mapping {get; set;}
public Map<String, Object> sf_to_cb_values {get; set;}
public Boolean isMultiCurrencyEnabled {
	get {
		return UIUtil.isMultiCurrencyEnabled();
	} set;
}
public List<SelectOption> planOpts {
	get
	{
		planOpts = new List<SelectOption>();
		if(isMultiCurrencyEnabled) {
			planOpts=CBSubscriptionUtil.getProductSelectOptions('PLAN',sId,curCode);
		}else{
			planOpts=CBSubscriptionUtil.getProductSelectOptions('PLAN',sId,null);
		}
		planOpts.remove(0);//no need for select option
		return planOpts;
	}
	set;
}

public Boolean canOverride {
	get {
		return urlUtil.canOverRide();
	} set;
}

public List<SelectOption> coupenOptions {get; set;}

public Map<String,String> PlanExternalIdVsChargeModel {get; set;}

public String JsonMap {get {
			       JsonMap = JSON.serialize(PlanExternalIdVsChargeModel);
			       return JsonMap;
		       } set;}

public UpdateSub(){
	displayTiers = false;
	qtyChanged =null;
	planOverridePriceType=true;
	displaytiericonplan = false;
	system.debug('pre populated plan '+oldPlan);
	sfId=ApexPages.currentPage().getParameters().get('sub_id');
	if(isMultiCurrencyEnabled) {
		sub = Database.query('select Id,chargebeeapps__CB_Oppurtunity__c ,chargebeeapps__CB_Subscription_Id__c,chargebeeapps__CB_Site__c,CurrencyIsoCode from CB_Subscription__c where Id=:sfId');
	}else{
		sub = [select Id,chargebeeapps__CB_Oppurtunity__c,chargebeeapps__CB_Subscription_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__Subscription_Plan__r.chargebeeapps__Currency__c from CB_Subscription__c where Id=:sfId];
	}
	sid = sub.chargebeeapps__CB_Site__c;
	if(isMultiCurrencyEnabled) {
		curCode=(String)sub.get('CurrencyIsoCode');
	}else{
		curCode=sub.chargebeeapps__Subscription_Plan__r.chargebeeapps__Currency__c;
	}
	domain = SiteUtil.getSiteName(sub.chargebeeapps__CB_Site__c);
	System.debug('domain--'+domain);
	//custom field mapping handling start
	if(sub.chargebeeapps__CB_Oppurtunity__c!=null) {
		sf_to_cb_mapping=CBCustomFieldMappingUtil.getFieldMapping(domain);
		sf_to_cb_values=CBCustomFieldMappingUtil.getCustomFieldDataForSubscription(sub.chargebeeapps__CB_Oppurtunity__c,sf_to_cb_mapping);
	}
	//custom field mapping handling ends
	constructProductMap();
	constructCouponList();
	constructAddonList();
	if(sub.chargebeeapps__CB_Site__c!=null) {
		urlUtil = new CBURLUtil(domain);
	}else{
		urlUtil = new CBURLUtil();
	}

	pname='UpdateSubPreview';
	//basic validation
	sfId=ApexPages.currentPage().getParameters().get('sub_id');

	if(sub.chargebeeapps__CB_Subscription_Id__c==null) {
		errObj = new BaseError('This subscription is not present in Chargebee.');
	}else{

		//Fetching the subscription from CB
		EndPoint ep=EndPointsIndex.retrieve_sub_url;
		if(sub.chargebeeapps__CB_Site__c!=null) {

			ep.domainName(domain);
		}
		List<String> lst = new List<String>();
		lst.add(EncodingUtil.urlEncode(sub.chargebeeapps__CB_Subscription_Id__c,'UTF-8'));
		ep.replace(lst);
		URLBuilder ub = new URLBuilder(ep);

		cont = new RetSubController(ub);
		try{
			mp = cont.makeRequest();

		}catch(Exception e) {
			errObj = new BaseError(e.getMessage());
		}
		if(mp!=null) {
			errObj = new BaseError(mp);
		}

		//Parse and populate
		if(!errObj.isErr) {
			SubRespObj subResp = new SubRespObj((Map<String,Object>)mp.get('subscription'));
			populateExistingData(subResp);
			coupId=subResp.getCouponId();
			if(coupId!=null) {
				coupenOptions=removeElementFromlist(coupId,coupenOptions);
			}
			addons = subResp.getAddonObj();
			if(addons==null) {
				addons=new List<AddonResp>();
			}else{

				for(AddonResp updateSAddon:addons) {
					String addonName=updateSAddon.Id;
					if(PlanExternalIdVsChargeModel.containsKey(addonName+'_CHARGE_MODEL'))
					{
						String planType=PlanExternalIdVsChargeModel.get(addonName+'_CHARGE_MODEL');
						if(planType != null && (planType.equalsIgnoreCase('Tiered') ||
						                        planType.equalsIgnoreCase('StairStep')))
						{
							List<Map<string,object> > tierdata = getTierMetric(addonName,planType,updateSAddon.quan);
							if(tierdata!= null && !tierdata.isEmpty())
							{
								if(planType.equalsIgnoreCase('Tiered'))
								{
									updateSAddon.displaytier=true;
								}
								updateSAddon.tierdata = tierdata;
								tierdataAddon = updateSAddon.tierdata;
							}
						}
					}
				}
			}
			addons.add(new AddonResp('-1',1,0,false,1,addons.size()));
			addonSize = addons.size();
			optionsInvoiceNow = new List<SelectOption>();
			optionsInvoiceNow.add(new SelectOption('true','Invoice now'));
			optionsInvoiceNow.add(new SelectOption('false','Add to unbilled charges'));
			renewalOpts = new List<SelectOption>();
			renewalOpts.add(new SelectOption('false','Immediately'));
			renewalOpts.add(new SelectOption('true','On next Renewal'));


			//initialize form input variables with defaults
			sltdCoup='-1';
			invNow=true;
			immd=false;
			tab1=true;
			style = 'cb-status';
			nstyle= 'cb-status';
			dispTxt=new List<String>();
			tabStyle1='cb-btn cb-btn--selected';
			tabStyle2='cb-btn cb-btn--righttab';
			pname='UpdateSubPreview';
			val=0;
			multiCn=false;
			tab = new List<String>(5);
			swapObj=false;

		}

	}
	system.debug('displaytiericonplan'+displaytiericonplan);
}

public PageReference saveAddons(){
	Integer i = values;
	AddonResp ax = new AddonResp('-1',1,0,false,1,i+1);
	addons.add(ax);
	addonSize = addons.size();
	AddonResp old = addons.get(i);
	old.setStatus(1);
	return null;
}

public PageReference delAddons(){
	Integer i = values;
	AddonResp old = addons.get(i);
	old.setStatus(2);
	return null;
}

private void populateExistingData(SubRespObj subResp){
	planOverridePriceType=true;
	displaytiericonplan = false;
	oldPlan=subResp.getPlanId();
	oldPlanBackup=oldPlan;
	system.debug('oldPlan '+oldPlan);
	PricebookEntry prod = new PricebookEntry();
	prod = [Select id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, product2.chargebeeapps__Currency__c From PricebookEntry where Product2.ExternalId =:oldPlan and Pricebook2.chargebeeapps__CB_Site__c=:sub.chargebeeapps__CB_Site__c and product2.chargebeeapps__Status__c='ACTIVE' and product2.chargebeeapps__Product_Type__c='PLAN'];
	if(prod.Product2.chargebeeapps__Recurring_charge_model__c == 'TIERED'||prod.Product2.chargebeeapps__Recurring_charge_model__c == 'STAIRSTEP')
	{
		displaytiericonplan = true;
	}
	if(prod.Product2.chargebeeapps__Recurring_charge_model__c == 'TIERED'
	   ||prod.Product2.chargebeeapps__Recurring_charge_model__c == 'STAIRSTEP'
	   ||prod.Product2.chargebeeapps__Recurring_charge_model__c == 'VOLUME') {
		planOverridePriceType=false;
	}
	oldPlanCur=subResp.getCurCode();
	oldPlanPrice=String.ValueOf(subResp.getPlanUnitPrice());
	oldPlanPriceBackup=oldPlanPrice;//retain the overriden value
	PlanExternalIdVsChargeModel.put(oldPlan+'_UNIT_PRICE',String.valueOf(oldPlanPrice));
	oldPlanQuan=subResp.getPlanQuan();
	oldStatus=subResp.getStatus();
	system.debug('default value '+planOverridePriceType);
}


private void constructProductMap(){
	List<PricebookEntry> prodList = new List<PricebookEntry>();
	if(!isMultiCurrencyEnabled) {
		prodList = [Select id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, product2.chargebeeapps__Currency__c From PricebookEntry where Pricebook2.chargebeeapps__CB_Site__c=:sub.chargebeeapps__CB_Site__c and product2.chargebeeapps__Status__c='ACTIVE' and (product2.chargebeeapps__Product_Type__c='PLAN' or product2.chargebeeapps__Product_Type__c='ADDON') and product2.chargebeeapps__Currency__c=:curCode limit 2000];
	}else{
		prodList = Database.query('Select id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, PricebookEntry.CurrencyIsoCode From PricebookEntry  where Pricebook2.chargebeeapps__CB_Site__c=:sid and product2.chargebeeapps__Status__c=\'ACTIVE\' and (product2.chargebeeapps__Product_Type__c=\'PLAN\' or product2.chargebeeapps__Product_Type__c=\'ADDON\') and PricebookEntry.CurrencyIsoCode=:curCode limit 2000');
	}

	PlanExternalIdVsChargeModel = new Map<String,String>();

	for(PricebookEntry temp : prodList)
	{
		if(temp.Product2.chargebeeapps__Product_Type__c == 'PLAN' && temp.Product2.ExternalId!= null)
		{
			PlanExternalIdVsChargeModel.put(temp.Product2.ExternalId+'_CHARGE_MODEL',temp.Product2.chargebeeapps__Recurring_charge_model__c);

		}
		else if(temp.Product2.chargebeeapps__Product_Type__c == 'ADDON' && temp.Product2.ExternalId!= null
		        && temp.Product2.chargebeeapps__Addon_Type__c != null ) {
			PlanExternalIdVsChargeModel.put(temp.Product2.ExternalId+'_CHARGE_MODEL',temp.Product2.chargebeeapps__Addon_Type__c);
		}
		PlanExternalIdVsChargeModel.put(temp.Product2.ExternalId+'_UNIT_PRICE',String.valueOf(temp.UnitPrice));

		if( temp.chargebeeapps__Setup_Cost__c != null ) {
			PlanExternalIdVsChargeModel.put(temp.Product2.ExternalId+'_SETUP_COST',String.valueOf(temp.chargebeeapps__Setup_Cost__c));
		}
		if(isMultiCurrencyEnabled) {
			if( temp.get('CurrencyIsoCode')!= null ) {
				PlanExternalIdVsChargeModel.put(temp.Product2.ExternalId+'_CURRENCY',String.valueOf(temp.get('CurrencyIsoCode')));
			}
		}else{
			if( temp.Product2.chargebeeapps__Currency__c!= null ) {
				PlanExternalIdVsChargeModel.put(temp.Product2.ExternalId+'_CURRENCY',String.valueOf(temp.Product2.chargebeeapps__Currency__c));
			}
		}
	}
}

private void constructCouponList(){
	coupenOptions = chargebeeapps.UIUtil.getCouponOptions(sub.chargebeeapps__CB_Site__c);
}

private void constructAddonList(){
	if(isMultiCurrencyEnabled) {
		addonOptions = CBSubscriptionUtil.getProductSelectOptions('ADDON',sub.chargebeeapps__CB_Site__c,curCode);
	}else{
		addonOptions = CBSubscriptionUtil.getProductSelectOptions('ADDON',sub.chargebeeapps__CB_Site__c,null);
	}
}

public PageReference preview(){
	showPopup=true;
	updateStyleClass(0);
	populate();
	return null;
}

private String addonURL(String bodyData){
	for(Integer i=0,j=0,k=0; i<addons.size(); i++) {
		AddonResp temp_add_obj = addons.get(i);
		if(temp_add_obj.status==1 && temp_add_obj.Id!='-1') {
			bodyData = CBURLUtil.buildURLString(bodyData,'addons[id]['+j+']',temp_add_obj.Id);


			if(PlanExternalIdVsChargeModel != null && PlanExternalIdVsChargeModel.get(temp_add_obj.Id + '_CHARGE_MODEL') != null && (PlanExternalIdVsChargeModel.get(temp_add_obj.Id + '_CHARGE_MODEL') == 'PER_UNIT'||PlanExternalIdVsChargeModel.get(temp_add_obj.Id + '_CHARGE_MODEL') == 'QUANTITY') && temp_add_obj.quan>0) {
				bodyData = CBURLUtil.buildURLString(bodyData,'addons[quantity]['+j+']',String.valueOf(temp_add_obj.quan));
			}
			else{
				bodyData = CBURLUtil.buildURLString(bodyData,'addons[quantity]['+j+']',String.valueOf(temp_add_obj.quan));
			}
			if(canOverRide && temp_add_obj.uPrice != null && temp_add_obj.canOverridePrice) {
				bodyData = CBURLUtil.buildURLString(bodyData,'addons[unit_price]['+j+']',String.valueOf(ChargebeeUtil.convertToLowerOrderCurrency(oldPlanCur, Double.valueOf(String.valueOf(temp_add_obj.uPrice)))));
			}
			j++;

		}else if(temp_add_obj.status==2 && temp_add_obj.exist) {
			if(k==0) {
				bodyData = CBURLUtil.buildURLString(bodyData,'replace_addon_list','true');
			}
			k++;
		}
	}
	return bodyData;

}
public boolean canOverridePrice(String planId){
	if(planId != '-1') {
		PricebookEntry selectedProduct = new PricebookEntry();
		selectedProduct = [Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice,product2.chargebeeapps__Currency__c From PricebookEntry where Product2.ExternalId =:planId And Pricebook2.chargebeeapps__CB_Site__c=:sub.chargebeeapps__CB_Site__c and product2.chargebeeapps__Status__c='ACTIVE' and (product2.chargebeeapps__Product_Type__c='PLAN' or product2.chargebeeapps__Product_Type__c='ADDON')];
		String plantype=selectedProduct.product2.chargebeeapps__Recurring_charge_model__c;
		return !(plantype=='Tiered' || plantype=='Stairstep' || plantype=='Volume');
	}
	return true;
}
public void populate(){
	//url building.....
	clearSetData();
	EndPoint ep = EndPointsIndex.cart_est_url;
	if(sub.chargebeeapps__CB_Site__c!=null) {
		ep.domainName(domain);
	}
	List<String> liststr = new List<String>();
	liststr.add(EncodingUtil.urlEncode(sub.chargebeeapps__CB_Subscription_Id__c,'UTF-8'));
	ep.replace(liststr);
	UpdateSubUrlBuilder br = new UpdateSubUrlBuilder(ep);
	System.debug('invNow---'+invNow);
	br.planId(oldPlan).prorate(String.valueOf(prorate)).endOfTerm(String.valueOf(immd)).invoiceImmediately(String.valueOf(invNow));
	if(bCycle!=null) {
		br.billingCycles(bCycle);
	}
	if(ponum!=null) {
		br.poNum(ponum);
	}
	if(oldPlanQuan!=null && !isFlatPlan(oldPlan)) {
		br.planQuan(String.valueOf(oldPlanQuan));
	}
	if(sltdCoup!='-1') {
		br.couponId(sltdCoup);
	}

	if(canOverride) {
		if(oldPlanPrice!= null && canOverridePrice(oldPlan)) {
			try{
				br.planUnitPrice(String.valueOf(ChargebeeUtil.convertToLowerOrderCurrency(oldPlanCur,Double.valueOf(oldPlanPrice))));
			}
			catch(Exception e) {
				apierrObj = new BaseError();
				apierrObj.setError(e.getMessage());
				showPopup=false;
				return;
			}
		}
	}
	br.ustring = addonURL(br.ustring);
	UpdateSubEstController ctllr = new UpdateSubEstController(br);
	//making request through controller.
	mp=ctllr.makeRequest();

	ue = getUpdateSubEstimate();
	if(ue!=null) {
		addToDisplayText('unbilled_charge_estimates',0);
	}

	apierrObj = new BaseError(mp);
	if(apierrObj.isErr) {
		showPopup=false;
		return;
	}
	UpdateSubEstResponse resp = new UpdateSubEstResponse(mp);

	iie = resp.getNextInvEst('immediate_invoice_estimate');
	if(iie!=null) {
		addToDisplayText('immediate_invoice_estimate',iie.tot);
	}else{
		addToDisplayText('immediate_invoice_estimate',0);
	}

	ie = resp.getNextInvEst('next_invoice_estimates');
	if(ie!=null) {
		addToDisplayText('next_invoice_estimates',ie.tot);
	}
	se=resp.getSubEstimate(ie.cc,sub.chargebeeapps__CB_Site__c);
	cne = resp.getCreditEst();
	if(cne!=null) {
		multiCn = cne.size()>1;
		if(multiCn) {
			addToDisplayText('credits',getCNTotal(cne));
		}else{
			addToDisplayText('credits',cne[0].tot);
		}


	}
	if(ie==null && iie==null && cne==null) {
		apierrObj = new BaseError();
		apierrObj.setError('There is no change in subscription.');
		showPopup=false;
		return;
	}
	//se.getStyleClass()

}

private void addToDisplayText(String key,Double amt){
	if(key=='immediate_invoice_estimate') {
		if(amt!=0) {
			dispTxt.add('An invoice for '+iie.cc+' '+amt+' will be generated immediately.');
		}else{
			dispTxt.add('There will be no immediate charges.');
		}
	}else if(key=='next_invoice_estimates') {
		dispTxt.add('Subsequent invoice for '+ie.cc+' '+amt+' will be generated upon renewal.');
	}
	else if(key=='credits') {
		dispTxt.add(cne[0].typ.capitalize()+' credits worth '+cne[0].cc+' '+amt+' will be created and applied on the immediate invoice.');
	}else if(key=='unbilled_charge_estimates') {
		Double a=getTotal(ue);
		dispTxt.add('A charge of '+ue[0].cc+' '+a+' will be added to the unbilled charges.');
	}

}

public static Double getTotal(List<UnbilledEstimate> unbilld){
	Double tot = 0;
	for(UnbilledEstimate u:unbilld) {
		tot += u.amount;
	}
	return tot;
}

public static Double getCNTotal(List<CreditNoteEstimate> unbilld){
	Double tot = 0;
	for(CreditNoteEstimate u:unbilld) {
		tot += u.tot;
	}
	return tot;
}

private List<SelectOption> removeElementFromlist(String Id,List<SelectOption> lst){
	Integer l = lst.size();
	List<SelectOption> updatedList = new List<SelectOption>();
	for(Integer i=0; i<l; i++) {
		SelectOption s = lst.get(i);
		if(!s.getValue().equals(Id)) {
			updatedList.add(s);
		}
	}
	return updatedList;
}


public PageReference invoke(){
	Integer tn = val;
	InvEstimate temp;
	if(tn==0) {
		pname='UpdateSubPreview';

	}else if(tn==1) {
		pname='Credits';

	}else if(tn==2) {
		pname='ImmediateCharges';
	}else if(tn==3) {
		pname='UnbilledCharges';
	}else if(tn==4) {
		pname='NextRenewalChanges';
	}
	updateStyleClass(tn);
	return null;
}



private void updateStyleClass(Integer t){
	tab[t]='cb-btn cb-btn--selected';
	for(Integer i=0; i<tab.size(); i++) {
		if(i!=t) {
			tab[i]='cb-btn cb-btn--normaltab';
		}
	}
}



public PageReference back(){
	return new PageReference('/'+sfId);
}
public PageReference cancel(){
	showPopup=false;
	pname='UpdateSubPreview';
	clearSetData();
	return null;
}

public void clearSetData(){
	dispTxt.clear();
	ie=null;
	iie=null;
	cne=null;
	ue=null;
}


private List<UnbilledEstimate> getUpdateSubEstimate(){
	EndPoint ep = EndPointsIndex.update_est_url;
	if(sub.chargebeeapps__CB_Site__c!=null) {
		ep.domainName(domain);
	}
	UpdateSubEstUrlBuilder br = new UpdateSubEstUrlBuilder(ep);
	System.debug('invNow---'+invNow);
	br.Id(sub.chargebeeapps__CB_Subscription_Id__c).planId(oldPlan).prorate(String.valueOf(prorate)).endOfTerm(String.valueOf(immd)).invoiceImmediately(String.valueOf(invNow));
	if(bCycle!=null) {
		br.billingCycles(bCycle);
	}
	if(ponum!=null) {
		br.poNum(ponum);
	}
	if(oldPlanQuan!=null && !isFlatPlan(oldPlan)) {
		br.planQuan(String.valueOf(oldPlanQuan));
	}
	if(sltdCoup!='-1') {
		br.couponId(sltdCoup);
	}

	if(canOverride) {
		if(oldPlanPrice!= null && canOverridePrice(oldPlan)) {
			try{
				br.planUnitPrice(String.valueOf(ChargebeeUtil.convertToLowerOrderCurrency(oldPlanCur,Double.valueOf(oldPlanPrice))));
			}
			catch(Exception e) {
				apierrObj = new BaseError();
				apierrObj.setError(e.getMessage());
				showPopup=false;
				return null;
			}
		}
	}
	br.ustring = addonURL(br.ustring);
	UpdateSubEstController ctllr = new UpdateSubEstController(br);
	Map<String,Object> mptemp=ctllr.makeRequest();
	UpdateSubEstResponse ures = new UpdateSubEstResponse(mptemp);
	newStatus = ures.getNewStatus();
	setSubText(oldStatus,newStatus);
	return ures.getUnbilledEst();
}

public void setSubText(String a,String b){
	style=SubEst.getStyleClass(a,style);
	if(a!=null && b!=null) {
		if(a.equals(b)) {
			subText='will remain as';
			newStatus=null;
		}else{
			subText='will be changed from ';
			nstyle=SubEst.getStyleClass(b,nstyle);
		}
	}else{
		subText='will remain as';
		newStatus=null;
	}

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

public PageReference updateSub(){

	EndPoint ep = EndPointsIndex.update_sub_url;
	if(sub.chargebeeapps__CB_Site__c!=null) {
		ep.domainName(domain);
	}
	List<String> liststr = new List<String>();
	liststr.add(EncodingUtil.urlEncode(sub.chargebeeapps__CB_Subscription_Id__c,'UTF-8'));
	ep.replace(liststr);
	UpdateSubscriptionUrlBuilder br = new UpdateSubscriptionUrlBuilder(ep);

	br.planId(oldPlan).prorate(String.valueOf(prorate)).endOfTerm(String.valueOf(immd)).invoiceImmediately(String.valueOf(invNow));
	if(bCycle!=null) {
		br.billingCycles(bCycle);
	}
	if(ponum!=null) {
		br.poNum(ponum);
	}
	if(oldPlanQuan!=null && !isFlatPlan(oldPlan)) {
		br.planQuan(String.valueOf(oldPlanQuan));
	}
	if(sltdCoup!=null && sltdCoup!='-1') {
		br.couponId(sltdCoup);
	}

	if(canOverride) {
		if(oldPlanPrice!= null && canOverridePrice(oldPlan)) {
			try{
				br.planUnitPrice(String.valueOf(ChargebeeUtil.convertToLowerOrderCurrency(oldPlanCur,Double.valueOf(oldPlanPrice))));
			}
			catch(Exception e) {
				apierrObj = new BaseError();
				apierrObj.setError(e.getMessage());
				showPopup=false;
				return null;
			}
		}
	}
	br.ustring = addonURL(br.ustring);
	//custom field mapping handling start
	if(sub.chargebeeapps__CB_Oppurtunity__c!=null) {
		sf_to_cb_mapping=CBCustomFieldMappingUtil.getFieldMapping(domain);
		sf_to_cb_values=CBCustomFieldMappingUtil.getCustomFieldDataForSubscription(sub.chargebeeapps__CB_Oppurtunity__c,sf_to_cb_mapping);
		if(sf_to_cb_values!=null) {
			Iterator<String> it=sf_to_cb_values.keySet().iterator();
			while(it.hasNext()) {
				String fieldName=it.next();
				if(sf_to_cb_values.get(fieldName)+''!=CBCustomFieldMappingUtil.NO_VALUE_SET)
					br.ustring = CBURLUtil.buildURLString(br.ustring, fieldName, sf_to_cb_values.get(fieldName)+'');
			}
		}
	}
	//custom field mapping handling ends
	UpdateSubController bctrl = new UpdateSubController(br);
	mp=bctrl.makeRequest();
	apierrObj = new BaseError(mp);
	if(apierrObj.isErr) {
		showPopup=false;
		clearSetData();
		return null;
	}

	String sub_id = sub.chargebeeapps__CB_Subscription_Id__c;
	String bodyData='';
	bodyData = CBURLUtil.buildURLString(bodyData,'entity_id',sub_id);
	if(sub_id != null && sub_id != '')
	{

		String subSyncEndPoint = CBSubscriptionUtil.getSyncSubsEndPoint(urlUtil);
		bodyData = '';
		bodyData = CBURLUtil.buildURLString(bodyData,'id', sub_id);
		bodyData = CBURLUtil.buildURLString(bodyData,'api_key',urlUtil.getApiKey());
		try
		{
			String responseFromNet = CBURLUtil.sendRequest(subSyncEndPoint, bodyData, urlUtil, true);

		}catch(Exception exp) {
			System.debug('exception '+exp);
		}


	}
	return back();

}

public PageReference CbPriceBookEntry()
{
	planOverridePriceType=true;
	CbPriceBookEntry = oldPlan;

	if(oldPlan != '-1') {

		displaytiericonplan = true;
		PricebookEntry selectedProduct = new PricebookEntry();
		if(isMultiCurrencyEnabled) {
			selectedProduct = Database.query('Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice,PricebookEntry.CurrencyIsoCode From PricebookEntry  where Product2.ExternalId =:oldPlan And Pricebook2.chargebeeapps__CB_Site__c=:sid and product2.chargebeeapps__Status__c=\'ACTIVE\' and (product2.chargebeeapps__Product_Type__c=\'PLAN\' or product2.chargebeeapps__Product_Type__c=\'ADDON\')');
			oldPlanCur = (String)selectedProduct.get('CurrencyIsoCode');
		}else{
			selectedProduct = [Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice,product2.chargebeeapps__Currency__c From PricebookEntry where Product2.ExternalId =:oldPlan And Pricebook2.chargebeeapps__CB_Site__c=:sub.chargebeeapps__CB_Site__c and product2.chargebeeapps__Status__c='ACTIVE' and (product2.chargebeeapps__Product_Type__c='PLAN' or product2.chargebeeapps__Product_Type__c='ADDON')];
			oldPlanCur = selectedProduct.product2.chargebeeapps__Currency__c;
		}
		string planType = selectedProduct.product2.chargebeeapps__Recurring_charge_model__c;
		string pbId = string.valueOf(selectedProduct.Id);
		if(qtyChanged!='changed')
		{
			oldPlanPrice = string.valueOf(selectedProduct.UnitPrice);
		}

		if(selectedProduct.product2.chargebeeapps__Recurring_charge_model__c != 'TIERED' && selectedProduct.product2.chargebeeapps__Recurring_charge_model__c != 'STAIRSTEP')
		{
			displaytiericonplan = false;
		}
		if(plantype != null && ( plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')||plantype.equalsIgnoreCase('Volume')))
		{
			planOverridePriceType=false;
			
			List<chargebeeapps__CB_Pricing_Tiers__c> CBPriceBookEntries = new List<chargebeeapps__CB_Pricing_Tiers__c>();
			CBPriceBookEntries =[Select Id,Name,chargebeeapps__PriceBookEntryId__c,chargebeeapps__ExternalId__c,chargebeeapps__Lower_Limit__c, chargebeeapps__Upper_Limit__c,chargebeeapps__Price__c From chargebeeapps__CB_Pricing_Tiers__c Where chargebeeapps__PriceBookEntryId__c=:pbId and chargebeeapps__ExternalId__c =:selectedProduct.Product2.ExternalId ORDER BY chargebeeapps__Lower_Limit__c ASC];
			showUnit = plantype.equalsIgnoreCase('Tiered');
			tierdata=getTierMetric(selectedProduct.product2.ExternalId,planType,oldPlanQuan);

			oldPlanPrice = string.valueOf(ProductService.getPrice(planType, CBPriceBookEntries, oldPlanQuan));
			if(oldPlanQuan == 0 || oldPlanQuan == null)
			{
				displaytiericonplan =false;
			}
		}
        //retain logic
        if((planType.equalsIgnoreCase('per_unit')||planType.equalsIgnoreCase('flat_fee')) && oldPlan==oldPlanBackup){
            oldPlanPrice=oldPlanPriceBackup;
         }
		qtyChanged =null;
	}
	return null;
}
public PageReference CbPriceBookEntryAddon()
{
	tierdataAddon = new List<Map<String,Object> >();
	AddonResp selectedAddon=addons.get(addonId);
	String addonName=selectedAddon.Id;
	selectedAddon.displaytiericon=false;
	addonqty = selectedAddon.quan;
	if(addonName != null && addonName !='-1') {
		PricebookEntry selectedProduct = new PricebookEntry();
		if(isMultiCurrencyEnabled) {
			selectedProduct = Database.query('Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, PricebookEntry.CurrencyIsoCode From PricebookEntry  where Product2.ExternalId =:addonName And Pricebook2.chargebeeapps__CB_Site__c=:sid and product2.chargebeeapps__Status__c=\'ACTIVE\' and product2.chargebeeapps__Product_Type__c=\'ADDON\'');
			selectedAddon.addonCurrency = (String)selectedProduct.get('CurrencyIsoCode');
		}else{
			selectedProduct = [Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice,product2.chargebeeapps__Currency__c From PricebookEntry where Product2.ExternalId =:addonName And Pricebook2.chargebeeapps__CB_Site__c=:sub.chargebeeapps__CB_Site__c and product2.chargebeeapps__Status__c='ACTIVE' and product2.chargebeeapps__Product_Type__c='ADDON'];
			selectedAddon.addonCurrency = selectedProduct.product2.chargebeeapps__Currency__c;
		}

		string pbId = string.valueOf(selectedProduct.Id);
		String plantype=selectedProduct.product2.Addon_Type__c;
		selectedAddon.model=plantype;

		if(plantype == null || plantype.equalsIgnoreCase('Flat_Fee') || plantype.equalsIgnoreCase('per_unit')||plantype.equalsIgnoreCase('quantity'))
		{
			if(qtyChanged!='changed')
			{
				selectedAddon.uPrice = selectedProduct.UnitPrice;
			}
		}
		if(plantype != null && ( plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')||plantype.equalsIgnoreCase('Volume')))
		{

			List<chargebeeapps__CB_Pricing_Tiers__c> pricingTiers = ProductService.getPricingTiers(pbId);

			if(plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep'))
			{
				tierdataAddon=chargebeeapps.UIUtil.getTierMetric(pbId, plantype,addonqty, pricingTiers);
				if(tierdataAddon != null & !tierdataAddon.isEmpty())
				{
					selectedAddon.tierdata=tierdataAddon;
				}
			}
			selectedAddon.uPrice = double.valueOf(ProductService.getPrice(planType, pricingTiers, addonqty));
		}
		qtyChanged =null;
	}
	return null;
}



public List<Map<String,Object> > getTierMetric(String extId,String plantype,Integer quantity)
{
	PricebookEntry getPlan = [Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice,product2.chargebeeapps__Currency__c From PricebookEntry where Product2.ExternalId =:extId And Pricebook2.chargebeeapps__CB_Site__c=:sub.chargebeeapps__CB_Site__c and product2.chargebeeapps__Status__c='ACTIVE' and (product2.chargebeeapps__Product_Type__c='PLAN' or product2.chargebeeapps__Product_Type__c='ADDON')];
	string pbId = string.valueOf(getPlan.Id);

	List<chargebeeapps__CB_Pricing_Tiers__c> CBPriceBookEntries =[Select Id,Name,chargebeeapps__PriceBookEntryId__c,chargebeeapps__ExternalId__c,chargebeeapps__Lower_Limit__c, chargebeeapps__Upper_Limit__c,chargebeeapps__Price__c From chargebeeapps__CB_Pricing_Tiers__c Where chargebeeapps__PriceBookEntryId__c=:pbId and chargebeeapps__ExternalId__c=:extId ORDER BY chargebeeapps__Lower_Limit__c ASC];

	return chargebeeapps.UIUtil.getTierMetric(pbId, plantype,quantity);
}
}