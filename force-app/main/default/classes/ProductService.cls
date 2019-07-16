public class ProductService {
public ProductService() {

}

public static Map<String, Object> getPlan(String planId, String domain) {
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
	return responseMap;
}

public static Map<string,List<string> > getMandatoryAddon(string planid, String domain)
{
	Map<string,list<string> > defaultaddonList = new Map<string,list<string> >();
	list<string> recommendAddons = new List<string>();
	list<string> mandatoryAddons = new List<string>();
	list<string> applicableAddons = new List<string>();
	
	Map<String, Object> responseMap = getPlan(planId, domain);
	BaseError be = new BaseError(responseMap);
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

public static Decimal getPrice(String planType, List<chargebeeapps__CB_Pricing_Tiers__c> pricingTiers, Integer qty) {

	Decimal price=0;
	for(chargebeeapps__CB_Pricing_Tiers__c cbp:pricingTiers)
	{
		if(plantype.equalsIgnoreCase('Tiered'))
		{
			if(cbp.chargebeeapps__Upper_Limit__c!=null && qty >cbp.chargebeeapps__Upper_Limit__c) {
				Integer limits =  integer.valueOf(cbp.chargebeeapps__Upper_Limit__c - cbp.chargebeeapps__Lower_Limit__c)+1;
				price += limits*cbp.chargebeeapps__Price__c;
			}
			else{
				price+=(qty-cbp.chargebeeapps__Lower_Limit__c+1)*cbp.chargebeeapps__Price__c;
				break;
			}
		}
		else if(plantype.equalsIgnoreCase('Volume'))
		{
			if(cbp.chargebeeapps__Lower_Limit__c<=qty &&
			   (cbp.chargebeeapps__Upper_Limit__c>=qty || cbp.chargebeeapps__Upper_Limit__c== null))
			{
				price = qty*cbp.chargebeeapps__Price__c;
			}
		}
		else if(plantype.equalsIgnoreCase('Stairstep'))
		{
			if(cbp.chargebeeapps__Lower_Limit__c<=qty &&
			   (cbp.chargebeeapps__Upper_Limit__c>=qty || cbp.chargebeeapps__Upper_Limit__c== null))
			{
				price = cbp.chargebeeapps__Price__c;
			}
		}
	}
	return price;
}

public static List<PricebookEntry> getRecurringAddonForSite(String siteId) {
	return getAddonsWithChargeModel('RECURRING', siteId);
}

public static List<PricebookEntry> getNonRecurringAddonForSite(String siteId) {
	return getAddonsWithChargeModel('NON_RECURRING', siteId);
}

public static List<PricebookEntry> getAllAddons(String siteId) {
	return getAddonsWithChargeModel(null, siteId);
}

private static List<PricebookEntry> getAddonsWithChargeModel(String chargeModel, String siteId) {
	if(chargeModel == null) {
		return [Select id,Product2.ExternalId,product2.name,product2.chargebeeapps__Product_Type__c,product2.chargebeeapps__Addon_Type__c 
		From PricebookEntry 
		where Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' 
		and product2.chargebeeapps__Product_Type__c='ADDON' 
		order by product2.Name 
		limit 999];
	} else {
		return [Select id,Product2.ExternalId,product2.name,product2.chargebeeapps__Product_Type__c,product2.chargebeeapps__Addon_Type__c 
		From PricebookEntry where product2.chargebeeapps__Recurring_charge_model__c=:chargeModel
		and Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' 
		and product2.chargebeeapps__Product_Type__c='ADDON' 
		order by product2.Name 
		limit 999];
	}
}

public static List<PricebookEntry> getPlans(String siteId) {
	return [Select id,Product2.ExternalId,product2.name 
	From PricebookEntry 
	where Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' 
	and product2.chargebeeapps__Product_Type__c='PLAN' 
	order by product2.Name 
	limit 999];
}

public static List<PricebookEntry> getPlans(String siteId, String currencyCode) {
	boolean isMultiCurrencyEnabled = UIUtil.isMultiCurrencyEnabled();
	if(isMultiCurrencyEnabled) {
		return Database.query('Select id,Product2.ExternalId,product2.name From PricebookEntry '+
			'where Pricebook2.chargebeeapps__CB_Site__c =:siteId and product2.chargebeeapps__Status__c=\'ACTIVE\' '+
			'and product2.chargebeeapps__Product_Type__c=\'PLAN\' and PricebookEntry.CurrencyIsoCode=:currencyCode '+
			'order by product2.Name limit 999');
	}else{
		return [Select id,Product2.ExternalId,product2.name From PricebookEntry
				where Pricebook2.chargebeeapps__CB_Site__c =:siteId and product2.chargebeeapps__Status__c='ACTIVE'
				and product2.chargebeeapps__Product_Type__c='PLAN' and product2.chargebeeapps__Currency__c=:currencyCode 
				order by product2.Name 
				limit 999];
	}
}

public static List<PricebookEntry> getAddons(Set<String> externalIds, String siteId) {
	boolean isMultiCurrencyEnabled = UIUtil.isMultiCurrencyEnabled();
	if(isMultiCurrencyEnabled) {
		return Database.query('Select id,Product2.ProductCode,Product2.ExternalId,product2.chargebeeapps__Currency__c, '+
		'product2.Name,product2.chargebeeapps__Product_Type__c,product2.chargebeeapps__Addon_Type__c,PricebookEntry.UnitPrice, '+
		'product2.chargebeeapps__Recurring_charge_model__c,PricebookEntry.CurrencyIsoCode '+
		'From PricebookEntry  where Product2.ExternalId IN:externalIds and Pricebook2.chargebeeapps__CB_Site__c=:siteId '+
		'and product2.chargebeeapps__Status__c=\'ACTIVE\' and product2.chargebeeapps__Product_Type__c=\'ADDON\'');
	}
	else{
		return [Select id,Product2.ProductCode,Product2.ExternalId,product2.Name,product2.chargebeeapps__Currency__c,
		product2.chargebeeapps__Product_Type__c,product2.chargebeeapps__Addon_Type__c,PricebookEntry.UnitPrice,
		product2.chargebeeapps__Recurring_charge_model__c 
		From PricebookEntry where Product2.ExternalId IN:externalIds and Pricebook2.chargebeeapps__CB_Site__c=:siteId 
		and product2.chargebeeapps__Status__c='ACTIVE' and product2.chargebeeapps__Product_Type__c='ADDON'];
	}
}

public static List<chargebeeapps__CB_Pricing_Tiers__c> getPricingTiers(String priceBookEntryId) {
	return [Select Id,Name,chargebeeapps__PriceBookEntryId__c,chargebeeapps__ExternalId__c,chargebeeapps__Lower_Limit__c, 
	chargebeeapps__Upper_Limit__c,chargebeeapps__Price__c 
	From chargebeeapps__CB_Pricing_Tiers__c 
	Where chargebeeapps__PriceBookEntryId__c=:priceBookEntryId 
	ORDER BY chargebeeapps__Lower_Limit__c ASC];

} 

}
