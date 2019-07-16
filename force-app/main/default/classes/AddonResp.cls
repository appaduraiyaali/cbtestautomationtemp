public class AddonResp {
public String Id {get; set;}
public Integer quan {get; set;}
public Double uPrice {get; set;}
public Boolean exist {get; set;}
public Integer status {get; set;}
public Integer sN {get; set;}
public String addonCurrency {get; set;}
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
		if(quan == 0 ||quan == null)
			return false;

		if(model.equalsIgnoreCase('Tiered') || model.equalsIgnoreCase('StairStep'))
			return true;

		return false;
	}
	set;
}
public string model {get; set;}
public boolean canOverridePrice
{
	get {
		if(model.equalsIgnoreCase('Tiered') || model.equalsIgnoreCase('StairStep')||model.equalsIgnoreCase('Volume'))
			return false;
		return true;
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
public AddonResp(boolean displayQuantity)
{
	this.displayQuantity = displayQuantity;
	showUnit=false;
	displaytier = false;
	this.model='Flat_Fee';
}
public AddonResp(String i,Integer q,Long up,Boolean e,Integer s,Integer sno){
        this(i,q,up,e,s,sno,'USD');
    }
    
    public AddonResp(String i,Integer q,Long up,Boolean e,Integer s,Integer sno,String curCode){
        Id=i;
        quan=q;
        uPrice=ChargebeeUtil.convertToHigherOrderCurrency(curCode,up);
        exist=e;
        status=s;
        sN=sno;
        this.model='Flat_Fee';
        this.canOverridePrice=true;
        displaytiericon = false;
        displaytier = false;
        system.debug('addon '+Id);
    }


    public void setStatus(Integer i){
        status=i;
    }

}