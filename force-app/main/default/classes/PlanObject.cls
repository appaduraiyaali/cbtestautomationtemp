public class PlanObject {

public String cbId {get; set;}
public Integer qty  {get; set;}
public Decimal price {get; set;}
public String planCurrency {get; set;}
public Decimal setupFee {get; set;}

//other
public List<Map<String,Object> > tierdata {get; set;}
public string model {get; set;}
public Boolean hasSetupFee {get; set;}

public PlanObject(String cbId, Integer qty, Decimal price, String planCurrency, Decimal setupFee) {
    this.cbId = cbId;
    this.qty = qty;
    this.price = price;
    this.planCurrency = planCurrency;
    this.setupFee = setupFee;

    //defaults
    this.model='';
    this.hasSetupFee=false;
    this.tierdata=null;
}

public boolean canOverridePrice 
{
	get{
		if(model.equalsIgnoreCase('Tiered') || model.equalsIgnoreCase('StairStep')||model.equalsIgnoreCase('Volume'))
			return false;
		return true;
	}
	set;
}
public boolean displayQuantity 
{
	get
	{
    	if(model.equalsIgnoreCase('Flat_Fee'))
       		return false;
    
    	return true;
	}
	set;
}
public boolean displaytiericon
{
	get {
		System.debug('qty'+qty);
		System.debug('model'+model);
		if(qty == 0 ||qty == null)
			return false;

		if(model.equalsIgnoreCase('Tiered') || model.equalsIgnoreCase('StairStep'))
			return true;

		return false;
	}
	set;
}

public boolean showUnit 
{
	get{
		return model.equalsIgnoreCase('Tiered');
	} set;
}

}
