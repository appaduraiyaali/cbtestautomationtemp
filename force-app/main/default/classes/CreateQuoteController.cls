public with sharing class CreateQuoteController {

public Opportunity oppProd;
public String oppId;
public Contact cont {get; set;}
public String con_id {get; set;}
public CBURLUtil urlUtil;

public Integer values {get; set;}
public Integer values1 {get; set;}

public PlanObject plan {get; set;}

public String billingCycles {get; set;}
public String coupon {get; set;}
public integer addonId {get; set;}

public boolean displayButton {get; set;}
public boolean removeButton {get; set;}
public string addontrigger {get; set;}

public string qtyVaried {get; set;}
public List<AddonObject> selList {get; set;}
public List<AddonObject> selListNonrecur {get; set;}
public BaseError be {get; set;}


public String domain {get; set;}
public boolean isSiteConnected {get; set;}

public String siteId {get; set;}
public String oppCur {get; set;}
public string couponError {get; set;}
public Map<String, Object> couponObj=null;
public Integer subPriceInCents=0;

public List<SelectOption> addonOptions { get; set;}
public List<SelectOption> addonOptionsNonrecur { get;set;}
public List<SelectOption> planOptions { get; set;}
public List<SelectOption> couponOptions { get; set;}

public Boolean isMultiCurrencyEnabled {
	get {
		return UIUtil.isMultiCurrencyEnabled();
	} set;
}

public PageReference checkPermissions(){
	Map<String, List<String> > objectToFieldMapping = new Map<String, List<String> >();

	objectToFieldMapping.put('contact', new List<String> {'LastName', 'FirstName','Email', 'AccountId', 'Phone',
	                                                      'MailingStreet', 'MailingCity', 'MailingState', 'MailingCountry', 'MailingPostalCode',
	                                                      'chargebeeapps__Auto_collection__c', 'chargebeeapps__External_Id__c'});
	objectToFieldMapping.put('product2',  new List<String> {'ExternalId','name','chargebeeapps__Recurring_charge_model__c',
	                                                        'chargebeeapps__Addon_Type__c','chargebeeapps__Currency__c','chargebeeapps__Status__c','chargebeeapps__Product_Type__c'});
	objectToFieldMapping.put('pricebookentry', new List<String> {'Id','name','chargebeeapps__Setup_Cost__c','UnitPrice'});
	objectToFieldMapping.put('chargebeeapps__Coupon__c', new List<String> {'chargebeeapps__CB_Coupon_Id__c','Name','chargebeeapps__Status__c'});
	objectToFieldMapping.put('opportunity', new List<String> {'Name','Id', 'AccountId','Pricebook2Id','chargebeeapps__Coupon__c'});
	objectToFieldMapping.put('Pricebook2', new List<String> {'Name','Name' });
	objectToFieldMapping.put('chargebeeapps__Contact_Associate_Site__c', new List<String> {'chargebeeapps__Contact__c',
	                                                                                       'chargebeeapps__External_Id__c','chargebeeapps__CB_Site__c'});

	List<String> objNames = new List<String>();
	String fs;

	for(String key : objectToFieldMapping.keyset()) {

		List<String> fields = objectToFieldMapping.get(key);

		if(!FlsUtil.isPermitable(fields,key)) {
			fs = FlsUtil.getNotAccessibleFields(fields,key,'access');
			objNames.add(key);
		}
	}

	if(fs!=null)
		return redirectToError(fs,String.join(objNames,','));

	/*if(domain!=null) {
		urlUtil = new CBURLUtil(domain);
		if(!urlUtil.isQuotesEnabled()) {
			return redirectToGeneralErrorPage('QUOTES_DISABLED',oppProd.Id);
		}
	}*/
	
	return null;	
}

public List<selectOption> getSiteDetails()
{
	List<selectOption> synchedSites = UIUtil.getSiteDetailsWithQuotesEnabled(con_id);
	isSiteConnected = synchedSites.size()==1;
	return synchedSites;
}

public PageReference selectedSiteName()
{
	plan = new PlanObject('', 1, 0.0, '', 0.0);
	siteId=SiteUtil.getSiteId(domain);
	system.debug('Site:'+domain);
	urlUtil = new CBURLUtil(domain);
	if(!urlUtil.isQuotesEnabled()) {
		return UIUtil.redirectToGeneralErrorPage('QUOTES_DISABLED',oppId);
	}

	selList = new List<AddonObject>();
	selListNonrecur = new List<AddonObject>();
	planOptions = chargebeeapps.UIUtil.getPlanOptions(siteId);
	couponOptions = chargebeeapps.UIUtil.getCouponOptions(siteId);
	loadFromOpportunity(siteId);
	return null;
}

public PageReference redirectToError(String err,String obj){
	PageReference pageRef = new PageReference('/apex/error');
	pageRef.getParameters().put('err',err);
	pageRef.getParameters().put('obj',obj);
	pageRef.setRedirect(true);
	return pageRef;
}

private void loadFromOpportunity(String siteId) {

	List<OpportunityLineItem> oppItem;

	if(isMultiCurrencyEnabled) {
		oppProd = Database.query('select id,Name,AccountId,Pricebook2Id,Pricebook2.Name,chargebeeapps__Coupon__c,CurrencyIsoCode  from Opportunity where Id=\''+oppId+'\'');
		oppCur=(String)oppProd.get('CurrencyIsoCode');
		oppitem = Database.query('select Product2Id,Product2.Name,Product2.ExternalId,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.CurrencyIsoCode,Product2.chargebeeapps__Currency__c,Product2.chargebeeapps__Product_Type__c,Product2.chargebeeapps__Addon_Type__c,Product2.chargebeeapps__Addon_Applicability__c,Quantity,UnitPrice, Discount ,Product2.chargebeeapps__Recurring_charge_model__c,TotalPrice,OpportunityId from OpportunityLineItem where PricebookEntry.Pricebook2.chargebeeapps__CB_Site__c=\''+siteId+'\' and product2.chargebeeapps__Status__c=\'ACTIVE\' and OpportunityId =\''+oppId+'\'');

	}else{
		oppProd = [select id,Name,AccountId,Pricebook2Id,Pricebook2.Name,chargebeeapps__Coupon__c from Opportunity where Id=:oppId];
		oppitem = [select Product2Id,Product2.Name,Product2.ExternalId,PricebookEntry.chargebeeapps__Setup_Cost__c,Product2.chargebeeapps__Currency__c,Product2.chargebeeapps__Product_Type__c,Product2.chargebeeapps__Addon_Type__c,Product2.chargebeeapps__Addon_Applicability__c,Quantity,UnitPrice, Discount,Product2.chargebeeapps__Recurring_charge_model__c,TotalPrice,OpportunityId from OpportunityLineItem where PricebookEntry.Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' and OpportunityId =:oppId];
	}

	populateAddonList();

	if(!oppitem.isEmpty())
	{
		integer i=0;
		if(oppProd.Coupon__c!=null) {
			chargebeeapps__Coupon__c c=[select Id,chargebeeapps__CB_Coupon_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__Coupon__c where chargebeeapps__CB_Site__c=:siteId and Id=:oppProd.Coupon__c];
			coupon=c.chargebeeapps__CB_Coupon_Id__c;
		}

		for(OpportunityLineItem oitem:oppitem)
		{
			if(oitem.product2.chargebeeapps__Product_Type__c =='PLAN')
			{
				plan = new PlanObject(oitem.Product2.ExternalId,
					Integer.valueOf(oitem.Quantity),
					calculateOriginalPrice(Integer.valueOf(oitem.TotalPrice*100),oitem.Discount),
					oitem.Product2.chargebeeapps__Currency__c,
					0.0);
	
				string plantype = oitem.Product2.chargebeeapps__Recurring_charge_model__c;
				plan.model = plantype;

				PricebookEntry selectedProduct;
				if(isMultiCurrencyEnabled) {
					plan.planCurrency = (String)oitem.PricebookEntry.get('CurrencyIsoCode');
					selectedProduct = Database.query('Select Id,Product2.Name,Product2.ExternalId,Product2.chargebeeapps__Addon_Applicability__c,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, PricebookEntry.CurrencyIsoCode,product2.chargebeeapps__Currency__c From PricebookEntry  where Product2.ExternalId =\''+oitem.Product2.ExternalId+'\'  And Pricebook2.chargebeeapps__CB_Site__c=\''+siteId+'\' and product2.chargebeeapps__Status__c=\'ACTIVE\' and (product2.chargebeeapps__Product_Type__c=\'PLAN\' or product2.chargebeeapps__Product_Type__c=\'ADDON\')');
				}
				else{
					selectedProduct = [Select Id,Product2.Name,Product2.ExternalId,Product2.chargebeeapps__Addon_Applicability__c,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice,product2.chargebeeapps__Currency__c From PricebookEntry where Product2.ExternalId =:oitem.Product2.ExternalId And Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' and (product2.chargebeeapps__Product_Type__c='PLAN' or product2.chargebeeapps__Product_Type__c='ADDON')];
				}
				string pbId = selectedProduct.Id;
				if(oitem.PricebookEntry.chargebeeapps__Setup_Cost__c!=null){
					plan.hasSetupFee=true;
					plan.setupFee=oitem.PricebookEntry.chargebeeapps__Setup_Cost__c;
                } else {
					plan.hasSetupFee=false;
					plan.setupFee=0.0;
				}

				if(plantype != null && ( plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')||plantype.equalsIgnoreCase('Volume')))
				{
					List<chargebeeapps__CB_Pricing_Tiers__c> pricingTiers = ProductService.getPricingTiers(pbId);

					plan.price= ProductService.getPrice(plantype,pricingTiers,Integer.valueOf(oitem.Quantity));
					if(plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep'))
					{
						List<Map<String,Object>> tierdata=UIUtil.getTierMetric(pbId,plantype,integer.valueOf(oitem.Quantity));
						if(tierdata!=null&&tierdata.isEmpty())
						{
							plan.tierdata = tierdata;
						}
					}
				}

				if(plantype!=null && plantype=='per_unit') {
					plan.price = oitem.UnitPrice;
				}
			}
			else if(oitem.product2.chargebeeapps__Product_Type__c =='ADDON')
			{
				oitem.TotalPrice=calculateOriginalPrice(Integer.valueOf(oitem.TotalPrice*100),oitem.Discount);
				string plantype = oitem.Product2.chargebeeapps__Addon_Type__c;
				string chargeModel = oitem.Product2.chargebeeapps__Recurring_charge_model__c;
				displayButton = true;

				PricebookEntry selectedProduct;
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
						List<chargebeeapps__CB_Pricing_Tiers__c> pricingTiers = ProductService.getPricingTiers(pbId);
						Decimal price= ProductService.getPrice(plantype,pricingTiers,Integer.valueOf(oitem.Quantity));

						ax = new AddonObject(oitem.Product2.ExternalId,integer.valueOf(oitem.Quantity),i,price,true,2);

						List<Map<String,Object>> tierdataAddon=UiUtil.getTierMetric(pbId,plantype,integer.valueOf(oitem.Quantity),pricingTiers);
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
		Map<string,List<string> > mandatryadd = ProductService.getMandatoryAddon(plan.cbId, domain);
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
		}
	}
}

public CreateQuoteController() {
	couponError='';
	be = new BaseError();
	isSiteConnected = false;
	oppId = ApexPages.currentPage().getParameters().get('opp_id');
	domain = System.currentPageReference().getParameters().get('domain');
	siteId = SiteUtil.getSiteId(domain);
	qtyVaried=null;
	
	displayButton = false;
	removeButton = false;
	billingCycles=null;
	
	//new
	oppProd = null;
	urlUtil=null;
	plan = new PlanObject('', 1, 0.0, '', 0.0);
	values=0;
	values1=0;
	coupon='';
	addonId=-1;
	addontrigger='';
	selList = new List<AddonObject>();
	selListNonrecur = new List<AddonObject>();
	domain='';
	siteId='';
	oppCur='';
	couponObj=null;
	addonOptions = new List<SelectOption>();
	addonOptionsNonrecur = new List<SelectOption>();
	planOptions = new List<System.SelectOption>();
	couponOptions = new List<System.SelectOption>();

	con_id = ApexPages.currentPage().getParameters().get('con_id');
	con_id = String.escapeSingleQuotes(con_id);
	String que = 'select Account.Name,Name,LastName, FirstName,Email, AccountId, Phone, MobilePhone, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, chargebeeapps__Auto_collection__c, chargebeeapps__External_Id__c from contact where id=:con_id';
	cont=Database.query(que);

	if(domain!='') {
		loadFromOpportunity(siteId);
	}
}

public PageReference validate(){
	if(plan.cbId=='-1' ) {
		be =new BaseError('Please select a plan');
		return null;
	}
	if(oppCur!=null && plan.planCurrency!=oppCur) {
		be =new BaseError('Plan currency is different from Opportunity currency.');
		return null;
	}
	if(plan.qty==null || plan.qty==0 ) {
		be =new BaseError('Quantity can not be 0 or empty');
		//displayPlanQty =true;
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
		if(addon.addonCurrency != plan.planCurrency) {
			be =new BaseError('Currency of '+ plan.cbId+ ' should not be different from '+ addon.addon);
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
		if(addon.addonCurrency != plan.planCurrency) {
			be =new BaseError('Currency of '+ plan.cbId + ' should not be different from ' + addon.addon);
			return null;
		}
		dupAddon.add(addon.addon);
	}
	if(validateCoupon()) {
		return createQuote();
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
			        && ((List<String>)couponObj.get('plan_ids')).contains(plan.cbId)) {
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
	subPriceInCents+=getTotalAmount(plan.qty,plan.price,plan.cbId,'plan');
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
public Decimal applyCoupon(Map<String,Object> coupon, String cbId,Decimal price,String type){
	String constraint='plan_constraint';
	String list_name='plan_ids';
	if(type=='addon') {
		constraint='addon_constraint';
		list_name='addon_ids';
	}
	if(coupon!=null && (String)coupon.get(constraint)!='none') {
		Integer priceInCents=Integer.valueOf(price*100);
		if((String)coupon.get(constraint)=='all') {
			return calculateDiscount(coupon,priceInCents);
		}
		else if((String)coupon.get(constraint)=='specific') {
			List<object> ids=(List<object>)coupon.get(list_name);
			if(ids.contains(cbId)) {
				return calculateDiscount(coupon,priceInCents);
			}
		}
		else if((String)coupon.get(constraint)=='not_applicable') {
			return calculateDiscount(coupon,subPriceInCents);
		}
	}
	return 0.0;
}
public Decimal calculateDiscount(Map<String,Object> coupon,Integer priceInCents){
	if((String)coupon.get('discount_type')=='percentage') {
		return (Decimal)coupon.get('discount_percentage');
	}
	else{//fixed amount
		Integer discount_amount=(Integer)coupon.get('discount_amount');
		if(discount_amount>=priceInCents) {
			return 100.00;
		}
		else{
			return ((Decimal.valueOf(discount_amount)*100)/Decimal.valueOf(priceInCents)).setScale(2);
		}
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


public boolean IsNewPricingModel(String planId){
	if(planId != '-1') {
		Product2 Product = [Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c From Product2 where Product2.ExternalId =:planId];
		String plantype=Product.chargebeeapps__Recurring_charge_model__c;
		return (plantype=='Tiered' || plantype=='Stairstep' || plantype=='Volume');
	}
	return false;
}

public PageReference createQuote(){

	List<chargebeeapps__Contact_Associate_Site__c> existingConSite = [SELECT Id,chargebeeapps__Contact__c,chargebeeapps__External_Id__c,chargebeeapps__CB_Site__c FROM chargebeeapps__Contact_Associate_Site__c WHERE (chargebeeapps__Contact__c =: cont.Id AND chargebeeapps__CB_Site__c =:siteId)];

	EndPoint ep = EndPointsIndex.create_subscription_quote;
	ep.domainName(domain);

	List<String> liststr = new List<String>();
	liststr.add(EncodingUtil.urlEncode(existingConSite[0].chargebeeapps__External_Id__c,'UTF-8'));
	ep.replace(liststr);

	CreateQuoteUrlBuilder br = new CreateQuoteUrlBuilder(ep);
	Integer quan = CBSubscriptionUtil.isFlatPlan(plan.cbId) ? 1 : plan.qty;

	br.planId(plan.cbId)
	.planQuan(String.valueOf(quan))
	.billingCycles(billingCycles)
	.couponId(coupon);

	Decimal planSetupFee = null;
	if( canOverRide ) {
		if(!IsNewPricingModel(plan.cbId)) {
			br.planUnitPrice(String.valueOf(ChargebeeUtil.convertToLowerOrderCurrency(plan.planCurrency,Double.valueOf(plan.price))));
		}
		if(!IsNewPricingModel(plan.cbId)) {
			br.planSetupFee(String.valueOf(ChargebeeUtil.convertToLowerOrderCurrency(plan.planCurrency,Double.valueOf(plan.setupFee))));
		}
	}

	List<chargebeeapps.AddonObject> selectedAddons = new List<chargebeeapps.AddonObject>();
	selectedAddons.addAll(selList);
	selectedAddons.addAll(selListNonrecur);

	br.ustring = CBSubscriptionUtil.getAddonURLWithOutMap(selectedAddons,br.ustring, canOverRide);

	System.debug('input'+br.ustring);

	GenericController ctllr = new GenericController(br);
	Map<String, Object> responseMap = ctllr.makeRequest();
	be = new BaseError(responseMap);
	system.debug('er'+be.isErr);
	if(!be.isErr) {
		QuoteObj quoteObj = new QuoteObj((Map<String, Object>)responseMap.get('quote'));
		String quoteId = quoteObj.getId();
		system.debug('quote_id'+quoteId);

		if(quoteId != null && quoteId != '')
		{
			try {
				chargebeeapps__CB_Quote__c quote = QuoteService.saveNewQuote(quoteObj, oppProd, existingConSite[0].chargebeeapps__Contact__c, siteId,
				                                                             domain,coupon, plan, selectedAddons);

				QuoteService.saveToThirdPartyEntityMapping(quoteId, quote.Id, domain, oppProd.Id, JSON.serialize(responseMap.get('quote')));
				return page_redirect(quote.Id);
			}catch(Exception exp) {
				be = new BaseError('CB Exception '+exp);
				return null;
			}
		}
	}
	return null;
}

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
		if(urlUtil!= null)
			return urlUtil.canOverRide();
		return false;
	} set;
}


public PageReference CbPriceBookEntry()
{
	if(plan.cbId != '-1') {
		PricebookEntry selectedProduct;
		if(isMultiCurrencyEnabled) {
			String planId = plan.cbId;
			selectedProduct = Database.query('Select Id,Product2.Name,Product2.ExternalId,Product2.chargebeeapps__Addon_Applicability__c,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, PricebookEntry.CurrencyIsoCode,product2.chargebeeapps__Currency__c From PricebookEntry  where Product2.ExternalId =:planId  And Pricebook2.chargebeeapps__CB_Site__c=\''+siteId+'\' and product2.chargebeeapps__Status__c=\'ACTIVE\' and (product2.chargebeeapps__Product_Type__c=\'PLAN\' or product2.chargebeeapps__Product_Type__c=\'ADDON\')');
			plan.planCurrency = (String)selectedProduct.get('CurrencyIsoCode');
		}
		else{
			selectedProduct = [Select Id,Product2.Name,Product2.ExternalId,Product2.chargebeeapps__Addon_Applicability__c,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, product2.chargebeeapps__Currency__c From PricebookEntry where Product2.ExternalId =:plan.cbId And Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' and (product2.chargebeeapps__Product_Type__c='PLAN' or product2.chargebeeapps__Product_Type__c='ADDON')];
			plan.planCurrency = selectedProduct.product2.chargebeeapps__Currency__c;
		}

		string pbId = string.valueOf(selectedProduct.Id);
		string plantype = selectedProduct.product2.chargebeeapps__Recurring_charge_model__c;
		plan.model = planType;

		if(selectedProduct.chargebeeapps__Setup_Cost__c!=null){
			plan.hasSetupFee=true;
			plan.setupFee=selectedProduct.chargebeeapps__Setup_Cost__c;
        } else {
			plan.hasSetupFee=false;
			plan.setupFee=0.0;
		}
		if(qtyVaried!='changedQty')
		{
			plan.price = selectedProduct.UnitPrice;
		}

		if(plantype != null && ( plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')||plantype.equalsIgnoreCase('Volume')))
		{
			List<chargebeeapps__CB_Pricing_Tiers__c> pricingTiers = ProductService.getPricingTiers(pbId);

			if(plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep'))
			{
				List<Map<String,Object>> tierdata=UIUtil.getTierMetric(pbId,plantype,plan.qty, pricingTiers);
				if(tierdata != null & !tierdata.isEmpty())
				{
					plan.tierdata = tierdata;
				}
			}
			plan.price=ProductService.getPrice(planType, pricingTiers, plan.qty);
		}
		if(qtyVaried !='changedQty')
		{
			selList = new List<AddonObject>();
			selListNonrecur = new List<AddonObject>();
			string attachedaddon = selectedProduct.product2.chargebeeapps__Addon_Applicability__c;
			sendRequestToPlan(selectedProduct.Product2.ExternalId,selectedProduct.Product2.Name,attachedaddon);
		}
		qtyVaried =null;
	}
	return null;
}
public void populateAddonList(){

	List<PricebookEntry> rec = ProductService.getRecurringAddonForSite(siteId);
	addonOptions = UIUtil.getPlanAddonOptions(rec);

	List<PricebookEntry> nonRec = ProductService.getNonRecurringAddonForSite(siteId);
	addonOptionsNonrecur = UIUtil.getPlanAddonOptions(nonRec);

}
public void filladdons(List<string> ids){

	Set<String> externalIds = new Set<String>(ids);

	List<PricebookEntry> cbaddonApp = ProductService.getAddons(externalIds, siteId);
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
	Map<String, Object> responseMap = ProductService.getPlan(planid, domain);
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
	Map<String, Integer> mandatoryAddonsQty = new Map<String, Integer>();
	Map<String, Integer> recommendedAddonQty = new Map<String, Integer>();

	if(attachedAddons!=null)
		for(Object o:attachedAddons) {
			Map<String, Object> adns = (Map<String, Object>)o;
			String addid = (string)adns.get('id');
			String addType = (string)adns.get('type');
			Integer qty = (Integer)adns.get('quantity');
			String obj = (string)adns.get('object');
			if(addType.equalsIgnoreCase('recommended') )
			{
				recommendedAddonQty.put(addid, qty);

			}else if(addType.equalsIgnoreCase('mandatory') ) {
				mandatoryAddonsQty.put(addid,qty);
			}
		}
	//mandatory addons
	if(mandatoryAddonsQty.size()>0) {
		Set<String> mandatoryAddons = mandatoryAddonsQty.keySet();
		List<PricebookEntry> cbaddons = ProductService.getAddons(mandatoryAddons,siteId);
		
		for(PricebookEntry cbb:cbaddons) {
			i++;
			displayButton =true;

			string plantype = cbb.product2.chargebeeapps__Addon_Type__c;
			string pbId = string.valueOf(cbb.Id);
			string chargeModel = cbb.product2.chargebeeapps__Recurring_charge_model__c;
			Integer qty=mandatoryAddonsQty.get(cbb.product2.ProductCode);
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
					List<Map<String,Object>> tierdataAddon=UIUtil.getTierMetric(pbId,plantype,qty, pricingTiers);
					if(tierdataAddon != null & !tierdataAddon.isEmpty())
					{
						ax.tierdata=tierdataAddon;
					}
				} else {
					ax = new AddonObject(cbb.Product2.ExternalId,qty,i,cbb.UnitPrice,true,2);
				}
				ax.model = plantype;
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
	if(recommendedAddonQty.size()>0) {
		Set<String> recommendedAddons = recommendedAddonQty.keySet();
		List<PricebookEntry> cbaddons = ProductService.getAddons(recommendedAddons,siteId);
		for(PricebookEntry cbb:cbaddons) {
			j++;
			displayButton =true;

			string plantype = cbb.product2.chargebeeapps__Addon_Type__c;
			string pbId = string.valueOf(cbb.Id);
			string chargeModel = cbb.product2.chargebeeapps__Recurring_charge_model__c;
			Integer qty=recommendedAddonQty.get(cbb.product2.ProductCode);
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
					List<Map<String,Object>> tierdataAddon=UIUtil.getTierMetric(pbId,plantype,qty);
					if(tierdataAddon != null & !tierdataAddon.isEmpty())
					{
						ax.tierdata=tierdataAddon;
					}
				} else{
					ax = new AddonObject(cbb.Product2.ExternalId,qty,j,cbb.UnitPrice,true,2);
				}
				ax.removeAddon=false;
				ax.model = plantype;
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
	return null;
}

public Map<String, Object> getCouponDetails(string couponId)
{
	return chargebeeapps.CouponService.getCouponDetails(couponId, domain);
}

public PageReference CbPriceBookEntryAddon()
{
	AddonObject selectedAddon=selList.get(addonId-1);
	updateAddonProperties(selectedAddon);
	return null;
}

public PageReference CbPriceBookEntryAddon1()
{
	AddonObject selectedAddon=selListNonrecur.get(addonId-1);
	updateAddonProperties(selectedAddon);
	return null;
}

private void updateAddonProperties(chargebeeapps.AddonObject selectedAddon)
{
	String addonName=selectedAddon.addon;
	Integer addonqty = selectedAddon.qty;
	PricebookEntry selectedProduct;
	if(isMultiCurrencyEnabled) {
		selectedProduct = Database.query('Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, PricebookEntry.CurrencyIsoCode,product2.chargebeeapps__Currency__c From PricebookEntry  where Product2.ExternalId =:addonName And Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c=\'ACTIVE\' and product2.chargebeeapps__Product_Type__c=\'ADDON\'');
		selectedAddon.addonCurrency = (String)selectedProduct.get('CurrencyIsoCode');
	}
	else{
		selectedProduct = [Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, product2.chargebeeapps__Currency__c From PricebookEntry where Product2.ExternalId =:addonName And Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' and product2.chargebeeapps__Product_Type__c='ADDON'];
		selectedAddon.addonCurrency = selectedProduct.product2.chargebeeapps__Currency__c;
	}
	string pbId = string.valueOf(selectedProduct.Id);
	String plantype=selectedProduct.product2.chargebeeapps__Addon_Type__c;
	selectedAddon.model = plantype;

	if(plantype == null || plantype.equalsIgnoreCase('Flat_Fee') || plantype.equalsIgnoreCase('Quantity')|| plantype=='per_unit')
	{
		if(qtyVaried!='changedQty')
		{
			selectedAddon.price = selectedProduct.UnitPrice;
		}
	}
	if(plantype != null && ( plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')||plantype.equalsIgnoreCase('Volume')))
	{
		List<chargebeeapps__CB_Pricing_Tiers__c> pricingTiers =[Select Id,Name,chargebeeapps__PriceBookEntryId__c,chargebeeapps__ExternalId__c,chargebeeapps__Lower_Limit__c, chargebeeapps__Upper_Limit__c,chargebeeapps__Price__c From chargebeeapps__CB_Pricing_Tiers__c Where chargebeeapps__PriceBookEntryId__c=:pbId ORDER BY chargebeeapps__Lower_Limit__c ASC];

		selectedAddon.price  = ProductService.getPrice(plantype,pricingTiers,addonqty);

		if(plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep'))
		{
			List<Map<String,Object>> tierdataAddon=UIUtil.getTierMetric(pbId,plantype,addonqty, pricingTiers);
			if(tierdataAddon != null & !tierdataAddon.isEmpty())
			{
				selectedAddon.tierdata=tierdataAddon;
			}
		}
	}
	qtyVaried=null;
}

public PageReference page_redirect(){
	return page_redirect(oppProd.Id);
}

private PageReference page_redirect(String url){
	PageReference pageRef = new PageReference('/'+url);
	pageRef.setRedirect(true);
	return pageRef;
}
}