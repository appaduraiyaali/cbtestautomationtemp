public with sharing class ListUnbilledChargesController{
    public String con_id{get;set;}
    public String err_msg{get;set;}
    public CBURLUtil urlUtil{get;set;}
    public ListUnbilledCharges luc{get;set;}
    public String sub{get;set;}
    public Boolean showPopup{get;set;}
    public Contact cont{get;set;}
    public InvoiceUnbilledEstimate unbilledEst{get;set;}
    public Boolean empty{get;set;}
    public Boolean iserr{get;set;}
    public String emsg{get;set;}
    public boolean isMultiSite{get;set;} 
    public String errMsg{get;set;}
    public String siteErr{get;set;}
    public Integer size{get;set;}
    public boolean disableSite{get;set;}
    public boolean isSiteConnected{get;set;} 
    public chargebeeapps__CB_Settings__c sites {get;set;}
    public List<chargebeeapps__Contact_Associate_Site__c> syncedSites{get;set;}
    public chargebeeapps__Contact_Associate_Site__c consite{get;set;}
    public List<chargebeeapps__Contact_Associate_Site__c> existingConSite{get;set;}  
    public String selectedSites{get;set;}
    
    public ListUnbilledChargesController(){
      iserr=false;
      con_id = ApexPages.currentPage().getParameters().get('con_id');
      con_id=String.escapeSingleQuotes(con_id);
        //String que = 'select Id,Email,chargebeeapps__External_Id__c from contact where Id=\''+con_id+'\'';
        String que = 'select Id,Email,chargebeeapps__External_Id__c from contact where Id=:con_id';
      cont=Database.query(que);
        //displayUnbilledCharge = true;
        isMultiSite=CBURLUtil.isMultiSite();
        if(isMultiSite)
        {           
            system.debug(isMultiSite);
             
        }
       syncedSites = [SELECT chargebeeapps__Contact__c ,chargebeeapps__External_Id__c ,chargebeeapps__CB_Site__c FROM chargebeeapps__Contact_Associate_Site__c WHERE chargebeeapps__Contact__c =: con_id AND chargebeeapps__External_Id__c != null];
        
         system.debug('Synced sites:'+syncedSites);
        if(syncedSites.size()==0)
        {
            disableSite = true;
            siteErr='This customer is not present in chargebee.';
        }
      
      
      
    }
    
    public List<selectOption> getSiteDetails()
    {
         
         List<selectOption> multiSites = new List<selectOption>();
         
         isSiteConnected = syncedSites.size()==1;
         for(chargebeeapps__Contact_Associate_Site__c siteList:syncedSites)
         {
              string sid = siteList.chargebeeapps__CB_Site__c;
             
             String domain = SiteUtil.getSiteName(sid);
             
             multiSites.add(new SelectOption(domain,domain));
             system.debug('SiteName:'+multiSites);
         }
         return multiSites;
        
     }  
    public PageReference selectedSiteName()
    {
        
        system.debug('Site:'+selectedSites);
        
        //system.debug(displayUnbilledCharge);
        urlUtil = new CBURLUtil(selectedSites);
        String sid = SiteUtil.getSiteID(selectedSites);
        existingConSite = [SELECT Id,chargebeeapps__Contact__c ,chargebeeapps__External_Id__c,chargebeeapps__CB_Site__c  FROM chargebeeapps__Contact_Associate_Site__c WHERE (chargebeeapps__Contact__c =: cont.Id AND chargebeeapps__CB_Site__c=:sid)];
        system.debug(existingConSite);
        size = existingConSite.size();
        if(existingConSite.size() != 0)
        {
            //displayUnbilledCharge = true;
            //system.debug(displayUnbilledCharge);
            String endpointURL = CBSubscriptionUtil.getListUnbilledChargesEndPoint(urlUtil,selectedSites);
            system.debug('Endpoint:'+endpointURL);
          String bodyData='';
          bodyData = CBURLUtil.buildURLString(bodyData,'customer_id[is]',existingConSite[0].chargebeeapps__External_Id__c);
            system.debug('Body:'+bodyData +'extid:'+ existingConSite[0].chargebeeapps__External_Id__c);
          endpointURL = endpointURL+'?'+bodyData;
          String response = CBURLUtil.sendRequest(endpointURL,null,urlUtil,true,'GET');
          System.debug('response-'+response);
          //System.debug('cont.External_Id__c---'+existingConSite[0].External_Id__c);
          luc = new ListUnbilledCharges(response);
          
          if(luc.jsonMap.get('list')!=null){
              empty=((List<Object>)luc.jsonMap.get('list')).isEmpty();
              system.debug('is Empty:'+empty);
              if(empty){
              err_msg='No unbilled charges found for this customer.';
              }
              else{
              if(luc.isAllVoided()){
                  err_msg='All unbilled charges are voided for this customer.';
                  empty=true;
              }
          }
          }
          if(luc.isErrorResponse){
              err_msg=response;
              empty=true;
          }
          
        }
        else{
            //displayUnbilledCharge = false;
            errMsg='This customer is not present in chargebee.';
            empty=true;
        }
        return null;
    } 
    public PageReference preview(){
        showPopup=true;
        populate(); 
        return null;
    }
    
    public void populate(){
        
          String endpointURL = CBSubscriptionUtil.getUnbilledChargesEstimateEndPoint(urlUtil,selectedSites);
          String bodyData='';
          bodyData = CBURLUtil.buildURLString(bodyData,'customer_id',existingConSite[0].chargebeeapps__External_Id__c);
          String response = CBURLUtil.sendRequest(endpointURL,bodyData,urlUtil,true,'POST');
          unbilledEst = (InvoiceUnbilledEstimate)EstimateFactory.constructResponseObject(response,'unbilled_estimate');
          
    }
    
    
    public PageReference Save(){
              String endpointURL = CBSubscriptionUtil.getInvoiceUnbilledChargesEndPoint(urlUtil);
              String bodyData='';
              bodyData = CBURLUtil.buildURLString(bodyData,'customer_id',existingConSite[0].chargebeeapps__External_Id__c);
              String response = CBURLUtil.sendRequest(endpointURL,bodyData,urlUtil,true,'POST');
              System.debug('response--'+response);
              Map<String,Object> jsonMap=(Map<String,Object>)JSON.deserializeUntyped(response);
              if(jsonMap.get('invoices')!=null){
                  return backToContact();
              }
              else{
                  iserr=true;
                  if(jsonMap.get('error_msg')!=null){
                      emsg=(String)jsonMap.get('error_msg');
                  }
                  else
                      emsg='CB Internal Error';
                  return null;
              }    
              
    }
    
    public PageReference backToContact(){
        return new PageReference('/'+con_id);
        
    }
    
    public PageReference Cancel(){
        PageReference pr = new PageReference('/apex/list_unbilled_charges');
        pr.getParameters().put('con_id',ApexPages.currentPage().getParameters().get('con_id'));
        pr.setRedirect(true);
        return pr;
    
    }
    
}