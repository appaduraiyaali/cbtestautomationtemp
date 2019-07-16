trigger QuoteTrigger on chargebeeapps__CB_Quote__c (before update) {
	for( Id quoteId : Trigger.newMap.keySet() )
	{
        chargebeeapps__CB_Quote__c oldObj = Trigger.oldMap.get(quoteId);
        chargebeeapps__CB_Quote__c newObj = Trigger.newMap.get(quoteId);

		String path = System.URL.getCurrentRequestUrl().getPath();

		//if trigger not hit because of integration service making bulkapi calls
		if(!path.contains('bulkapi')) {
			if(oldObj.chargebeeapps__Status__c != newObj.chargebeeapps__Status__c) {
				if(oldObj.chargebeeapps__Status__c == 'INVOICED')
				{
					newObj.addError('INVOICED is an end state and cannot be changed.');
					continue;
				}
				if(newObj.chargebeeapps__Status__c == 'CLOSED'||
					newObj.chargebeeapps__Status__c == 'ACCEPTED' ||
					newObj.chargebeeapps__Status__c == 'DECLINED')
				{
					QuoteService.updateChargebeeQuoteStatus(newObj.chargebeeapps__CB_Quote_Id__c, newObj.chargebeeapps__CB_Site__r.Name, 
						newObj.chargebeeapps__Status__c);
				} else {
					newObj.addError(newObj.chargebeeapps__Status__c + ' status is invalid for a quote update.');
				}
			}
		}
	}
}