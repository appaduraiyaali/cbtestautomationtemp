public class AddonObject
{
public String addon {get; set;}
public Integer qty  {get; set;}
public Integer status  {get; set;}
public Integer id  {get; set;}
public decimal price {get; set;}
public String addonCurrency {get; set;}
public string model {get; set;}
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
public List<Map<String,Object> > tierdata {get; set;}
public boolean displaytier {get; set;}
public boolean showUnit 
{
	get{
		return model.equalsIgnoreCase('Tiered');
	} set;
}
public boolean removeAddon {get; set;}

public AddonObject(String addon,Integer qty,Integer id, Decimal price,boolean displayQuantity)
{
	this.displayQuantity = displayQuantity;
	this.addon = addon;
	this.qty = qty;
	this.id = id;
	this.price = price;
	this.model='Flat_Fee';
	this.removeAddon = true;
	system.debug('addon is '+addon);
}

public AddonObject(String addon,Integer qty,Integer id, Decimal price,boolean displayQuantity, Integer status)
{
	this.displayQuantity = displayQuantity;
	this.addon = addon;
	this.qty = qty;
	this.id = id;
	this.price = price;
	this.model='Flat_Fee';
	this.removeAddon = true;
	this.status = status;
}

//2=used?, 3=used?, 4=Deleted
public void setStatus(Integer status)
{
	this.status = status;
}

}

