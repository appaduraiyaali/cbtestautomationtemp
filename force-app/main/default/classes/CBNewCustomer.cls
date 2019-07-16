public with sharing class CBNewCustomer
{
    public  Contact  cont {get;set;}
    public  Account acct {get;set;}
    public CBNewCustomerUtil utilObj{get;set;}
    public String response{get;set;}    
    public String action{get;set;}
    public String errorMessage{get;set;} 
    
    boolean site ;
    public String domain{get;set;}
    public boolean isMultiSite{get;set;} 
    
    public boolean disableCreate{get;set;}
    public boolean disableUpdate{get;set;}
    public boolean disableMessage{get;set;}
    
    public List<chargebeeapps__Contact_Associate_Site__c> existingConSite{get;set;}  
    public String selectedSites{get;set;}
    public Map<String, Object> sf_to_cb_values{get;set;}
    public PageReference checkPermissions(){
        List<String> fields1 = new List<String> {'LastName', 'FirstName','Email', 'AccountId', 'Phone', 'MailingStreet', 'MailingCity', 'MailingState', 'MailingCountry', 'MailingPostalCode', 'chargebeeapps__Auto_collection__c', 'chargebeeapps__External_Id__c'};
        List<String> fields2 = new List<String> {'Name'};
        List<String> fields3 = new List<String> {'chargebeeapps__Contact__c','chargebeeapps__External_Id__c','chargebeeapps__CB_Site__c'}; 
        List<String> objNames = new List<String>();
                          
        String fs;
        if(!FlsUtil.isPermitable(fields1,'contact')){
            fs = FlsUtil.getNotAccessibleFields(fields1,'contact','access');
            objNames.add('contact');   
        }
        if(!FlsUtil.isPermitable(fields2,'account')){
            fs += FlsUtil.getNotAccessibleFields(fields2,'account','access');
            objNames.add('account');   
        }
         if(!FlsUtil.isPermitable(fields3,'chargebeeapps__Contact_Associate_Site__c'))
         {
             fs = FlsUtil.getNotAccessibleFields(fields3,'chargebeeapps__Contact_Associate_Site__c','access');
             objNames.add('chargebeeapps__Contact_Associate_Site__ce'); 
         }
        System.debug('fs-----'+fs);
        if(fs==null)
        {
            return null;
        }
        else
            return redirectToError(fs,String.join(objNames,','));
    }
    
    public PageReference ToError()
    {
           PageReference pageRef = new PageReference('/apex/error');
           pageRef.setRedirect(true);
           return pageRef; 
    }
    public CBNewCustomer(){
        
        action = ApexPages.currentPage().getParameters().get('action');
        String cus_id = ApexPages.currentPage().getParameters().get('id');
        cus_id = String.escapeSingleQuotes(cus_id);
        //config = [select Customer_custom_map__c from custom_field_config__c];
        String que = 'select Id, LastName, FirstName,Email, AccountId, Phone, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, chargebeeapps__Auto_collection__c, chargebeeapps__External_Id__c from contact where id=:cus_id';
        cont = Database.query(que);
        if(cont.AccountId != null){
            
            acct = [select Name from Account where id=:cont.AccountId];
        } 
        
        isMultiSite=CBURLUtil.isMultiSite();
        selectedSites = System.currentPageReference().getParameters().get('domain');
        
        //custom field changes
        Map<String, Object> sf_to_cb_mapping=CBCustomFieldMappingUtil.getFieldMapping(selectedSites);
        sf_to_cb_values=CBCustomFieldMappingUtil.getCustomFieldDataForCustomer(cont.Id,sf_to_cb_mapping);
    }
    public void reloadCustomFieldMapping(){
        Map<String, Object> sf_to_cb_mapping=CBCustomFieldMappingUtil.getFieldMapping(selectedSites);
        sf_to_cb_values=CBCustomFieldMappingUtil.getCustomFieldDataForCustomer(cont.Id,sf_to_cb_mapping);
    }
    public List<selectOption> getSiteDetails()
    {
         
         List<selectOption> multiSites = new List<selectOption>();
         Map<String,chargebeeapps__CB_Settings__c> sitedetails=CBURLUtil.getAllSiteDetails();
         if(isMultiSite){
             
             multiSites.add(new SelectOption('-1','Select'));
         }
         
         for(chargebeeapps__CB_Settings__c siteName:sitedetails.values())
         {
             string domain = siteName.Name;
             multiSites.add(new SelectOption(domain,domain));
             system.debug('SiteName:'+multiSites);
         }
         return multiSites;
     } 
    public PageReference displayEnabledMessage()
    {   
        System.debug('selectedSites'+selectedSites);
        String sid = SiteUtil.getSiteId(selectedSites);   
        existingConSite = [SELECT Id,chargebeeapps__Contact__c ,chargebeeapps__External_Id__c,chargebeeapps__CB_Site__c  FROM chargebeeapps__Contact_Associate_Site__c WHERE (chargebeeapps__Contact__c =: cont.Id AND chargebeeapps__CB_Site__c =:sid AND chargebeeapps__External_Id__c!=null)];
        
        errorMessage='';
        if(existingConSite.size() == 0)
        {
            system.debug('True');
            //disableMessage = true;
            disableCreate = True;
            disableUpdate = false;
        }else{
            system.debug('False');
            disableCreate = false;
            disableUpdate = true;
        }
        
        return null;
        
    } 
 
    public PageReference redirectToError(String err,String obj){
       PageReference pageRef = new PageReference('/apex/error');
       pageRef.getParameters().put('err',err);
       pageRef.getParameters().put('obj',obj);
       pageRef.setRedirect(true);
       return pageRef; 
    }
    
    public PageReference createCustomer(){
      
        String ext_id = null;
        if(selectedSites!='-1'){
           
            utilObj = new CBNewCustomerUtil(selectedSites);
            
            system.debug('selectedSites'+selectedSites);
            StatusClass.Status pr=utilObj.createCustomer(ApexPages.currentPage().getParameters().get('id'));
            
            
            System.debug('action---------'+action);
            System.debug('utilObj.response---'+utilObj.response);
            if(pr==StatusClass.Status.API_ERROR)
            {
               errorMessage=utilObj.response;
               return null;
            }        
            else if(pr==StatusClass.Status.ACCESSIBILITY_ERROR)
            {
                return ToError();
            }
            else
            {
            
                if(action=='sync')
                {
                //url = FlsUtil.safeUrl(url);        
                PageReference pageRef = new PageReference('/'+cont.id);
                pageRef.setRedirect(true);
                return pageRef;
                }
                else if(action=='update_payment_method')
                {
                 PageReference pageRef = new PageReference('/apex/UpdatePaymentMethod');
                 pageRef.getParameters().put('id',ApexPages.currentPage().getParameters().get('id'));
                pageRef.setRedirect(true);
                return pageRef;   
                }
                else if(action=='create_sub')
                {
                    PageReference pageRef = new PageReference('/apex/Create_Subscription');
                    pageRef.getParameters().put('con_id',ApexPages.currentPage().getParameters().get('id'));
                    pageRef.getParameters().put('domain',selectedSites);
                    String opp_id = ApexPages.currentPage().getParameters().get('opp_id'); 
                    if(opp_id != null && opp_id!='' && opp_id != 'null')
                    {
                        pageRef.getParameters().put('opp_id',opp_id);
                    }
                    String id = ApexPages.currentPage().getParameters().get('id'); 
                    if(id != null && id!='' && id != 'null')
                    {
                        pageRef.getParameters().put('id',id);
                    }
                    pageRef.setRedirect(true);
                    return pageRef;
                }
                else if(action=='create_quote')
                {
                    PageReference pageRef = new PageReference('/apex/Create_Quote');
                    pageRef.getParameters().put('con_id',ApexPages.currentPage().getParameters().get('id'));
                    pageRef.getParameters().put('domain',selectedSites);
                    String opp_id = ApexPages.currentPage().getParameters().get('opp_id'); 
                    if(opp_id != null && opp_id!='' && opp_id != 'null')
                    {
                        pageRef.getParameters().put('opp_id',opp_id);
                    }
                    pageRef.setRedirect(true);
                    return pageRef;
                }
                return null;
                
            }
        
        }
        errorMessage='Please select a site.';
        return null;                        
     }
     
    public PageReference back(){        
            PageReference pageRef = new PageReference('/'+cont.id);
            pageRef.setRedirect(true);
            return pageRef;               
    } 
}