public class QuoteService {
public QuoteService() {

}

@future(callout=true)
public static  void getQuotePDFAsAttachment(String sfId, String quoteCBId,String site) {
	Map<String, Object> resp = getPdfS3Link(quoteCBId,site);
	BaseError er = new BaseError(resp);
	if(!er.isErr) {
		Blob content = getPdfContent((String)((Map<String,Object>)resp.get('download')).get('download_url'));
        chargebeeapps__CB_Quote__c quote = [Select chargebeeapps__CB_Quote_Id__c
            From chargebeeapps__CB_Quote__c where Id=:sfId];
        createAttachment(quote, content);
	}
}

private static void createAttachment(chargebeeapps__CB_Quote__c quote,Blob content){
	Attachment attach = new Attachment();
	attach.Body =content;
	attach.Name = 'Quote_'+quote.chargebeeapps__CB_Quote_Id__c;
	attach.IsPrivate = false;
	attach.contentType = 'application/pdf';
	attach.ParentId = quote.Id;
	try{
		insert attach;
	}catch(Exception exp) {}
}

private static Blob getPdfContent(String link){
	HttpRequest reqData = new HttpRequest();
	Http http = new Http();
	reqData.setTimeout(20000);
	reqData.setEndpoint(link);
	reqData.setMethod('GET');
	HTTPResponse res = http.send(reqData);
	return res.getBodyAsBlob();

}

private static Map<String, Object> getPdfS3Link(String quoteCBId,String site){
	EndPoint ep = getPdfEndpoint(quoteCBId,site);
	GenericURLBuilder br = new GenericURLBuilder(ep);
	GenericController ctllr = new GenericController(br);
	return ctllr.makeRequest();
}

private static EndPoint getPdfEndpoint(String quoteCBId,String site){
	EndPoint ep = EndPointsIndex.get_quote_pdf;
	ep.domainName(site);
	List<String> liststr = new List<String>();
	liststr.add(quoteCBId);
	ep.replace(liststr);
	return ep;
}

public static chargebeeapps__CB_Quote__c getQuote(String id) {
	boolean isMultiCurrencyEnabled = UIUtil.isMultiCurrencyEnabled();
	return getQuote(id, isMultiCurrencyEnabled);
}

public static chargebeeapps__CB_Quote__c getQuote(String quoteId, Boolean multiCurrencyEnabled) {
	if(multiCurrencyEnabled) {
		return Database.query('Select Id, chargebeeapps__CB_Site__c, chargebeeapps__Opportunity__c, CurrencyIsoCode ' +
		                       'from chargebeeapps__CB_Quote__c where Id=:quoteId');
	} else {
		return [Select Id, chargebeeapps__CB_Site__c, chargebeeapps__Opportunity__c from chargebeeapps__CB_Quote__c where Id=:quoteId];
	}
}

public static List<chargebeeapps__CB_Quote_Product__c> getQuoteProducts(String id) {
	boolean isMultiCurrencyEnabled = UIUtil.isMultiCurrencyEnabled();
	return getQuoteProducts(id, isMultiCurrencyEnabled);
}

public static List<chargebeeapps__CB_Quote_Product__c> getQuoteProducts(String quoteId, Boolean multiCurrencyEnabled) {
	if(multiCurrencyEnabled) {
		return Database.query('Select Id, CurrencyIsoCode, chargebeeapps__Quantity__c, ' +
		                               'chargebeeapps__UnitPrice__c, chargebeeapps__Product__r.Id, chargebeeapps__Discount__c ' +
		                               'from chargebeeapps__CB_Quote_Product__c where chargebeeapps__CB_Quote__c=:quoteId');
	} else {
		return [Select Id, chargebeeapps__Quantity__c,
		                 chargebeeapps__UnitPrice__c, chargebeeapps__Product__r.Id, chargebeeapps__Discount__c
		                 from chargebeeapps__CB_Quote_Product__c where chargebeeapps__CB_Quote__c=:quoteId];
	}

}

@future
public static void syncToOpportunity(String quoteId) {
	boolean isMultiCurrencyEnabled = UIUtil.isMultiCurrencyEnabled();

	chargebeeapps__CB_Quote__c quote = getQuote(quoteId, isMultiCurrencyEnabled);
	List<chargebeeapps__CB_Quote_Product__c> quoteProducts = getQuoteProducts(quoteId, isMultiCurrencyEnabled);
	chargebeeapps__CB_Quote_Coupon__c quoteCoupon = null;
	Opportunity opp = null;

    List<chargebeeapps__CB_Quote_Coupon__c> quoteCoupons = [Select Id, Name,chargebeeapps__CB_Coupon__c from chargebeeapps__CB_Quote_Coupon__c where chargebeeapps__CB_Quote__c=:quoteId];

    if(quoteCoupons.size() >0)
	    quoteCoupon = quoteCoupons.get(0);

	if(quote.chargebeeapps__Opportunity__c!= null) {
		opp = [Select Id, Pricebook2Id from Opportunity where Id=:quote.chargebeeapps__Opportunity__c];
		syncToOpportunity(quote, quoteProducts, quoteCoupon, opp);
	}
}

private static void syncToOpportunity(chargebeeapps__CB_Quote__c quote,
                                     List<chargebeeapps__CB_Quote_Product__c> quoteProducts,
                                     chargebeeapps__CB_Quote_Coupon__c quoteCoupon,
                                     Opportunity opp) {

	OpportunityService oppService = new OpportunityService(opp.Id);
	oppService.deleteOpportunityLineItems();

	boolean isMultiCurrencyEnabled = UIUtil.isMultiCurrencyEnabled();

	Pricebook2 pb=[select Id,chargebeeapps__CB_Site__c From PriceBook2 Where Pricebook2.chargebeeapps__CB_Site__c=:quote.chargebeeapps__CB_Site__c];
	if(opp.Pricebook2Id!=pb.Id) {
		opp.Pricebook2Id=pb.Id;
	}

	if(quoteCoupon != null) {
		opp.Coupon__c=quoteCoupon.chargebeeapps__CB_Coupon__c;
	}
	else{
		opp.Coupon__c=null;
	}

	/*if(isMultiCurrencyEnabled)
		opp.put('CurrencyIsoCode', quote.get('CurrencyIsoCode'));*/

	update opp;

	List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();

	for(chargebeeapps__CB_Quote_Product__c quoteProduct : quoteProducts) {

        PricebookEntry pricebookEntry=[Select id,Product2.Id,Product2.ExternalId, Product2.chargebeeapps__Recurring_charge_model__c,
            Product2.chargebeeapps__Product_Type__c
            From PricebookEntry
		    Where Product2.Id=:quoteProduct.chargebeeapps__Product__r.Id
		    and Pricebook2.chargebeeapps__CB_Site__c=:quote.chargebeeapps__CB_Site__c];

        if(pricebookEntry.Product2.chargebeeapps__Product_Type__c == 'ADDON' &&
            pricebookEntry.Product2.chargebeeapps__Recurring_charge_model__c == 'NON_RECURRING') {
            continue;
            //non-recurring addons are not added to the opportunity
        }

		OpportunityLineItem obj=new OpportunityLineItem();
		obj.Quantity=quoteProduct.chargebeeapps__Quantity__c;
		obj.UnitPrice=quoteProduct.chargebeeapps__UnitPrice__c;
		obj.Product2Id=quoteProduct.chargebeeapps__Product__r.Id;
		obj.Discount=quoteProduct.chargebeeapps__Discount__c;
		obj.OpportunityId=opp.Id;

		obj.PricebookEntryId=pricebookEntry.Id;

		if(isMultiCurrencyEnabled)
			obj.put('CurrencyIsoCode', quoteProduct.get('CurrencyIsoCode'));

		opportunityLineItems.add(obj);
	}

	insert opportunityLineItems;
}

@future(callout=true)
public static void updateChargebeeQuoteStatus(String quoteId, String domain, String status) {
	EndPoint ep = EndPointsIndex.update_status_quote;
	ep.domainName(domain);

	List<String> liststr = new List<String>();
	liststr.add(EncodingUtil.urlEncode(quoteId,'UTF-8'));
	ep.replace(liststr);

	GenericURLBuilder urlBuilder = new GenericURLBuilder(ep);
	urlBuilder.param('status', status);
	GenericController ctllr = new GenericController(urlBuilder);
	Map<String, Object> responseMap = ctllr.makeRequest();
}

@future(callout = true)
public static void saveToThirdPartyEntityMapping(String quoteId, String thirdPartyEntityId, String dominName, String oppId,
    String quoteJson) {
	try {
		CBURLUtil urlUtil = new CBURLUtil(dominName);
		String bodyData = CBURLUtil.buildURLString('', 'entity_id',quoteId);
		bodyData = chargebeeapps.CBURLUtil.buildURLString(bodyData, 'third_party_entity_id', thirdPartyEntityId);
        bodyData = chargebeeapps.CBURLUtil.buildURLString(bodyData, 'old_resource', quoteJson);
		bodyData = CBSubscriptionUtil.getDataForTpSyncQuotes(oppId, bodyData,'SYNCED');
        String updateTPEndpoint = CBSubscriptionUtil.getUpdateTPEndPoint(urlUtil);
		String responseFromNet = CBURLUtil.sendRequest(updateTPEndpoint, bodyData, urlUtil, true);
	}catch(Exception exp) {
		String responseFromNet = 'CB Exception '+exp;
	}
}

public static chargebeeapps__CB_Quote__c saveNewQuote(QuoteObj quoteObj, Opportunity opp, String contactSfId, String siteId,String domainName,
        String coupon, PlanObject plan, List<chargebeeapps.AddonObject> selList) {
	return saveNewQuote(quoteObj, opp, contactSfId, siteId, domainName, coupon, plan, selList, null);
}

public static chargebeeapps__CB_Quote__c saveNewQuote(QuoteObj quoteObj, Opportunity opp, String contactSfId, String siteId,String domainName,
        String coupon, PlanObject plan, List<chargebeeapps.AddonObject> selList, CB_Subscription__c subscription) {

    boolean isMultiCurrencyEnabled = UIUtil.isMultiCurrencyEnabled();

	Integer subscriptionValueInCents = chargebeeapps.CouponService.calculateSubscriptionAmount(plan, selList, siteId);

    Map<String, Object> couponResponse=CouponService.getCouponDetails(coupon, domainName);


	String opportunityId = null;
	if(opp != null) {
		opportunityId = opp.Id;
		upsert opp;
	}

	chargebeeapps__CB_Quote__c quote = new chargebeeapps__CB_Quote__c(
		chargebeeapps__Company__c = opp.AccountId,
		chargebeeapps__Operation_Type__c = quoteObj.getOperationType(),
		chargebeeapps__Opportunity__c = opportunityId,
		chargebeeapps__CB_Site__c = siteId,
		chargebeeapps__CustomerID__c = contactSfId,
		chargebeeapps__CB_Quote_Id__c = quoteObj.getId(),
		Name = quoteObj.getId(),
		chargebeeapps__Total__c = quoteObj.getTotal(),
		chargebeeapps__Due_Amount__c = quoteObj.getAmountDue(),
		chargebeeapps__PriceType__c = quoteObj.getPriceType(),
		chargebeeapps__Status__c = quoteObj.getStatus(),
		chargebeeapps__SubTotal__c = quoteObj.getSubTotal(),
		chargebeeapps__ValidTill__c = DateTime.newInstance(quoteObj.getValidTill()*1000),
		chargebeeapps__VATNumber__c = quoteObj.getVATNumber()
		);

	if(subscription!=null)
		quote.chargebeeapps__CB_Subscription__c = subscription.Id;

	if(isMultiCurrencyEnabled)
		quote.put('CurrencyIsoCode', plan.planCurrency);

	insert quote;

	List<chargebeeapps__Quote_Line_Item__c> quoteLineItems = new List<chargebeeapps__Quote_Line_Item__c>();

	for (QuoteLineItemObj quoteLineItem: quoteObj.getLineItems()) {

		chargebeeapps__Quote_Line_Item__c lineItem = new chargebeeapps__Quote_Line_Item__c(
			chargebeeapps__CB_Quote__c = quote.Id,
			chargebeeapps__Amount__c = quoteLineItem.getAmount(),
			Name = quoteLineItem.getId(),
			chargebeeapps__Discount_Amount__c = quoteLineItem.getDiscountAmount(),
			chargebeeapps__Price__c = quoteLineItem.getUnitAmount(),
			chargebeeapps__Tax_Exempt_Reason__c = quoteLineItem.getTaxExemptReason(),
			chargebeeapps__Quantity__c = quoteLineItem.getQuantity(),
			chargebeeapps__Tax_Amount__c = quoteLineItem.getTaxAmount(),
			chargebeeapps__Product_Code__c = quoteLineItem.getEntityId()
			);

		if(isMultiCurrencyEnabled)
			lineItem.put('CurrencyIsoCode', plan.planCurrency);
		quoteLineItems.add(lineItem);
	}

	insert quoteLineItems;

	List<chargebeeapps__CB_Quote_Product__c> quoteProducts = new List<chargebeeapps__CB_Quote_Product__c>();

	chargebeeapps__CB_Quote_Product__c planProduct = createQuoteProduct(plan.qty,plan.price,plan.cbId,plan.setupFee,'plan',
	                                                        quote.Id, subscriptionValueInCents, couponResponse, plan.planCurrency, siteId);
	quoteProducts.add(planProduct);

	for(AddonObject addon:selList) {
		chargebeeapps__CB_Quote_Product__c addonProduct = createQuoteProduct(Decimal.valueOf(addon.qty),addon.price,addon.addon,null,'addon',
		                                                    quote.Id, subscriptionValueInCents, couponResponse, plan.planCurrency, siteId);

		quoteProducts.add(addonProduct);
	}

	insert quoteProducts;

	chargebeeapps__CB_Quote_Coupon__c quoteCoupon = null;

	if(coupon!='-1') {
		chargebeeapps__Coupon__c couponObj = chargebeeapps.CouponService.getCoupon(coupon, siteId);

		quoteCoupon = new chargebeeapps__CB_Quote_Coupon__c();
		quoteCoupon.Name = couponObj.Name;
		quoteCoupon.chargebeeapps__CB_Quote__c = quote.Id;
		quoteCoupon.chargebeeapps__CB_Coupon__c = couponObj.Id;

		if(isMultiCurrencyEnabled)
			quoteCoupon.put('CurrencyIsoCode', plan.planCurrency);

		insert quoteCoupon;
	}

	//TODO: We should create a log object and log any silent errors. Schedule a job to clear every X days
	QuoteService.getQuotePDFAsAttachment(quote.Id, quoteObj.getId(),domainName);
	if(opp!= null)
		QuoteService.syncToOpportunity(quote.Id);

	return quote;
}

public static chargebeeapps__CB_Quote_Product__c createQuoteProduct(Decimal quantity,Decimal totalPrice, String cbId, Decimal setupFee,
    String type, String quoteId, Integer subscriptionValueInCents, Map<String, Object> couponObj, String planCurrency, String siteId){
	if(cbId=='-1') {
		return null;
	}

    boolean isMultiCurrencyEnabled = UIUtil.isMultiCurrencyEnabled();

	PricebookEntry product=new PricebookEntry();
	if(isMultiCurrencyEnabled) {
		product=Database.query('Select id,ProductCode,CurrencyIsoCode,UnitPrice,Product2.Id,Product2.ExternalId From PricebookEntry Where Product2.ExternalId=:cbId and Pricebook2.chargebeeapps__CB_Site__c=:siteId');
	} else{
		product=[Select id,ProductCode,UnitPrice,Product2.Id,Product2.ExternalId From PricebookEntry Where Product2.ExternalId=:cbId and Pricebook2.chargebeeapps__CB_Site__c=:siteId];
	}

	Product2 prod=[select id,chargebeeapps__Recurring_charge_model__c,chargebeeapps__Addon_Type__c,chargebeeapps__Currency__c from Product2 where id=:product.Product2.Id];

	chargebeeapps__CB_Quote_Product__c obj=new chargebeeapps__CB_Quote_Product__c();
	obj.chargebeeapps__CB_Quote__c=quoteId;
	obj.chargebeeapps__Product__c=product.Product2.Id;
	obj.chargebeeapps__Quantity__c=quantity;
    obj.chargebeeapps__SetupFee__c=setupFee;

	String model=prod.chargebeeapps__Recurring_charge_model__c;

	if(type=='addon') {
		model=prod.chargebeeapps__Addon_Type__c;
	}

	if(model=='per_unit'||model=='quantity') {
		obj.chargebeeapps__UnitPrice__c=totalPrice;
		totalPrice*=quantity;
	}
	else{
		obj.chargebeeapps__UnitPrice__c=totalPrice/quantity;
	}

	Decimal discountPercent = CouponService.applyCoupon(couponObj,cbId,totalPrice,type, subscriptionValueInCents);
	obj.chargebeeapps__Discount__c = discountPercent;
	obj.chargebeeapps__TotalPrice__c = totalPrice  - totalPrice * discountPercent/100;

	if(isMultiCurrencyEnabled)
		obj.put('CurrencyIsoCode', planCurrency);

	return obj;

}

}