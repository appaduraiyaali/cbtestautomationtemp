public with sharing class ChooseSite{

    public List<selectOption> getSiteDetails()
    {
         
         List<selectOption> multiSites = new List<selectOption>();
         Map<String,chargebeeapps__CB_Settings__c > sitedetails=CBURLUtil.getAllSiteDetails();
         for(chargebeeapps__CB_Settings__c  siteName:sitedetails.values())
         {
             string domain = siteName.Name;
             multiSites.add(new SelectOption(domain,domain));
             system.debug('SiteName:'+multiSites);
         }
         return multiSites;
     }
     public boolean isMultiSite{get{
         return CBURLUtil.isMultiSite();
     }set;}
     public String selectedSite{get;set;}
     public String oppId{get;set;}
     public String pbId{get;set;}
     public String pbName{get;set;}
     public String siteId{get;set;}
     public BaseError disclaimerMsg{get;set;}
     public Opportunity opp{get;set;}
     
     public ChooseSite(){
        oppId = ApexPages.currentPage().getParameters().get('id');
        opp = [select Id,Pricebook2Id,Pricebook2.chargebeeapps__CB_Site__c,Pricebook2.Name from Opportunity where Id=:oppId];
        
        pbId= opp.Pricebook2Id;
        pbName = opp.Pricebook2.Name;
        siteId = opp.Pricebook2.chargebeeapps__CB_Site__c;
        System.debug('pbName--'+pbName);
        oppId = opp.Id;
        if(pbName!=null){
            if(siteId!=null){
                selectedSite=SiteUtil.getSiteName(siteId);
            }else{
                disclaimerMsg = new BaseError('A custom pricebook - '+pbName+' is present.Selecting a site would change pricebook and remove products');
            }
            
        }else{
            disclaimerMsg = new BaseError('No pricebook is present');
        }
        
    
     }
     
     public PageReference next(){
         System.debug('selectedSite---'+selectedSite);
         if(selectedSite!=null){
             String sid = SiteUtil.getSiteId(selectedSite);
             Pricebook2 p = [select Id,chargebeeapps__CB_Site__c from Pricebook2 where chargebeeapps__CB_Site__c=:sid];
             if(pbId==null){
             //Proceed without deleting
                 setPricebookOnOpp(p.Id);
             }else if(p.Id.equals(pbId)){
             //Proceed without deleting
             }else{
                 deleteOppProducts();
                 setPricebookOnOpp(p.Id);
             }
             PageReference pageRef = new PageReference('/apex/chargebeeapps__CBManageProduct');
             pageRef.getParameters().put('id',ApexPages.currentPage().getParameters().get('id'));
             pageRef.getParameters().put('domain',selectedSite);
             pageRef.setRedirect(true);
             return pageRef;
         }
         
         return null;
     }
     
     public void deleteOppProducts(){  
        OpportunityLineItem[] objects=[select Id,Name From OpportunityLineItem where OpportunityId=:oppId];
        if(objects!=null && objects.size()>0){
            if (OpportunityLineItem.sObjectType.getDescribe().isDeletable()){
            	delete objects;
            }
        }
        chargebeeapps__CB_Opportunity_Product__c[] objs=[select Id,Name From chargebeeapps__CB_Opportunity_Product__c where chargebeeapps__Opportunity__c=:oppId];
        if(objs!=null && objs.size()>0){
            if (chargebeeapps__CB_Opportunity_Product__c.sObjectType.getDescribe().isDeletable()){
            	delete objs;
            }
        }    
     }
     
     public void setPricebookOnOpp(String pid){
         if (Schema.sObjectType.Opportunity.fields.Pricebook2Id.IsUpdateable())
         {
             opp.Pricebook2Id=pid;
         }
         update opp;
         
     }
     
     public PageReference back(){
         PageReference pageRef = new PageReference('/'+oppId);
         pageRef.setRedirect(true);
         return pageRef;
     }
     

}