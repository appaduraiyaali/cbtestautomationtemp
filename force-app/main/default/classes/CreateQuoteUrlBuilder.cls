public class CreateQuoteUrlBuilder extends URLBuilder {

private static final String amp='&';

public CreateQuoteUrlBuilder(EndPoint ep){
	super(ep);
}

private void addEncode(String key, String value) {
	if(value!= null && !value.equals('')) {
		value=EncodingUtil.urlEncode(value,'UTF-8');
		if(ustring!='') {
			ustring+=amp;
		}
		ustring+=key+'='+value;
	}
}

private void add(String key, String value) {
	if(value!= null && !value.equals('')) {
		if(ustring!='') {
			ustring+=amp;
		}
		ustring+=key+'='+value;
	}
}

public CreateQuoteUrlBuilder planId(String s){
	addEncode('subscription[plan_id]',s);
	return this;
}

public CreateQuoteUrlBuilder planQuan(String s){
	add('subscription[plan_quantity]',s);
	return this;
}

public CreateQuoteUrlBuilder planUnitPrice(String s){
	add('subscription[plan_unit_price]',s);
	return this;
}

public CreateQuoteUrlBuilder planSetupFee(String s){
	add('subscription[setup_fee]',s);
	return this;
}

public CreateQuoteUrlBuilder billingCycles(String s){
	add('billing_cycles',s);
	return this;
}

public CreateQuoteUrlBuilder couponId(String s){
	addEncode('coupon_ids[0]',s);
	return this;
}

}