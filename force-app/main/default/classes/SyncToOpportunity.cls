public with sharing class SyncToOpportunity {

public String quoteId {get; set;}

public SyncToOpportunity(){
    quoteId = ApexPages.currentPage().getParameters().get('quote_id');
	quoteId = String.escapeSingleQuotes(quoteId);

    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'The Opportunity products and Pricebook will ' +
        'be replaced with the Quotes Products and Pricebook'));
 
}

public Pagereference checkPermissions() {

	chargebeeapps__CB_Quote__c quote = QuoteService.getQuote(quoteId);

	String domain = SiteUtil.getSiteName(quote.chargebeeapps__CB_Site__c);

	if(domain!=null) {
		CBUrlUtil urlUtil = new CBURLUtil(domain);
		if(!urlUtil.isQuotesEnabled()) {
			return redirectToGeneralErrorPage('QUOTES_DISABLED',quoteId);
		}
	}

	if(quote.chargebeeapps__Opportunity__c == null) {
		return redirectToGeneralErrorPage('QUOTES_OPPORTUNITY',quoteId);
	}
	return null;
}

private Pagereference redirectToGeneralErrorPage(String msg,String id) {
	PageReference pageRef = new PageReference('/apex/General_err');
	pageRef.getParameters().put('err',msg);
    pageRef.getParameters().put('id',id);
	pageRef.setRedirect(true);
	return pageRef;
}

public PageReference syncQuote() {
    QuoteService.syncToOpportunity(quoteId);
	return backToQuote();
}

public PageReference backToQuote(){
	String url = '';
	if(quoteId !=null && quoteId != '-1') {url=quoteId;}
	PageReference pageRef = new PageReference('/'+url);
	pageRef.setRedirect(true);
	return pageRef;
}


}