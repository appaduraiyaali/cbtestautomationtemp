public class UpdateSubUrlBuilder extends URLBuilder {

private static final String amp='&';

public UpdateSubUrlBuilder(){
	super();
}

public UpdateSubUrlBuilder(EndPoint ep){
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


public UpdateSubUrlBuilder planId(String s){
	addEncode('plan_id',s);
	return this;
}

public UpdateSubUrlBuilder planQuan(String s){
	add('plan_quantity',s);
	return this;
}

public UpdateSubUrlBuilder planUnitPrice(String s){
	add('plan_unit_price',s);
	return this;
}

public UpdateSubUrlBuilder planSetupFee(String s){
	add('subscription[setup_fee]',s);
	return this;
}

public UpdateSubUrlBuilder billingCycles(String s){
	add('billing_cycles',s);
	return this;
}

public UpdateSubUrlBuilder poNum(String s){
	add('po_number',s);
	return this;
}

public UpdateSubUrlBuilder couponId(String s){
	addEncode('coupon_ids[0]',s);
	return this;
}

public UpdateSubUrlBuilder prorate(String s){
	add('prorate',checkBoolean(s));
	return this;
}

public UpdateSubUrlBuilder endOfTerm(String s){
	add('end_of_term',checkBoolean(s));
	return this;
}

public UpdateSubUrlBuilder invoiceImmediately(String s){
	add('invoice_immediately',checkBoolean(s));
	return this;
}

private String checkBoolean(String s){
	if(s!=null) {
		List<String> boolVals=new List<String>();
		boolVals.add('true');
		boolVals.add('false');
		if(boolVals.contains(s.toLowerCase())) {
			return s.toLowerCase();
		}
		else
			return null;
	}
	return null;

}



}