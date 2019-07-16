public with sharing class CreateQuoteForUpdateSubscription {

public BaseEstimateController cont {get; set;}
public String sfId {get; set;}
public String oldPlan {get; set;}
public String oldPlanCur {get; set;}
public Integer oldPlanQuan {get; set;}
public String oldPlanPrice {get; set;}
public boolean planOverridePriceType {get; set;}
public String bCycle {get; set;}
public String coupId {get; set;}
public boolean multiCn {get; set;}
public String sltdCoup {get; set;}
public List<AddonResp> addons {get; set;}
public Integer values {get; set;}
public BaseError errObj {get; set;}
public BaseError apierrObj {get; set;}
public CB_Subscription__c sub {get; set;}
public CBURLUtil urlUtil {get; set;}
public List<SelectOption> addonOptions {get; set;}
public Integer val {get; set;}
public boolean swapObj {get; set;}
public String oldStatus {get; set;}
public Integer addonSize {get; set;}
public string CbPriceBookEntry {get; set;}
public integer addonId {get; set;}
public integer addonqty {get; set;}
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
public List<SelectOption> coupenOptions {get; set;}
public Map<String,String> PlanExternalIdVsChargeModel {get; set;}

public Boolean isMultiCurrencyEnabled {
	get {
		return UIUtil.isMultiCurrencyEnabled();
	} set;
}
public List<SelectOption> planOpts {
	get
	{
		List<PricebookEntry> prodList = ProductService.getPlans(sub.chargebeeapps__CB_Site__c, curCode);
		return chargebeeapps.UIUtil.getPlanAddonOptions(prodList);
	}
	set;
}

public Boolean canOverride {
	get {
		return urlUtil.canOverRide();
	} set;
}


public String JsonMap {
	get {
		JsonMap = JSON.serialize(PlanExternalIdVsChargeModel);
		return JsonMap;
	}
	set;
}

public CreateQuoteForUpdateSubscription(){
	displayTiers = false;
	qtyChanged =null;
	planOverridePriceType=true;
	displaytiericonplan = false;
	sfId=ApexPages.currentPage().getParameters().get('sub_id');
	if(isMultiCurrencyEnabled) {
		sub = Database.query('select Id,chargebeeapps__CB_Subscription_Id__c,chargebeeapps__CB_Site__c,CurrencyIsoCode,chargebeeapps__CB_Oppurtunity__c, ' +
		                     'chargebeeapps__CustomerID__r.Id from CB_Subscription__c where Id=:sfId');
		curCode=(String)sub.get('CurrencyIsoCode');
	}else{
		sub = [select Id,chargebeeapps__CB_Subscription_Id__c,chargebeeapps__CB_Site__c,chargebeeapps__Subscription_Plan__r.chargebeeapps__Currency__c,
		       chargebeeapps__CB_Oppurtunity__c,chargebeeapps__CustomerID__r.Id
		       from CB_Subscription__c where Id=:sfId];
		curCode=sub.chargebeeapps__Subscription_Plan__r.chargebeeapps__Currency__c;
	}
	sid = sub.chargebeeapps__CB_Site__c;
	domain = SiteUtil.getSiteName(sub.chargebeeapps__CB_Site__c);
	constructProductMap();
	constructCouponList();
	constructAddonList();
	urlUtil = new CBURLUtil(domain);

	if(sub.chargebeeapps__CB_Subscription_Id__c==null) {
		errObj = new BaseError('This subscription is not present in Chargebee.');
	}else{
		EndPoint ep=EndPointsIndex.retrieve_sub_url;
		ep.domainName(domain);
		List<String> lst = new List<String>();
		lst.add(EncodingUtil.urlEncode(sub.chargebeeapps__CB_Subscription_Id__c,'UTF-8'));
		ep.replace(lst);
		URLBuilder ub = new URLBuilder(ep);

		cont = new RetSubController(ub);

		Map<String,Object> mp;
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
						String planname=PlanExternalIdVsChargeModel.get(addonName+'_CHARGE_MODEL');
						if(isNewPricingModel(planname)) {
							updateSAddon.canOverridePrice=false;
						}
						if(planname != null && (planname.equalsIgnoreCase('Tiered') ||
						                        planname.equalsIgnoreCase('StairStep')))
						{
							updateSAddon.displaytiericon=true;
							List<Map<string,object> > tierdata = chargebeeapps.UIUtil.getTierMetric(addonName,planname,updateSAddon.quan);
							if(tierdata!= null && !tierdata.isEmpty())
							{
								if(planname.equalsIgnoreCase('Tiered'))
								{
									updateSAddon.showUnit=true;
									updateSAddon.displaytier=true;
								}
								else{
									updateSAddon.showUnit=false;
								}

								updateSAddon.displaytiericon=true;
								updateSAddon.tierdata = tierdata;
								tierdataAddon = updateSAddon.tierdata;
							}
						}
					}
				}
			}
			addons.add(new AddonResp('-1',1,0,false,1,addons.size()));
			addonSize = addons.size();

			//initialize form input variables with defaults
			sltdCoup='-1';
			val=0;
			multiCn=false;
			swapObj=false;

		}

	}
}

public boolean isNewPricingModel(String type){
	return (type.equalsIgnoreCase('Tiered')||type.equalsIgnoreCase('StairStep')||type.equalsIgnoreCase('Volume'));
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
	PricebookEntry prod = [Select id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,
	                       product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, product2.chargebeeapps__Currency__c
	                       From PricebookEntry where Product2.ExternalId =:oldPlan and Pricebook2.chargebeeapps__CB_Site__c=:sub.chargebeeapps__CB_Site__c
	                    and product2.chargebeeapps__Status__c='ACTIVE' and product2.chargebeeapps__Product_Type__c='PLAN'];
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
	PlanExternalIdVsChargeModel.put(oldPlan+'_UNIT_PRICE',String.valueOf(oldPlanPrice));
	oldPlanQuan=subResp.getPlanQuan();
	oldStatus=subResp.getStatus();
}

private void constructProductMap(){
	PlanExternalIdVsChargeModel = chargebeeapps.UIUtil.getPlanExternalIdVsChargeModel(isMultiCurrencyEnabled, sub.chargebeeapps__CB_Site__c);
}

private void constructCouponList(){
	coupenOptions = UIUtil.getCouponOptions(sub.chargebeeapps__CB_Site__c);
}

private void constructAddonList(){
	List<PricebookEntry> prodList;
	if(isMultiCurrencyEnabled) {
		prodList = Database.query('Select id,Product2.ExternalId,product2.name,product2.chargebeeapps__Product_Type__c,PricebookEntry.CurrencyIsoCode From PricebookEntry  where Pricebook2.chargebeeapps__CB_Site__c=:sid and product2.chargebeeapps__Status__c=\'ACTIVE\' and product2.chargebeeapps__Product_Type__c=\'ADDON\' and PricebookEntry.CurrencyIsoCode=:curCode limit 500');
	}else{
		prodList = [Select id,Product2.ExternalId,product2.name,product2.chargebeeapps__Product_Type__c,product2.chargebeeapps__Currency__c From PricebookEntry where Pricebook2.chargebeeapps__CB_Site__c=:sub.chargebeeapps__CB_Site__c and product2.chargebeeapps__Status__c='ACTIVE' and product2.chargebeeapps__Product_Type__c='ADDON' and product2.chargebeeapps__Currency__c=:curCode limit 500];
	}
	addonOptions = chargebeeapps.UIUtil.getPlanAddonOptions(prodList);
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
		PricebookEntry selectedProduct = [Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,
		                                  product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,
		                                  PricebookEntry.UnitPrice,product2.chargebeeapps__Currency__c From PricebookEntry
		                                  where Product2.ExternalId =:planId And Pricebook2.chargebeeapps__CB_Site__c=:sub.chargebeeapps__CB_Site__c
		                                                                                                               and product2.chargebeeapps__Status__c='ACTIVE' and (product2.chargebeeapps__Product_Type__c='PLAN' or product2.chargebeeapps__Product_Type__c='ADDON')];
		String plantype=selectedProduct.product2.chargebeeapps__Recurring_charge_model__c;
		return !(plantype=='Tiered' || plantype=='Stairstep' || plantype=='Volume');
	}
	return true;
}

@TestVisible private static List<SelectOption> removeElementFromlist(String Id,List<SelectOption> lst){
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

public PageReference back(){
	return new PageReference('/'+sfId);
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

public PageReference createQuote(){

	EndPoint ep = EndPointsIndex.update_subscription_quote;
	if(sub.chargebeeapps__CB_Site__c!=null) {
		ep.domainName(domain);
	}
	CreateQuoteForUpdateSubUrlBuilder br = new CreateQuoteForUpdateSubUrlBuilder(ep);

	br.subscriptionId(sub.chargebeeapps__CB_Subscription_Id__c).planId(oldPlan);
	if(bCycle!=null) {
		br.billingCycles(bCycle);
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
				return null;
			}
		}
	}
	br.ustring = addonURL(br.ustring);
	System.debug('input'+br.ustring);

	GenericController bctrl = new GenericController(br);
	Map<String,Object> mp=bctrl.makeRequest();
	apierrObj = new BaseError(mp);
	if(!apierrObj.isErr) {
		QuoteObj quoteObj = new QuoteObj((Map<String, Object>)mp.get('quote'));
		String quoteId = quoteObj.getId();
		system.debug('quote_id'+quoteId);

		if(quoteId != null && quoteId != '')
		{
			try {
				List<chargebeeapps.AddonObject> addonObjects = new List<chargebeeapps.AddonObject>();
				for(AddonResp addon : addons) {
					if(addon.status==1 && addon.Id!='-1') {
						chargebeeapps.AddonObject addonObject = new chargebeeapps.AddonObject(addon.Id,
						                                                                      addon.quan, 0, addon.uPrice, addon.displayQuantity);
						addonObjects.add(addonObject);
					}
				}

				Opportunity opp = getOpportunity(sub.chargebeeapps__CB_Oppurtunity__c, quoteObj);
				chargebeeapps.PlanObject plan = new chargebeeapps.PlanObject(oldPlan, oldPlanQuan, Decimal.valueOf(oldPlanPrice), oldPlanCur, null);
				chargebeeapps__CB_Quote__c quote = QuoteService.saveNewQuote(quoteObj, opp, sub.chargebeeapps__CustomerID__r.Id,
				                                                             sub.chargebeeapps__CB_Site__c,
				                                                             domain,sltdCoup, plan, addonObjects, sub);

				String opportunityId = null;
				if(opp != null)
					opportunityId = opp.Id;

				QuoteService.saveToThirdPartyEntityMapping(quoteId, quote.Id, domain, opportunityId,JSON.serialize(mp.get('quote')));
				return page_redirect(quote.Id);

			}catch(Exception exp) {
				String responseFromNet = 'CB Exception '+exp;
			}
		}
	} else {
		return null;
	}
	return back();
}

private Opportunity getOpportunity(String existingOppId, QuoteObj quoteobj) {
	if(SiteUtil.doNotCreateOrUpdateOpportunity(sub.chargebeeapps__CB_Site__c))
		return null;

	if(existingOppId==null)
		return null;

	boolean useExistingOpportunity = !SiteUtil.createNewOpportunityOnUpdate(sub.chargebeeapps__CB_Site__c);

	Opportunity existingOpp = [select id,name,AccountId,chargebeeapps__Coupon__c,Pricebook2Id from Opportunity
				                   where Id=:existingOppId];
	if(useExistingOpportunity)
		return existingOpp;
	else {
		Account account = [Select Id, Name from Account where Id=:existingOpp.AccountId];
		Date closeDate = Datetime.newInstance(quoteobj.getValidTill()*1000).date();
		Opportunity opp = new Opportunity(
			Name = 'Update for ' + account.Name,
			StageName = getLowestNonZeroProbabilityStage(),
			CloseDate = closeDate,
			AccountId = account.Id
		);
		//TODO: default fields, record type
		return opp;
	}

}

@TestVisible private static String getLowestNonZeroProbabilityStage() {
	List<OpportunityStage> stages = [SELECT ApiName, DefaultProbability FROM OpportunityStage WHERE IsActive = TRUE];
	Decimal min = 100;
	String stageName;
	for(OpportunityStage stage: stages) {
		if(stage.DefaultProbability > 0 && stage.DefaultProbability < min) {
			min = stage.DefaultProbability;
			stageName = stage.ApiName;
		}
	} 
	return stageName;
}

private PageReference page_redirect(String url){
	PageReference pageRef = new PageReference('/'+url);
	pageRef.setRedirect(true);
	return pageRef;
}

public PageReference CbPriceBookEntry()
{
	planOverridePriceType=true;
	CbPriceBookEntry = oldPlan;
	if(oldPlan != '-1') {
		displaytiericonplan = true;
		PricebookEntry selectedProduct;
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
		qtyChanged =null;

		if(selectedProduct.product2.chargebeeapps__Recurring_charge_model__c != 'TIERED'
		   && selectedProduct.product2.chargebeeapps__Recurring_charge_model__c != 'STAIRSTEP')
		{
			displaytiericonplan = false;
		}
		if(plantype != null && ( plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')||plantype.equalsIgnoreCase('Volume')))
		{
			planOverridePriceType=false;
			List<chargebeeapps__CB_Pricing_Tiers__c> pricingTiers = ProductService.getPricingTiers(pbId);

			showUnit=plantype.equalsIgnoreCase('Tiered');
			tierdata=chargebeeapps.UIUtil.getTierMetric(selectedProduct.Product2.ExternalId,planType,oldPlanQuan, pricingTiers);

			oldPlanPrice = string.valueOf(ProductService.getPrice(planType, pricingTiers, oldPlanQuan));
			displaytiericonplan = !(oldPlanQuan == 0 || oldPlanQuan == null);
		}
	}
	return null;
}
public PageReference CbPriceBookEntryAddon()
{
	tierdataAddon = new List<Map<String,Object> >();

	AddonResp selectedAddon=addons.get(addonId);
	String addonName=selectedAddon.Id;
	addonqty = selectedAddon.quan;
	if(addonName != null && addonName !='-1') {

		PricebookEntry selectedProduct;
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

		if(plantype == null || plantype.equalsIgnoreCase('Flat_Fee') ||
		   plantype.equalsIgnoreCase('per_unit')||plantype.equalsIgnoreCase('quantity'))
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
				tierdataAddon=chargebeeapps.UIUtil.getTierMetric(selectedProduct.product2.ExternalId,plantype,addonqty, pricingTiers);
				if(tierdataAddon != null & !tierdataAddon.isEmpty())
				{
					selectedAddon.tierdata=tierdataAddon;
				}
			}

			selectedAddon.uPrice = double.valueOf(ProductService.getPrice(planType, pricingTiers, addonqty));
		}
	}
	qtyChanged = null;
	return null;
}

}