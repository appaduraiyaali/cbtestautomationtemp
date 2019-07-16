public with sharing class CouponService {
public CouponService() {

}

public static Map<String, Object> getCouponDetails(string couponId, String domain)
{
	if(couponId=='-1') {
		return null;
	}

	EndPoint ep = EndPointsIndex.get_coupon_details;
	if(domain!=null) {
		ep.domainName(domain);
	}
	List<String> liststr = new List<String>();
	liststr.add(EncodingUtil.urlEncode(couponId,'UTF-8'));
	ep.replace(liststr);
	GenericURLBuilder br = new GenericURLBuilder(ep);
	GenericController ctr = new GenericController(br);
	Map<String, Object> responseMap = ctr.makeRequest();
	Map<String, Object> resp = (Map<String, Object>)responseMap.get('coupon');

	return resp;
}

public static Integer calculateSubscriptionAmount(chargebeeapps.PlanObject plan, List<chargebeeapps.AddonObject> addons, String siteId){
	Integer subPriceInCents=0;
	subPriceInCents+=getTotalAmount(plan.qty,plan.price,plan.cbId,'plan', siteId);
	for(AddonObject addon:addons) {
		subPriceInCents+=getTotalAmount(addon.qty,addon.price,addon.addon,'addon', siteId);
	}
	return subPriceInCents;
}

public static Integer getTotalAmount(Integer quantity,Decimal totalPrice,string cbId,string type, String siteId){
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

public static boolean validateCoupon(String coupon, String plan, List<AddonObject> addons, Map<String, Object>  couponObj){
	if(coupon!='-1') {
		try{
			system.debug('coupon'+couponObj);
			if((String)couponObj.get('plan_constraint')=='all'
			   || ((String)couponObj.get('addon_constraint')=='all'
			       && (!addons.isEmpty()))) {
				return true;
			}
			else if((String)couponObj.get('plan_constraint')=='not_applicable'
			        && (String)couponObj.get('addon_constraint')=='not_applicable') {//apply on invoice amount
				return true;
			}
			else if((String)couponObj.get('plan_constraint')=='specific'
			        && ((List<String>)couponObj.get('plan_ids')).contains(plan)) {
				return true;//can be applied on plan
			}
			else if((String)couponObj.get('addon_constraint')=='specific') {
				for(AddonObject addon:addons) {
					if(((List<object>)couponObj.get('addon_ids')).contains(addon.addon)) {
						return true;//applicable on addon
					}
				}
			}
		}
		catch(Exception e) {

		}
		return false;
	}
	return true;
}

public static Decimal applyCoupon(Map<String,Object> coupon, String cbId,Decimal price,String type, Integer subscriptionValueCents){
	String constraint='plan_constraint';
	String list_name='plan_ids';
	if(type=='addon') {
		constraint='addon_constraint';
		list_name='addon_ids';
	}
	if(coupon!=null && (String)coupon.get(constraint)!='none') {
		Integer priceInCents=Integer.valueOf(price*100);
		if((String)coupon.get(constraint)=='all') {
			return calculateDiscountInPercent(coupon,priceInCents);
		}
		else if((String)coupon.get(constraint)=='specific') {
			List<object> ids=(List<object>)coupon.get(list_name);
			if(ids.contains(cbId)) {
				return calculateDiscountInPercent(coupon,priceInCents);
			}
		}
		else if((String)coupon.get(constraint)=='not_applicable') {
			return calculateDiscountInPercent(coupon,subscriptionValueCents);
		}
	}
	return 0.0;
}

public static Decimal calculateDiscountInPercent(Map<String,Object> coupon,Integer priceInCents){
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

public static chargebeeapps__Coupon__c getCoupon(String cbId, String siteId) {
    chargebeeapps__Coupon__c coupon = [Select Id,Name from chargebeeapps__Coupon__c where chargebeeapps__CB_Site__c=:siteId and chargebeeapps__CB_Coupon_Id__c=:cbId];
    return coupon;
}

}
