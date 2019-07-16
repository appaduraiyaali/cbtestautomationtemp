public with sharing class OpportunityService {

private String oppId;

public OpportunityService(String oppId) {
	this.oppId = oppId;
}

public void deleteOpportunityLineItems(){
	OpportunityLineItem[] objects=[select Id,Name From OpportunityLineItem where OpportunityId=:oppId];
	if (OpportunityLineItem.sObjectType.getDescribe().isDeletable()) {
		delete objects;
	}
	chargebeeapps__CB_Opportunity_Product__c[] objs=[select Id,Name From chargebeeapps__CB_Opportunity_Product__c
	                                                 where chargebeeapps__Opportunity__c=:oppId];
	if (chargebeeapps__CB_Opportunity_Product__c.sObjectType.getDescribe().isDeletable()) {
		delete objs;
	}
}

public void createOppLineItem(Decimal quantity,Decimal totalPrice, String cbId,String type, String siteId, 
    Integer subscriptionValueInCents, Map<String, Object> couponObj){
	if(cbId=='-1') {
		return;
	}

	Boolean isMultiCurrencyEnabled = UIUtil.isMultiCurrencyEnabled();

	PricebookEntry product=new PricebookEntry();
	if(isMultiCurrencyEnabled) {
		product=Database.query('Select id,ProductCode,CurrencyIsoCode,UnitPrice,Product2.Id,Product2.ExternalId ' +
		                       'From PricebookEntry Where Product2.ExternalId=:cbId and Pricebook2.chargebeeapps__CB_Site__c=:siteId');
	}
	else{
		product=[Select id,ProductCode,UnitPrice,Product2.Id,Product2.ExternalId
		         From PricebookEntry Where Product2.ExternalId=:cbId and Pricebook2.chargebeeapps__CB_Site__c=:siteId];
	}

	Product2 prod=[select id,chargebeeapps__Recurring_charge_model__c,chargebeeapps__Addon_Type__c,chargebeeapps__Currency__c from Product2 where id=:product.Product2.Id];
	String model=prod.chargebeeapps__Recurring_charge_model__c;

	if(type=='addon') {
		model=prod.chargebeeapps__Addon_Type__c;
	}

	OpportunityLineItem obj=new OpportunityLineItem();
	if (Schema.sObjectType.OpportunityLineItem.fields.Quantity.isCreateable())
	{
		obj.Quantity=quantity;
	}
	if(model=='per_unit'||model=='quantity') {
		if (Schema.sObjectType.OpportunityLineItem.fields.UnitPrice.isCreateable())
		{
			obj.UnitPrice=totalPrice;
		}
		totalPrice*=quantity;
	}
	else{
		if (Schema.sObjectType.OpportunityLineItem.fields.UnitPrice.isCreateable())
		{
			obj.UnitPrice=totalPrice/quantity;
		}
	}

	if (Schema.sObjectType.OpportunityLineItem.fields.Product2Id.isCreateable())
	{
		obj.Product2Id=product.Product2.Id;
	}
	if (Schema.sObjectType.OpportunityLineItem.fields.Discount.isCreateable())
	{
		obj.Discount=CouponService.applyCoupon(couponObj,cbId,totalPrice,type,subscriptionValueInCents);
	}
	if (Schema.sObjectType.OpportunityLineItem.fields.OpportunityId.isCreateable())
	{
		obj.OpportunityId=oppId;
	}
	if (Schema.sObjectType.OpportunityLineItem.fields.PricebookEntryId.isCreateable())
	{
		obj.PricebookEntryId=product.Id;
	}

	insert obj;
	String cbOppProductCurrency=prod.chargebeeapps__Currency__c;
	if(isMultiCurrencyEnabled) {
		cbOppProductCurrency=(string)product.get('CurrencyIsoCode');
	}
	if(model=='flat_fee') {
		createCBOppProducts(null, null, obj.Id, 1, null, totalPrice,obj.Product2Id,cbOppProductCurrency);
	}
	else if(model=='per_unit'||model=='quantity') {
		createCBOppProducts(null, null, obj.Id, Quantity, obj.UnitPrice, totalPrice,obj.Product2Id,cbOppProductCurrency);
	}
	else{
		List<chargebeeapps__CB_Pricing_Tiers__c> pbEntries=ProductService.getPricingTiers(product.Id);

		if(model=='volume') {
			for(chargebeeapps__CB_Pricing_Tiers__c entry:pbEntries) {
				if(entry.chargebeeapps__Upper_Limit__c==null || entry.chargebeeapps__Upper_Limit__c>=quantity) {
					createCBOppProducts(entry.chargebeeapps__Lower_Limit__c, entry.chargebeeapps__Upper_Limit__c, obj.Id+'',
					                    quantity, entry.chargebeeapps__Price__c, totalPrice,obj.Product2Id,cbOppProductCurrency);
					break;
				}
			}
		}
		else if(model=='stairstep') {
			for(chargebeeapps__CB_Pricing_Tiers__c entry:pbEntries) {
				if(entry.chargebeeapps__Upper_Limit__c==null || entry.chargebeeapps__Upper_Limit__c>=quantity) {
					createCBOppProducts(entry.chargebeeapps__Lower_Limit__c, entry.chargebeeapps__Upper_Limit__c, obj.Id+'',
					                    quantity, null, totalPrice,obj.Product2Id,cbOppProductCurrency);
					break;
				}
			}
		}
		else if(model=='tiered') {
			Decimal units=quantity;
			for(chargebeeapps__CB_Pricing_Tiers__c entry:pbEntries) {

				if(entry.chargebeeapps__Upper_Limit__c==null || (entry.chargebeeapps__Upper_Limit__c-entry.chargebeeapps__Lower_Limit__c+1)>=units) {
					createCBOppProducts(entry.chargebeeapps__Lower_Limit__c, entry.chargebeeapps__Upper_Limit__c, obj.Id+'',
					                    units, entry.chargebeeapps__Price__c, units*entry.chargebeeapps__Price__c,obj.Product2Id,cbOppProductCurrency);
					break;
				}
				else{
					Decimal slot=entry.chargebeeapps__Upper_Limit__c-entry.chargebeeapps__Lower_Limit__c+1;
					units-=slot;
					createCBOppProducts(entry.chargebeeapps__Lower_Limit__c, entry.chargebeeapps__Upper_Limit__c, obj.Id+'',
					                    slot, entry.chargebeeapps__Price__c, slot*entry.chargebeeapps__Price__c,obj.Product2Id,cbOppProductCurrency);
				}
			}
		}
	}
}

private void createCBOppProducts(Decimal lo,Decimal up,String oppProId,Decimal quantity,Decimal unitPrice,
                                 Decimal subTotal,string sfId,string CurrencyIsoCode){
	chargebeeapps__CB_Opportunity_Product__c cbOppProduct=new chargebeeapps__CB_Opportunity_Product__c();
	if (Schema.sObjectType.chargebeeapps__CB_Opportunity_Product__c.fields.Lower_Limit__c.isCreateable())
	{
		cbOppProduct.Lower_Limit__c=lo;
	}
	if (Schema.sObjectType.chargebeeapps__CB_Opportunity_Product__c.fields.Upper_Limit__c.isCreateable())
	{
		cbOppProduct.Upper_Limit__c=up;
	}
	if (Schema.sObjectType.chargebeeapps__CB_Opportunity_Product__c.fields.Opportunity__c.isCreateable())
	{
		cbOppProduct.Opportunity__c=oppId;
	}
	if (Schema.sObjectType.chargebeeapps__CB_Opportunity_Product__c.fields.Opportunity_Product_Id__c.isCreateable())
	{
		cbOppProduct.Opportunity_Product_Id__c=oppProId;
	}
	if (Schema.sObjectType.chargebeeapps__CB_Opportunity_Product__c.fields.Quantity__c.isCreateable())
	{
		cbOppProduct.Quantity__c=quantity;
	}
	if (Schema.sObjectType.chargebeeapps__CB_Opportunity_Product__c.fields.Unit_Price__c.isCreateable())
	{
		cbOppProduct.Unit_Price__c=unitPrice;
	}
	if (Schema.sObjectType.chargebeeapps__CB_Opportunity_Product__c.fields.Subtotal__c.isCreateable())
	{
		cbOppProduct.Subtotal__c=subTotal;
	}
	if (Schema.sObjectType.chargebeeapps__CB_Opportunity_Product__c.fields.Product__c.isCreateable())
	{
		cbOppProduct.Product__c=sfId;
	}

	if(UIUtil.isMultiCurrencyEnabled()) {
		cbOppProduct.put('CurrencyIsoCode',CurrencyIsoCode);
	}
	insert cbOppProduct;
}

}
