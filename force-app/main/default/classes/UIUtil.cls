public class UIUtil {
public UIUtil() {

}

public static List<SelectOption> getSiteDetails(String contactId) {
	List<String> domains = new List<String>();
	List<chargebeeapps__Contact_Associate_Site__c> syncedSites = getSitesForContact(contactId);
	for(chargebeeapps__Contact_Associate_Site__c siteList:syncedSites)
	{
		string sid = siteList.chargebeeapps__CB_Site__c;
		String domain=SiteUtil.getSiteName(sid);
		domains.add(domain);
	}
	return getSiteOptions(domains);
}

public static List<SelectOption> getSiteDetailsWithQuotesEnabled(String contactId) {
	List<String> domains = new List<String>();
	List<chargebeeapps__Contact_Associate_Site__c> syncedSites = getSitesForContact(contactId);
	for(chargebeeapps__Contact_Associate_Site__c siteList:syncedSites)
	{
		string sid = siteList.chargebeeapps__CB_Site__c;
		String domain=SiteUtil.getSiteName(sid);
		CBURLUtil urlUtil = new CBURLUtil(domain);
		if(urlUtil.isQuotesEnabled())
			domains.add(domain);
	}
	return getSiteOptions(domains);
}

private static List<System.SelectOption> getSiteOptions(List<String> domains) {
	List<selectOption> multiSites = new List<selectOption>();
	for(String domain: domains) {
		multiSites.add(new SelectOption(domain,domain));
	}
	return multiSites;
}

private static List<chargebeeapps__Contact_Associate_Site__c> getSitesForContact(String contactId) {
	List<chargebeeapps__Contact_Associate_Site__c> syncedSites = 
		[SELECT chargebeeapps__Contact__c,chargebeeapps__External_Id__c,chargebeeapps__CB_Site__c
	                                                              FROM chargebeeapps__Contact_Associate_Site__c 
																  WHERE chargebeeapps__Contact__c =: contactId 
																  AND chargebeeapps__External_Id__c != null];
	return syncedSites;
}

private static Boolean isMultiCurrencyEnabled = null;

public static Boolean isMultiCurrencyEnabled() {
	if(isMultiCurrencyEnabled==null)
		isMultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
	return isMultiCurrencyEnabled;
}

public static Map<String,String> getPlanExternalIdVsChargeModel(Boolean isMultiCurrencyEnabled, String siteId) {
	List<PricebookEntry> prodList = new List<PricebookEntry>();
	if(isMultiCurrencyEnabled) {
		//System.debug('isMultiCurrencyEnabledinnnn----'+isMultiCurrencyEnabled);
		prodList = Database.query('Select id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, PricebookEntry.CurrencyIsoCode From PricebookEntry  where Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c=\'ACTIVE\' and (product2.chargebeeapps__Product_Type__c=\'PLAN\' or product2.chargebeeapps__Product_Type__c=\'ADDON\') limit 500');
	}else{
		prodList = [Select id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,product2.chargebeeapps__Addon_Type__c,
		            product2.chargebeeapps__Product_Type__c,PricebookEntry.chargebeeapps__Setup_Cost__c,PricebookEntry.UnitPrice, product2.chargebeeapps__Currency__c
		            From PricebookEntry
		            where Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE'
		                                                                                                      and (product2.chargebeeapps__Product_Type__c='PLAN' or product2.chargebeeapps__Product_Type__c='ADDON') limit 500];
	}

	Map<String,String> PlanExternalIdVsChargeModel = new Map<String,String>();

	for(PricebookEntry temp : prodList)
	{
		//System.debug('eeeee----- '+temp.Product2.ExternalId);
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

	return PlanExternalIdVsChargeModel;
}

public static List<SelectOption> getPlanOptions(String siteId) {
	System.debug('planSite'+siteId);
	List<PricebookEntry> prodList = ProductService.getPlans(siteId);
	return getPlanAddonOptions(prodList);
}

public static List<System.SelectOption> getPlanAddonOptions(List<PricebookEntry> planAddonList) {
	List<SelectOption> planOptions = new List<SelectOption>();
	planOptions.add(new SelectOption('-1','Select'));
	for(PricebookEntry temp : planAddonList) {
		if(temp.Product2.ExternalId!= null) {
			planOptions.add(new SelectOption(temp.Product2.ExternalId,temp.Product2.name));
		}
	}
	return planOptions;
}

public static List<SelectOption> getAddonOptions(String siteId) {
	List<PricebookEntry> prodList = ProductService.getAllAddons(siteId);
	return getPlanAddonOptions(prodList);
}

public static List<SelectOption> getCouponOptions(String siteId) {
	List<chargebeeapps__Coupon__c> prodList = new List< chargebeeapps__Coupon__c>();

	prodList = [Select chargebeeapps__CB_Coupon_Id__c,Name,chargebeeapps__Status__c
	            From chargebeeapps__Coupon__c where chargebeeapps__CB_Site__c=:siteId 
				and chargebeeapps__Status__c = 'ACTIVE'
	        	order by Name limit 500];
	List<SelectOption> couponOptions = new List<SelectOption>();
	couponOptions.add(new SelectOption('-1','Select'));
	for(chargebeeapps__Coupon__c temp : prodList) {
		if(temp.chargebeeapps__CB_Coupon_Id__c != null) {
			couponOptions.add(new SelectOption(temp.chargebeeapps__CB_Coupon_Id__c,temp.name));
		}
	}
	return couponOptions;
}

public static chargebeeapps__Coupon__c getCoupon(String cbId, String siteId) {
	chargebeeapps__Coupon__c coupon = [Select Id from chargebeeapps__Coupon__c 
		where chargebeeapps__CB_Site__c=:siteId and chargebeeapps__CB_Coupon_Id__c=:cbId];
	return coupon;
}

public static List<Map<String,Object> > getTierMetric(String pbId,String plantype,Integer quantity)
{
	List<chargebeeapps__CB_Pricing_Tiers__c> pricingTiers = ProductService.getPricingTiers(pbId);

	return getTierMetric(pbId, plantype, quantity, pricingTiers);
}
public static List<Map<String,Object> > getTierMetric(String pbId,String plantype,Integer quantity, List<chargebeeapps__CB_Pricing_Tiers__c> pricingTiers)
{
	List<Map<String,Object> > tierdata=new List<Map<String,Object> >();

	for(chargebeeapps__CB_Pricing_Tiers__c cbp:pricingTiers)
	{
		Map<String,Object> tierrow=new Map<String,Object>();

		if(plantype.equalsIgnoreCase('Stairstep'))
		{
			if(cbp.chargebeeapps__Upper_Limit__c != null && quantity >= cbp.chargebeeapps__Lower_Limit__c )
			{
				tierrow.put('Tier',' Upto '+cbp.chargebeeapps__Upper_Limit__c);
				tierrow.put('Price',cbp.Price__c);
				tierrow.put('UnitRate','');
			}
			else if (cbp.chargebeeapps__Upper_Limit__c == null && quantity >= cbp.chargebeeapps__Lower_Limit__c)
			{
				tierrow.put('Tier',cbp.chargebeeapps__Lower_Limit__c+'&'+'above');
				tierrow.put('Price',cbp.chargebeeapps__Price__c);
				tierrow.put('UnitRate','');
			}
		}
		else if(plantype.equalsIgnoreCase('Tiered'))
		{
			Integer tierquantity;
			if(cbp.chargebeeapps__Upper_Limit__c != null && quantity >= cbp.chargebeeapps__Lower_Limit__c && quantity >= cbp.chargebeeapps__Upper_Limit__c)
			{
				tierquantity=Integer.valueOf(cbp.chargebeeapps__Upper_Limit__c - cbp.chargebeeapps__Lower_Limit__c) +1;
				tierrow.put('Tier',cbp.chargebeeapps__Lower_Limit__c+' - '+cbp.chargebeeapps__Upper_Limit__c);
			}
			else if(cbp.chargebeeapps__Upper_Limit__c != null && quantity >= cbp.chargebeeapps__Lower_Limit__c && quantity < cbp.chargebeeapps__Upper_Limit__c)
			{
				tierquantity= Integer.valueOf(quantity - cbp.chargebeeapps__Lower_Limit__c) + 1;

				if( quantity == cbp.chargebeeapps__Lower_Limit__c ) {
					tierquantity=1;
				}
				tierrow.put('Tier',cbp.chargebeeapps__Lower_Limit__c+' - '+cbp.chargebeeapps__Upper_Limit__c);
			}
			else if(cbp.chargebeeapps__Upper_Limit__c == null && quantity >= cbp.chargebeeapps__Lower_Limit__c )
			{
				tierquantity = Integer.valueOf(quantity - cbp.chargebeeapps__Lower_Limit__c) + 1;

				if( quantity == cbp.chargebeeapps__Lower_Limit__c) {
					tierquantity=1;
				}
				tierrow.put('Tier',cbp.chargebeeapps__Lower_Limit__c+' & '+'above');
			}

			if(tierquantity != null) {
				tierrow.put('UnitRate',tierquantity +' * '+cbp.chargebeeapps__Price__c);
				tierrow.put('Price',tierquantity  * cbp.chargebeeapps__Price__c);
			}
		}
		if(!tierrow.isEmpty()) {
			tierdata.add(tierrow);
		}
	}
	//System.debug(' Tiered Data for Id  ' + pbId + ' Plan Type ' + plantype + ' is ' + tierdata);
	return tierdata;
}

public static Pagereference redirectToGeneralErrorPage(String msg,String id) {
	PageReference pageRef = new PageReference('/apex/General_err');
	pageRef.getParameters().put('err',msg);
	pageRef.getParameters().put('id',id);
	pageRef.setRedirect(true);
	return pageRef;
}


}