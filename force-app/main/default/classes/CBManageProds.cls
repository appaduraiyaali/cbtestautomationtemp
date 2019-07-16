public with sharing class CBManageProds {

public Opportunity oppProd;
public CBURLUtil urlUtil;
public Id oppId;
public AddonObject selectedAddon;
public Decimal price=0;
public Integer values {get; set;}
public Integer values1 {get; set;}
public String plans {get; set;}
public String planPrice {get; set;}
public String planCur {get; set;}
public Integer pquan {get; set;}
public String coupon {get; set;}
public string CbPriceBookEntry {get; set;}
public integer addonId {get; set;}
public integer addons {get; set;}
public string addon {get; set;}
public integer addonqty {get; set;}
public decimal addonprice {get; set;}
public string addonCurrency {get; set;}
public boolean displayQty {get; set;}
public boolean displayIcon {get; set;}
public string addonType {get; set;}
public boolean displayTiers {get; set;}
public boolean displayPlanQty {get; set;}
public boolean displayPriceCurrency {get; set;}
public boolean showUnit {get; set;}
public boolean displayButton {get; set;}
public boolean removeButton {get; set;}
public boolean disableText {get; set;}
public string addontrigger {get; set;}
public boolean planOverridePriceType {get; set;}
public boolean displaytiericonplan {get; set;}
public PricebookEntry selectedProduct;
public boolean allAddon;
public string attachedaddon;
public string qtyVaried {get; set;}
public List<AddonObject> selList {get; set;}
public List<AddonObject> selListNonrecur {get; set;}
public string planError {get; set;}
public BaseError be {get; set;}
public string submitlabel {get; set;}
public List<OpportunityLineItem> oppitem;
public List<Map<String,Object> > tierdata {get; set;}
public List<Map<String,Object> > tierdataAddon {get; set;}
public String pbName {get; set;}
public String domain {get; set;}
public String siteId {get; set;}
public String oppCur {get; set;}
public string couponError {get; set;}
Map<String, Object> couponObj=null;
public Integer subPriceInCents=0;

public Boolean isMultiCurrencyEnabled {
	get {
		return UIUtil.isMultiCurrencyEnabled();
	} set;
}

public CBManageProds() {
	planError='';
	couponError='';
	allAddon = false;
	be = new BaseError();
	submitlabel='Add Products';
	oppId = ApexPages.currentPage().getParameters().get('id');
	domain = ApexPages.currentPage().getParameters().get('domain');
	siteId = SiteUtil.getSiteId(domain);
	qtyVaried=null;
	displayTiers = false;
	displayPriceCurrency = false;
	displayPlanQty = false;
	displayIcon = false;
	displayButton = false;
	removeButton = false;
	showUnit = false;
	planOverridePriceType = true;
	system.debug('opp prod id '+oppId);
	populateAddonList();
	if(isMultiCurrencyEnabled) {
		oppProd = Database.query('select id,Name,Pricebook2Id,Pricebook2.Name,chargebeeapps__Coupon__c,CurrencyIsoCode  from Opportunity where Id=\''+oppId+'\'');
		oppCur=(String)oppProd.get('CurrencyIsoCode');
		oppitem = Database.query('select Product2Id,Product2.Name,Product2.ExternalId,PricebookEntry.CurrencyIsoCode,Product2.chargebeeapps__Currency__c,Product2.chargebeeapps__Product_Type__c,Product2.chargebeeapps__Addon_Type__c,Product2.chargebeeapps__Addon_Applicability__c,Quantity,UnitPrice, Discount ,Product2.chargebeeapps__Recurring_charge_model__c,TotalPrice,OpportunityId from OpportunityLineItem where PricebookEntry.Pricebook2.chargebeeapps__CB_Site__c=\''+siteId+'\' and product2.chargebeeapps__Status__c=\'ACTIVE\' and OpportunityId =\''+oppId+'\'');

	}else{
		oppProd = [select id,Name,Pricebook2Id,Pricebook2.Name,chargebeeapps__Coupon__c from Opportunity where Id=:oppId];
		oppitem = [select Product2Id,Product2.Name,Product2.ExternalId,Product2.chargebeeapps__Currency__c,Product2.chargebeeapps__Product_Type__c,Product2.chargebeeapps__Addon_Type__c,Product2.chargebeeapps__Addon_Applicability__c,Quantity,UnitPrice, Discount,Product2.chargebeeapps__Recurring_charge_model__c,TotalPrice,OpportunityId from OpportunityLineItem where PricebookEntry.Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' and OpportunityId =:oppId];
	}

	pbName = oppProd.Pricebook2.Name;
	selList = new List<AddonObject>();
	selListNonrecur = new List<AddonObject>();

	pquan =1;
	urlUtil = new CBURLUtil(domain);

	if(!oppitem.isEmpty())
	{
		submitlabel='Update Products';
		integer i=0;
		if(oppProd.Coupon__c!=null) {
			chargebeeapps__Coupon__c c=[select Id,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__Coupon__c where chargebeeapps__CB_Site__c=:siteId and Id=:oppProd.Coupon__c];
			coupon=c.chargebeeapps__CB_Coupon_Id__c;
		}

		for(OpportunityLineItem oitem:oppitem)
		{
			if(oitem.product2.chargebeeapps__Product_Type__c =='PLAN')
			{
				attachedaddon = oitem.Product2.chargebeeapps__Addon_Applicability__c;
				string plantype = oitem.Product2.chargebeeapps__Recurring_charge_model__c;

				plans = oitem.Product2.ExternalId;
				planPrice = string.valueOf(calculateOriginalPrice(Integer.valueOf(oitem.TotalPrice*100),oitem.Discount));
				planCur = oitem.Product2.chargebeeapps__Currency__c;
				pquan=Integer.valueOf(oitem.Quantity);

				if(isMultiCurrencyEnabled) {
					planCur=(String)oitem.PricebookEntry.get('CurrencyIsoCode');
					selectedProduct = Database.query('Select Id,Product2.Name,Product2.ExternalId,Product2.chargebeeapps__Addon_Applicability__c,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, PricebookEntry.CurrencyIsoCode,product2.chargebeeapps__Currency__c From PricebookEntry  where Product2.ExternalId =\''+oitem.Product2.ExternalId+'\'  And Pricebook2.chargebeeapps__CB_Site__c=\''+siteId+'\' and product2.chargebeeapps__Status__c=\'ACTIVE\' and (product2.chargebeeapps__Product_Type__c=\'PLAN\' or product2.chargebeeapps__Product_Type__c=\'ADDON\')');
				}
				else{
					selectedProduct = [Select Id,Product2.Name,Product2.ExternalId,Product2.chargebeeapps__Addon_Applicability__c,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice,product2.chargebeeapps__Currency__c From PricebookEntry where Product2.ExternalId =:oitem.Product2.ExternalId And Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' and (product2.chargebeeapps__Product_Type__c='PLAN' or product2.chargebeeapps__Product_Type__c='ADDON')];
				}
				string pbId = selectedProduct.Id;

				if(plantype != null && ( plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')||plantype.equalsIgnoreCase('Volume')))
				{
					List<chargebeeapps__CB_Pricing_Tiers__c> pricingTiers = ProductService.getPricingTiers(pbId);

					planOverridePriceType = false;

					Decimal price = ProductService.getPrice(plantype,pricingTiers,Integer.valueOf(oitem.Quantity));
					displayPlanQty =true;
					planPrice = string.valueOf(price);
					if(plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep'))
					{
						displayTiers =true;
						planOverridePriceType = false;
						displayIcon =true;

						tierdata=chargebeeapps.UIUtil.getTierMetric(pbId, plantype, Integer.valueOf(oitem.Quantity),pricingTiers);
						if(tierdata!=null&&tierdata.isEmpty())
						{
							showUnit=plantype.equalsIgnoreCase('Tiered');
						}
					}
				}
				
				if(plantype!=null && plantype=='per_unit') {
					planprice=oitem.UnitPrice+'';
					displayPlanQty=true;
					planOverridePriceType = true;
				}
			}
			else if(oitem.product2.chargebeeapps__Product_Type__c =='ADDON')
			{
				oitem.TotalPrice=calculateOriginalPrice(Integer.valueOf(oitem.TotalPrice*100),oitem.Discount);
				string plantype = oitem.Product2.chargebeeapps__Addon_Type__c;
				string chargeModel = oitem.Product2.chargebeeapps__Recurring_charge_model__c;
				displayButton = true;
				if(isMultiCurrencyEnabled) {
					selectedProduct = Database.query('Select Id,Product2.Name,Product2.ExternalId,Product2.chargebeeapps__Addon_Applicability__c,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, PricebookEntry.CurrencyIsoCode,product2.chargebeeapps__Currency__c From PricebookEntry  where Product2.ExternalId =\''+oitem.Product2.ExternalId+'\'  And Pricebook2.chargebeeapps__CB_Site__c=\''+siteId+'\' and product2.chargebeeapps__Status__c=\'ACTIVE\' and (product2.chargebeeapps__Product_Type__c=\'PLAN\' or product2.chargebeeapps__Product_Type__c=\'ADDON\')');
				}
				else{
					selectedProduct = [Select Id,Product2.Name,Product2.ExternalId,Product2.chargebeeapps__Addon_Applicability__c,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, product2.chargebeeapps__Currency__c From PricebookEntry where Product2.ExternalId =:oitem.Product2.ExternalId And Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' and (product2.chargebeeapps__Product_Type__c='PLAN' or product2.chargebeeapps__Product_Type__c='ADDON')];
				}
				string pbId = selectedProduct.Id;
				i++;
				if(chargeModel != null)
				{
					AddonObject ax;
					if(plantype == null || plantype.equalsIgnoreCase('Flat_Fee')) {
						ax = new AddonObject(oitem.Product2.ExternalId,integer.valueOf(oitem.Quantity),i,oitem.TotalPrice,false,2);
					} else if(plantype!=null && (plantype=='per_unit'|| plantype=='quantity')) {
						ax = new AddonObject(oitem.Product2.ExternalId,integer.valueOf(oitem.Quantity),i,oitem.UnitPrice,false,2);
					} else if(plantype != null && ( plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')||plantype.equalsIgnoreCase('Volume')))
					{
						ax = new AddonObject(oitem.Product2.ExternalId,integer.valueOf(oitem.Quantity),i,oitem.TotalPrice,true,2);
							
						tierdataAddon=UIUtil.getTierMetric(pbId,plantype,integer.valueOf(oitem.Quantity));
						if(tierdataAddon != null & !tierdataAddon.isEmpty())
						{
							ax.tierdata=tierdataAddon;
						}
					}
					ax.model=plantype;
					ax.addonCurrency = oitem.Product2.chargebeeapps__Currency__c;
					if(isMultiCurrencyEnabled) {
						ax.addonCurrency=(String)oitem.PricebookEntry.get('CurrencyIsoCode');
					}
					if(chargeModel.equalsIgnoreCase('Recurring'))
						selList.add(ax);
					else
						selListNonrecur.add(ax);
					
				}
			}
		}
		Map<string,List<string> > mandatryadd = getMandatoryAddon(plans);
		if(mandatryadd!=null)
		{
			List<string> manAddon = mandatryadd.get('mandatory');
			List<string> applicableAdd = mandatryadd.get('applicable');
			for(AddonObject obj: selList)
			{
				if(manAddon.contains(obj.addon)) {
					obj.removeAddon=false;
				}
			}
			for(AddonObject obj: selListNonrecur)
			{
				if(manAddon.contains(obj.addon)) {
					obj.removeAddon=false;
				}
			}
			if(applicableAdd.size()>0) {
				fillAddons(applicableAdd);
			}
			else{
				populateAddonList();
			}
		}
	}else{
		populateAddonList();
	}
}


public List<SelectOption> options3 {
	get
	{
		return CBSubscriptionUtil.getProductSelectOptions('PLAN',siteId,null);
	}
	set;
}
public List<SelectOption> addonOptions {
	get;
	set;
}

public List<SelectOption> addonOptionsNonrecur {
	get;
	set;
}
public List<SelectOption> couponOptions {
	get {
		couponOptions = chargebeeapps.UIUtil.getCouponOptions(siteId);
		return couponOptions;
	}
	set;
}
public PageReference validate(){
	if(plans=='-1' ) {
		be =new BaseError('Please select a plan');
		return null;
	}
	if(oppCur!=null && planCur!=oppCur) {
		be =new BaseError('Plan currency is different from Opportunity currency.');
		return null;
	}
	if(pquan==null || pquan==0 ) {
		be =new BaseError('Quantity can not be 0 or empty');
		displayPlanQty =true;
		return null;
	}
	Set<string> dupAddon=new Set<string>();
	for(AddonObject addon:selList) {
		if(dupAddon.contains(addon.addon)) {
			be =new BaseError('Please remove duplicate Addons - '+addon.addon);
			return null;
		}
		if(addon.qty == 0 || addon.qty == null) {
			be =new BaseError('Please enter quantity - '+addon.addon);
			return null;
		}
		if(addon.addonCurrency != planCur) {
			be =new BaseError('Currency of '+ plans+ ' should not be different from '+ addon.addon);
			return null;
		}
		dupAddon.add(addon.addon);

	}
	dupAddon=new Set<string>();
	for(AddonObject addon:selListNonrecur) {
		if(dupAddon.contains(addon.addon)) {
			be =new BaseError('Please remove duplicate Addons - '+addon.addon);
			return null;
		}
		if(addon.qty == 0 || addon.qty == null) {
			be =new BaseError('Please enter quantity - '+addon.addon);
			return null;
		}
		if(addon.addonCurrency != planCur) {
			be =new BaseError('Currency of '+ plans + ' should not be different from ' + addon.addon);
			return null;
		}
		dupAddon.add(addon.addon);
	}
	if(validateCoupon()) {
		saveObjects();
		return new PageReference('/'+oppId);
	}
	return null;
}
public boolean validateCoupon(){
	couponError='';
	if(coupon!='-1') {
		try{
			couponObj=getCouponDetails(coupon);
			system.debug('coupon'+couponObj);
			if((String)couponObj.get('plan_constraint')=='all'
			   || ((String)couponObj.get('addon_constraint')=='all'
			       && (!selList.isEmpty()||!selListNonrecur.isEmpty()))) {
				return true;
			}
			else if((String)couponObj.get('plan_constraint')=='not_applicable'
			        && (String)couponObj.get('addon_constraint')=='not_applicable') {//apply on invoice amount
				calculateSubscriptionAmount();
				return true;
			}
			else if((String)couponObj.get('plan_constraint')=='specific'
			        && ((List<String>)couponObj.get('plan_ids')).contains(plans)) {
				return true;//can be applied on plan
			}
			else if((String)couponObj.get('addon_constraint')=='specific') {
				for(AddonObject addon:selList) {
					if(((List<object>)couponObj.get('addon_ids')).contains(addon.addon)) {
						return true;//applicable on addon
					}
				}
				for(AddonObject addon:selListNonrecur) {
					if(((List<object>)couponObj.get('addon_ids')).contains(addon.addon)) {
						return true;//applicable on addon
					}
				}
			}
		}
		catch(Exception e) {

		}
		couponError='Coupon not applicable';
		return false;
	}
	return true;
}
public void calculateSubscriptionAmount(){
	subPriceInCents=0;
	subPriceInCents+=getTotalAmount(pquan,Decimal.valueOf(planPrice),plans,'plan');
	for(AddonObject addon:selList) {
		subPriceInCents+=getTotalAmount(Decimal.valueOf(addon.qty),addon.price,addon.addon,'addon');
	}
	for(AddonObject addon:selListNonrecur) {
		subPriceInCents+=getTotalAmount(Decimal.valueOf(addon.qty),addon.price,addon.addon,'addon');
	}
}
public Integer getTotalAmount(Decimal quantity,Decimal totalPrice,string cbId,string type){
	PricebookEntry product=[Select id,ProductCode,UnitPrice,Product2.Id,Product2.ExternalId From PricebookEntry Where Product2.ExternalId=:cbId and Pricebook2.chargebeeapps__CB_Site__c=:siteId];
	Product2 prod=[select id,chargebeeapps__Recurring_charge_model__c,chargebeeapps__Addon_Type__c from Product2 where id=:product.Product2.Id];
	String model=prod.chargebeeapps__Recurring_charge_model__c;
	if(type=='addon') {
		model=prod.chargebeeapps__Addon_Type__c;
	}
	if(model=='per_unit'||model=='quantity') {
		return Integer.valueOf(totalPrice*quantity*100);
	}
	else{
		return Integer.valueOf(totalPrice*100);
	}
}

public Decimal calculateOriginalPrice(Integer priceInCents,Decimal discount){
	if(discount<100 && priceInCents>0) {
		Decimal temp=(priceInCents*100)/(100-discount);
		temp=temp/100;
		return temp.setScale(2);
	}
	return 0.0;
}
public void saveObjects(){
	updateOpportunity();

	OpportunityService oppService = new OpportunityService(oppId);
	oppService.deleteOpportunityLineItems();
	savePlan(oppService);
	saveAddonObjects(oppService);
}
public void savePlan(OpportunityService oppService){
	oppService.createOppLineItem(pquan,Decimal.valueOf(planPrice),plans,'plan',siteId,subPriceInCents,couponObj);
}
public void saveAddonObjects(OpportunityService oppService){
	for(AddonObject addon:selList) {
		oppService.createOppLineItem(Decimal.valueOf(addon.qty),addon.price,addon.addon,'addon',siteId,subPriceInCents,couponObj);
	}
	for(AddonObject addon:selListNonrecur) {
		oppService.createOppLineItem(Decimal.valueOf(addon.qty),addon.price,addon.addon,'addon',siteId,subPriceInCents,couponObj);
	}
}


public void updateOpportunity(){
	Pricebook2 pb=[select Id,chargebeeapps__CB_Site__c From PriceBook2 Where Pricebook2.chargebeeapps__CB_Site__c=:siteId];
	if(oppProd.Pricebook2Id!=pb.Id) {
		if (Schema.sObjectType.Opportunity.fields.Pricebook2Id.IsUpdateable())
		{
			oppProd.Pricebook2Id=pb.Id;
		}
	}
	if(coupon!='-1') {
		chargebeeapps__Coupon__c c=[select Id from chargebeeapps__Coupon__c where chargebeeapps__CB_Coupon_Id__c=:coupon and chargebeeapps__CB_Site__c=:siteId];
		if (Schema.sObjectType.Opportunity.fields.Coupon__c.IsUpdateable())
		{
			oppProd.Coupon__c=c.Id;
		}
	}
	else{
		if (Schema.sObjectType.Opportunity.fields.Coupon__c.IsUpdateable())
		{
			oppProd.Coupon__c=null;
		}
	}
	system.debug('oppProd '+oppProd);
	update oppProd;
}
public Map<String,String> PlanExternalIdVsChargeModel {
	get
	{
		return chargebeeapps.UIUtil.getPlanExternalIdVsChargeModel(isMultiCurrencyEnabled, siteId);
	}
	set;
}

public String JsonMap {get {
			       JsonMap = JSON.serialize(PlanExternalIdVsChargeModel);
			       system.debug('JsonMap '+JsonMap);
			       return JsonMap;
		       } set;}
public PageReference saveAddons(){

	Integer i = selList.size()+1;
	displayButton = true;
	AddonObject ax = new AddonObject('-1',1,i,0,false,2);
	selList.add(ax);

	AddonObject old = selList.get(i-1);
	old.setStatus(3);

	return null;
}
public PageReference delAddons(){
	Integer i = values;
	system.debug('val '+i);
	//i--;
	try{
		selList.remove(i-1);
	}
	catch(Exception e) {
	}

	return null;
}
public PageReference saveAddonsNewList()
{
	Integer j = selListNonrecur.size()+1;
	displayButton = true;
	AddonObject ax = new AddonObject('-1',1,j,0,false,2);
	selListNonrecur.add(ax);
	AddonObject old1 = selListNonrecur.get(j-1);
	old1.setStatus(3);
	return null;
}

public PageReference delAddonsNewList(){
	Integer j = values1;
	try{
		selListNonrecur.remove(j-1);
	}
	catch(Exception e) {
	}

	return null;
}
public Boolean canOverride {
	get {
		return urlUtil.canOverRide();
	} set;
}


public Map<string,List<string> > getMandatoryAddon(string planid)
{
	Map<string,list<string> > defaultaddonList = new Map<string,list<string> >();
	list<string> recommendAddons = new List<string>();
	list<string> mandatoryAddons = new List<string>();
	list<string> applicableAddons = new List<string>();
	EndPoint ep = EndPointsIndex.get_plan_details;
	if(domain!=null) {
		ep.domainName(domain);
	}
	List<String> liststr = new List<String>();
	liststr.add(EncodingUtil.urlEncode(planid,'UTF-8'));
	ep.replace(liststr);
	GenericURLBuilder br = new GenericURLBuilder(ep);
	GenericController ctr = new GenericController(br);
	Map<String, Object> responseMap = ctr.makeRequest();
	BaseError be = new BaseError(responseMap);
	system.debug('here::'+attachedaddon);
	if(be.isErr) {

		return null;
	}
	Map<String, Object> resp = (Map<String, Object>)responseMap.get('plan');
	if(resp.containsKey('attached_addons')) {
		List<object> attachedAddons = new List<object>();
		attachedAddons =  (List<object>)resp.get('attached_addons');
		for(object add:attachedAddons)
		{
			if((string)((Map<String,Object>)add).get('type')=='mandatory')
			{
				string addid = (string)((Map<String,Object>)add).get('id');
				mandatoryAddons.add(addid);

			}
			if((string)((Map<String,Object>)add).get('type')=='recommended')
			{
				string addid = (string)((Map<String,Object>)add).get('id');
				recommendAddons.add(addid);
			}

		}
	}
	if(resp.containsKey('applicable_addons')) {
		List<object> appAddons = new List<object>();
		appAddons =  (List<object>)resp.get('applicable_addons');
		for(object add:appAddons)
		{
			string addid = (string)((Map<String,Object>)add).get('id');
			applicableAddons.add(addid);


		}
	}
	defaultaddonList.put('mandatory',mandatoryAddons);
	defaultaddonList.put('recommended',recommendAddons);
	defaultaddonList.put('applicable',applicableAddons);

	return defaultaddonList;
}
public PageReference CbPriceBookEntry()
{
	planOverridePriceType=true;
	allAddon =false;
	CbPriceBookEntry = plans;
	displayTiers=false;
	displayPriceCurrency = true;
	displayPlanQty =false;
	if(plans != '-1') {
		if(isMultiCurrencyEnabled) {
			selectedProduct = Database.query('Select Id,Product2.Name,Product2.ExternalId,Product2.chargebeeapps__Addon_Applicability__c,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, PricebookEntry.CurrencyIsoCode,product2.chargebeeapps__Currency__c From PricebookEntry  where Product2.ExternalId =:plans  And Pricebook2.chargebeeapps__CB_Site__c=\''+siteId+'\' and product2.chargebeeapps__Status__c=\'ACTIVE\' and (product2.chargebeeapps__Product_Type__c=\'PLAN\' or product2.chargebeeapps__Product_Type__c=\'ADDON\')');
			planCur = (String)selectedProduct.get('CurrencyIsoCode');
		}
		else{
			selectedProduct = [Select Id,Product2.Name,Product2.ExternalId,Product2.chargebeeapps__Addon_Applicability__c,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, product2.chargebeeapps__Currency__c From PricebookEntry where Product2.ExternalId =:plans And Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' and (product2.chargebeeapps__Product_Type__c='PLAN' or product2.chargebeeapps__Product_Type__c='ADDON')];
			planCur = selectedProduct.product2.chargebeeapps__Currency__c;
		}

		string pbId = string.valueOf(selectedProduct.Id);
		string plantype = selectedProduct.product2.chargebeeapps__Recurring_charge_model__c;
		if(qtyVaried!='changedQty')
		{
			planPrice = string.valueOf(selectedProduct.UnitPrice);
		}

		string attachedaddon = selectedProduct.product2.chargebeeapps__Addon_Applicability__c;
		if(plantype != null && (plantype.equalsIgnoreCase('PER_UNIT') || plantype=='quantity') )
		{
			displayPlanQty =true;
		}

		if(plantype != null && ( plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')||plantype.equalsIgnoreCase('Volume')))
		{
			List<chargebeeapps__CB_Pricing_Tiers__c> pricingTiers = ProductService.getPricingTiers(pbId);

			planOverridePriceType=false;
			showUnit=plantype.equalsIgnoreCase('Tiered');

			if(plantype != null && (plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')) )
			{
				displayIcon =true;
				tierdata=UIUtil.getTierMetric(pbId,plantype,pquan, pricingTiers);
				if(tierdata != null & !tierdata.isEmpty())
				{
					displayTiers=true;
				}
			}else{
				displayIcon = false;
				displayTiers=false;
			}

			displayPlanQty =true;

			if(pquan == 0 || pquan == null)
			{
				displayIcon =false;
			}
			Decimal price=ProductService.getPrice(planType, pricingTiers, pquan);
			planPrice = string.valueOf(price);
		}else{
			displayPlanQty =false;
		}
		integer i;
		if(qtyVaried !='changedQty')
		{
			selList = new List<AddonObject>();
			selListNonrecur = new List<AddonObject>();

			allAddon = sendRequestToPlan(selectedProduct.Product2.ExternalId,selectedProduct.Product2.Name,attachedaddon);
		}
		qtyVaried =null;

	}
	return null;
}
public void populateAddonList(){

	List<PricebookEntry> prodList = ProductService.getRecurringAddonForSite(siteId);
    addonOptions = UIUtil.getPlanAddonOptions(prodList);

	List<PricebookEntry> prodLists = ProductService.getNonRecurringAddonForSite(siteId);
    addonOptionsNonrecur = UIUtil.getPlanAddonOptions(prodList);

}
public void filladdons(List<string> ids){

	List<PricebookEntry> cbaddonApp = [Select id,Product2.ProductCode,Product2.ExternalId,Product2.Name,product2.chargebeeapps__Product_Type__c,product2.chargebeeapps__Addon_Type__c,PricebookEntry.UnitPrice,product2.chargebeeapps__Recurring_charge_model__c From PricebookEntry where Product2.ExternalId IN:ids and Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' and product2.chargebeeapps__Product_Type__c='ADDON'];
	addonOptions = new List<SelectOption>();
	addonOptions.add(new SelectOption('-1','Select'));
	addonOptionsNonrecur = new List<SelectOption>();
	addonOptionsNonrecur.add(new SelectOption('-1','Select'));
	for(PricebookEntry cb:cbaddonApp)
	{
		string plantype = cb.product2.chargebeeapps__Addon_Type__c;
		string pbId = string.valueOf(cb.Id);
		string chargeModel = cb.product2.chargebeeapps__Recurring_charge_model__c;

		if(chargeModel != null && chargeModel.equalsIgnoreCase('Recurring'))
		{
			addonOptions.add(new SelectOption(cb.Product2.ExternalId,cb.Product2.Name));
		}
		if(chargeModel != null && chargeModel.equalsIgnoreCase('Non_Recurring'))
		{
			addonOptionsNonrecur.add(new SelectOption(cb.Product2.ExternalId,cb.Product2.Name));
		}

	}
}
public boolean sendRequestToPlan(string planid,string name,string attachedaddon)
{
	EndPoint ep = EndPointsIndex.get_plan_details;
	if(domain!=null) {
		ep.domainName(domain);
	}
	List<String> liststr = new List<String>();
	liststr.add(EncodingUtil.urlEncode(planid,'UTF-8'));
	ep.replace(liststr);
	GenericURLBuilder br = new GenericURLBuilder(ep);
	GenericController ctr = new GenericController(br);
	Map<String, Object> responseMap = ctr.makeRequest();
	BaseError be = new BaseError(responseMap);

	if(be.isErr) {
		selList = new List<AddonObject>();
		selListNonrecur = new List<AddonObject>();
		return null;
	}
	Map<String, Object> resp = (Map<String, Object>)responseMap.get('plan');

	List<object> attachedAddons = new List<object>();
	attachedAddons =  (List<object>)resp.get('attached_addons');
	List<String> addonlists = new List<String>();
	if(attachedaddon!=null && attachedaddon.equalsIgnoreCase('Restricted'))
	{
		List<object> applicableAddons = new List<object>();
		applicableAddons =  (List<object>)resp.get('applicable_addons');

		if(applicableAddons!=null)
		{
			string appAddonid;
			for(Object a:applicableAddons) {

				Map<String, Object> adns = (Map<String, Object>)a;
				system.debug(adns.get('id'));
				appAddonid = (string)adns.get('id');
				addonlists.add(appAddonid);

			}
			filladdons(addonlists);
		}
	}
	else{
		populateAddonList();

	}
	Integer i = 0;
	List<string> attAddons = new List<string>();
	List<string> recAttAddons = new List<string>();
	List<Integer> recAttQty = new List<Integer>();
	List<Integer> recAttQty1 = new List<Integer>();
	string addType;
	string addid;

	integer qty;
	string obj;
	if(attachedAddons==null)
	{
		allAddon = true;
	}
	if(attachedAddons!=null)

		for(Object o:attachedAddons) {

			Map<String, Object> adns = (Map<String, Object>)o;
			addid = (string)adns.get('id');
			addType = (string)adns.get('type');
			qty = (Integer)adns.get('quantity');
			obj = (string)adns.get('object');
			if(addType.equalsIgnoreCase('recommended') )
			{
				recAttAddons.add(addid);
				recAttQty.add(qty);

			}else if(addType.equalsIgnoreCase('mandatory') ) {
				attAddons.add(addid);
				recAttQty1.add(qty);
			}
		}
	//mandatory addons
	integer count=0;
	if(attAddons.size()>0) {
		List<PricebookEntry> cbaddon;
		if(isMultiCurrencyEnabled) {
			cbaddon = Database.query('Select id,Product2.ProductCode,Product2.ExternalId,product2.Name,product2.chargebeeapps__Product_Type__c,PricebookEntry.CurrencyIsoCode,product2.chargebeeapps__Addon_Type__c,PricebookEntry.UnitPrice,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Currency__c From PricebookEntry  where Product2.ExternalId IN:attAddons and Pricebook2.chargebeeapps__CB_Site__c=\''+siteId+'\' and product2.chargebeeapps__Status__c=\'ACTIVE\' and product2.chargebeeapps__Product_Type__c=\'ADDON\'');
		}
		else{
			cbaddon = [Select id,Product2.ProductCode,Product2.ExternalId,product2.Name,product2.chargebeeapps__Product_Type__c,product2.chargebeeapps__Addon_Type__c,PricebookEntry.UnitPrice,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Currency__c From PricebookEntry where Product2.ExternalId IN:attAddons and Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' and product2.chargebeeapps__Product_Type__c='ADDON'];
		}
		for(PricebookEntry cbb:cbaddon) {
			i++;
			displayButton =true;

			qty=recAttQty1.get(count++);
			string plantype = cbb.product2.chargebeeapps__Addon_Type__c;
			string pbId = string.valueOf(cbb.Id);
			string chargeModel = cbb.product2.chargebeeapps__Recurring_charge_model__c;
			if(chargeModel != null)
			{
				AddonObject ax;
				if(plantype == null || plantype.equalsIgnoreCase('Flat_Fee')) {
					ax = new AddonObject(cbb.Product2.ExternalId,qty,i,cbb.UnitPrice,false,2);
				} else if(plantype != null && ( plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')||plantype.equalsIgnoreCase('Volume')))
				{
					List<chargebeeapps__CB_Pricing_Tiers__c> pricingTiers = ProductService.getPricingTiers(pbId);

					Decimal newPrice = ProductService.getPrice(plantype,pricingTiers,qty);
					ax = new AddonObject(cbb.Product2.ExternalId,qty,i,newPrice,true,2);
					tierdataAddon=UIUtil.getTierMetric(pbId,plantype,qty, pricingTiers);
					if(tierdataAddon != null & !tierdataAddon.isEmpty())
					{
						ax.tierdata=tierdataAddon;
					}
				} else {
					ax = new AddonObject(cbb.Product2.ExternalId,qty,i,cbb.UnitPrice,true,2);
				}
				ax.model=plantype;
				ax.addonCurrency = cbb.product2.chargebeeapps__Currency__c;
				if(isMultiCurrencyEnabled) {
					ax.addonCurrency = (String)cbb.get('CurrencyIsoCode');
				}
				ax.removeAddon=false;
				if(chargeModel.equalsIgnoreCase('Recurring'))
					selList.add(ax);
				else if (chargeModel.equalsIgnoreCase('Non_recurring'))
					selListNonrecur.add(ax);
			}
		}

	}
	//recomended addons
	Integer j = 0;
	count=0;
	if(recattAddons.size()>0) {
		List<PricebookEntry> cbaddon;
		if(isMultiCurrencyEnabled) {
			cbaddon=Database.query('Select id,Product2.ProductCode,Product2.ExternalId,product2.chargebeeapps__Currency__c,product2.Name,product2.chargebeeapps__Product_Type__c,product2.chargebeeapps__Addon_Type__c,PricebookEntry.UnitPrice,product2.chargebeeapps__Recurring_charge_model__c,PricebookEntry.CurrencyIsoCode From PricebookEntry  where Product2.ExternalId IN:recAttAddons and Pricebook2.chargebeeapps__CB_Site__c=\''+siteId+'\' and product2.chargebeeapps__Status__c=\'ACTIVE\' and product2.chargebeeapps__Product_Type__c=\'ADDON\'');
		}
		else{
			cbaddon=[Select id,Product2.ProductCode,Product2.ExternalId,product2.Name,product2.chargebeeapps__Currency__c,product2.chargebeeapps__Product_Type__c,product2.chargebeeapps__Addon_Type__c,PricebookEntry.UnitPrice,product2.chargebeeapps__Recurring_charge_model__c From PricebookEntry where Product2.ExternalId IN:recAttAddons and Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' and product2.chargebeeapps__Product_Type__c='ADDON'];
		}
		for(PricebookEntry cbb:cbaddon) {
			j++;
			displayButton =true;
			qty =  recAttQty.get(count++);

			string plantype = cbb.product2.chargebeeapps__Addon_Type__c;
			string pbId = string.valueOf(cbb.Id);
			string chargeModel = cbb.product2.chargebeeapps__Recurring_charge_model__c;
			if(chargeModel != null)
			{
				AddonObject ax;
				if(plantype == null || plantype.equalsIgnoreCase('Flat_Fee')) {
					ax = new AddonObject(cbb.Product2.ExternalId,qty,j,cbb.UnitPrice,false,2);
				} else if(plantype != null && ( plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')||plantype.equalsIgnoreCase('Volume')))
				{
					List<chargebeeapps__CB_Pricing_Tiers__c> pricingTiers = ProductService.getPricingTiers(pbId);

					Decimal newPrice = ProductService.getPrice(plantype,pricingTiers,qty);

					ax = new AddonObject(cbb.Product2.ExternalId,qty,j,newPrice,true,2);
					tierdataAddon=UIUtil.getTierMetric(pbId,plantype,qty);
					if(tierdataAddon != null & !tierdataAddon.isEmpty())
					{
						ax.tierdata=tierdataAddon;
					}
				} else{
					ax = new AddonObject(cbb.Product2.ExternalId,qty,j,cbb.UnitPrice,true,2);
				}
				ax.model=plantype;
				ax.addonCurrency = cbb.product2.chargebeeapps__Currency__c;
				if(isMultiCurrencyEnabled) {
					ax.addonCurrency = (String)cbb.get('CurrencyIsoCode');
				}
				if(chargeModel.equalsIgnoreCase('Recurring'))
					selList.add(ax);
				else if (chargeModel.equalsIgnoreCase('Non_recurring'))
					selListNonrecur.add(ax);
			}
		}
	}
	return allAddon;
}

public Map<String, Object> getCouponDetails(string couponId)
{
	return chargebeeapps.CouponService.getCouponDetails(couponId, domain);
}

public PageReference CbPriceBookEntryAddon()
{
	selectedAddon=selList.get(addonId-1);
	updateAddonProperties(selectedAddon);
	return null;
}

public PageReference CbPriceBookEntryAddon1()
{
	selectedAddon=selListNonrecur.get(addonId-1);
	updateAddonProperties(selectedAddon);
	return null;
}

private void updateAddonProperties(chargebeeapps.AddonObject selectedAddon)
{
	String addonName=selectedAddon.addon;
	addonqty = selectedAddon.qty;
	if(isMultiCurrencyEnabled) {
		selectedProduct = Database.query('Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, PricebookEntry.CurrencyIsoCode,product2.chargebeeapps__Currency__c From PricebookEntry  where Product2.ExternalId =:addonName And Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c=\'ACTIVE\' and product2.chargebeeapps__Product_Type__c=\'ADDON\'');
	}
	else{
		selectedProduct = [Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, product2.chargebeeapps__Currency__c From PricebookEntry where Product2.ExternalId =:addonName And Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' and product2.chargebeeapps__Product_Type__c='ADDON'];
	}
	string pbId = string.valueOf(selectedProduct.Id);
	String plantype=selectedProduct.product2.chargebeeapps__Addon_Type__c;
	selectedAddon.model = plantype;
	selectedAddon.addonCurrency = selectedProduct.product2.chargebeeapps__Currency__c;
	if(isMultiCurrencyEnabled) {
		selectedAddon.addonCurrency = (String)selectedProduct.get('CurrencyIsoCode');
	}

	if(plantype == null || plantype.equalsIgnoreCase('Flat_Fee') || plantype.equalsIgnoreCase('Quantity')|| plantype=='per_unit')
	{
		if(qtyVaried!='changedQty')
		{
			selectedAddon.price = selectedProduct.UnitPrice;
		}
	}
	qtyVaried=null;
	if(plantype != null && ( plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')||plantype.equalsIgnoreCase('Volume')))
	{
		List<chargebeeapps__CB_Pricing_Tiers__c> pricingTiers = ProductService.getPricingTiers(pbId);

		selectedAddon.price  = ProductService.getPrice(plantype,pricingTiers,addonqty);

		if(plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep'))
		{
			tierdataAddon=UIUtil.getTierMetric(pbId,plantype,addonqty, pricingTiers);
			if(tierdataAddon != null & !tierdataAddon.isEmpty())
			{
				selectedAddon.tierdata=tierdataAddon;
			}
		}
	}
}

public PageReference showPriceTiers()
{
	displayTiers=true;
	return null;
}
public PageReference hidePriceTiers()
{
	displayTiers=false;
	return null;
}

}