@IsTest public class CreateTestData {
    @TestSetup public static void insertTestData()
    {
        chargebeeapps__CB_Sites__c sites = TestdataUtility.getSites();
        
		Opportunity[] opt = TestdataUtility.insertOpportunity();
        
         Product2[] prod = TestdataUtility.insertProducts();
         system.debug('prod--'+prod);        
         List<string> extid = new List<string>();
         List<string> selectedIds = new List<string>();
         for(Product2 pr:prod)
         {
             string externalids = pr.ExternalId;
             extid.add(externalids);
             string plantype = pr.chargebeeapps__Recurring_charge_model__c;
             system.debug('plantype---'+plantype);
             if(pr.chargebeeapps__Addon_Type__c != null)
             {
                 string addonType = pr.chargebeeapps__Addon_Type__c;
                 if(( addonType.equalsIgnoreCase('Tiered') || addonType.equalsIgnoreCase('StairStep')||addonType.equalsIgnoreCase('Volume')))
                 {
                     string pid = pr.Id;
             		 selectedIds.add(pid);
                 }
             }
             if((plantype.equalsIgnoreCase('Tiered') || plantype.equalsIgnoreCase('StairStep')||plantype.equalsIgnoreCase('Volume')))

                {
					string pid = pr.Id;
             		selectedIds.add(pid);
                 
             	}
         }
                 
         List<string> pbIds = new List<string>();
         PricebookEntry[] pbentry = TestdataUtility.insertPBEntry(extid);
         
         PricebookEntry[] selctedprod = [select Id,product2Id from PricebookEntry where product2Id IN:selectedIds];
         
         for(PricebookEntry pb:selctedprod)
         {
             string pid = pb.Id;
             pbIds.add(pid);
              
         }
         
         OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = opt[1].Id,Quantity = 5,PricebookEntryId = pbentry[0].Id,TotalPrice = 5 * 100);
            
         insert oli1;
         system.debug('oli---'+oli1);
         TestdataUtility.insertCBTiers(pbIds);
    }
    
}