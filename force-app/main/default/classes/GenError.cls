public class GenError
{
public String err {get; set;}
public String id {get; set;}
public String objNames{get;set;}

public GenError()
{
	err = ApexPages.currentPage().getParameters().get('err');
	if(err=='QUOTES_DISABLED') {
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Quotes is not enabled for your Chargebee site.');
	    ApexPages.addMessage(myMsg);
    } else if (err=='QUOTES_OPPORTUNITY') {
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'The quote is not connected to an Opportunity.');
	    ApexPages.addMessage(myMsg);
	}else if(err=='CANNOT_CONVERT'){
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'The quote cannot be converted as it is not OPEN or ACCEPTED state');
	    ApexPages.addMessage(myMsg);
	}else if(err=='NOT_APPROVED'){
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot send email as quote is not approved.');
	    ApexPages.addMessage(myMsg);
	}
	id = ApexPages.currentPage().getParameters().get('id');
	objNames = ApexPages.currentPage().getParameters().get('obj');
}

public Pagereference back() {
	PageReference pageRef = new PageReference('/'+id);
	pageRef.setRedirect(true);
	return pageRef;
}
}