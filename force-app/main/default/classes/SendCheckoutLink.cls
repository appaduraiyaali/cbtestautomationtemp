public with sharing class SendCheckoutLink
{

  public String subject{get;set;}
  
  public String email{get;set;}
  
  public String link{get;set;}
    
  public String pre_message{get;set;}
  
  public String post_message{get;set;}
  
  public  Account acct {get;set;}
  
  public Contact cont {get;set;}

  public String response{get;set;}  
  
  public String old_res {get;set;}
  
  public String mapmeta {get;set;}
  
  public string opp_id = null;
  
  public CBURLUtil urlUtil{get;set;}
  
  public List<chargebeeapps__Contact_Associate_Site__c> existingConSite{get;set;}
  
  
        
  public PageReference send()
  {
        response = null;
        String responseFromNet;
        System.debug('The other one is before the select statement');
        string endpointURL = urlUtil.getUrl()+'/adhoc_checkout_email/api/send';
        
        String mailContent = pre_message.replace('\n','<br>') + link +'<br>'+ post_message.replace('\n','<br>');
        if(email==null){
            response='Please make sure the email is present.';
            return null;
        }
        
        String bodyData = '';
        bodyData = CBURLUtil.buildURLString(bodyData, 'content', mailContent);
        bodyData = CBURLUtil.buildURLString(bodyData, 'subject', subject);
        bodyData = CBURLUtil.buildURLString(bodyData, 'to_address', email);
        bodyData = CBURLUtil.buildURLString(bodyData, 'api_key', urlUtil.getApiKey());
        try {
            responseFromNet = CBURLUtil.sendRequest(endpointURL, bodyData, urlUtil, true);
            System.debug('responseFromNet-----'+responseFromNet);
        }
        catch(Exception exp){
            System.debug('exception '+exp);
            //return null;
            responseFromNet = 'exception '+exp;
            response = 'error';
        } 

        
        if(opp_id !=null){
          String ext_id = ApexPages.currentPage().getParameters().get('link_id');
          if(ext_id != null && ext_id != '' )
            {  
                bodyData = '';
                bodyData = CBURLUtil.buildURLString(bodyData, 'entity_id',existingConSite[0].chargebeeapps__External_Id__c);
                bodyData = CBURLUtil.buildURLString(bodyData, 'entity_type', 'customer');
                bodyData = CBURLUtil.buildURLString(bodyData, 'third_party_entity_id', cont.id);
                bodyData = CBURLUtil.buildURLString(bodyData, 'integration_name', 'salesforce');
                bodyData = CBURLUtil.buildURLString(bodyData, 'status', 'SYNCED');
                
                //
                if(old_res !=null){
                    bodyData = CBURLUtil.buildURLString(bodyData, 'old_resource', old_res);
                }
                if(acct!=null){
                    bodyData = CBURLUtil.buildURLString(bodyData, 'mapping_meta', '{"account_id":"'+acct.id+'","checkout_vs_opp_id":{"'+ext_id+'":"'+opp_id+'"}}');
                }                
               
                String syncEndPoint = urlUtil.getUrl()+'/api/v2/third_party_entity_mappings/update_entity';
                try 
                {
                    responseFromNet = CBURLUtil.sendRequest(syncEndPoint, bodyData, urlUtil, true);        
                 }catch(Exception exp){
                        responseFromNet = 'exception '+exp;
                        response = responseFromNet+bodyData;
                 }
                 
            }
            ext_id = CBURLUtil.getValueFromResponse(responseFromNet, 'third_party_entity_mapping');
            if(ext_id ==null){
                response = responseFromNet;
            }                     
        }
        if(response==null){
            String cus_id = ApexPages.currentPage().getParameters().get('id');
            PageReference pageRef = new PageReference('/'+cus_id);
            //pageRef.getParameters.put('link_url', link);
            pageRef.setRedirect(true);
            return pageRef;
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
  public SendCheckoutLink()
  {
    String site = ApexPages.currentPage().getParameters().get('domain');
    String sid = SiteUtil.getSiteId(site);
    urlUtil = new CBURLUtil(site);
    
    String cus_id = ApexPages.currentPage().getParameters().get('id');
    
    cus_id = String.escapeSingleQuotes(cus_id);    
    String que = 'select Name,LastName, FirstName,Email, AccountId, MobilePhone, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, chargebeeapps__Auto_collection__c, chargebeeapps__External_Id__c from contact where id=\''+cus_id+'\'';
    cont = Database.query(que);
    existingConSite = [SELECT Id,chargebeeapps__Contact__c ,chargebeeapps__External_Id__c, chargebeeapps__CB_Site__c  FROM chargebeeapps__Contact_Associate_Site__c WHERE (chargebeeapps__Contact__c =: cont.Id AND chargebeeapps__CB_Site__c=:sid)];
    if(cont.AccountId != null){
         
        acct = [select Name from Account where id=:cont.AccountId];
    }
    
    subject = 'Complete your checkout';
    email = cont.email;
    pre_message = 'Dear '+cont.name+',\n\nYou\'re almost there! \n\nUse this secure link to confirm your personal details and enter your payment information:\n\n';
    post_message = '\n\nIf you have questions or the link doesn\'t seem to be working, don\'t hesitate to get in touch.\n\nThank you.';
    link = ApexPages.currentPage().getParameters().get('link_url');
    opp_id = ApexPages.currentPage().getParameters().get('opp_id');    
  }
  
  public  PageReference fetchCusMeta(){
        List<String> fields1 = new List<String> {'LastName', 'FirstName','Email', 'AccountId', 'Phone', 'MailingStreet', 'MailingCity', 'MailingState', 'MailingCountry', 'MailingPostalCode', 'chargebeeapps__Auto_collection__c', 'chargebeeapps__External_Id__c'};
        List<String> fields2 = new List<String> {'Name'};
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
        System.debug('fs-----'+fs);
        if(fs!=null)
        {
            return redirectToError(fs,String.join(objNames,','));
        }
        
            
    
        if(opp_id == null || opp_id == 'null' || opp_id == '')
        return null;
        
        response = null;
        String responseFromNet;
        System.debug('The other one is before the select statement');
        string endpointURL = urlUtil.getUrl()+'/api/v2/third_party_entity_mappings/retrieve';
        //reqData.setMethod('GET');
        
        String bodyData = '';
        bodyData = CBURLUtil.buildURLString(bodyData,'entity_id',existingConSite[0].chargebeeapps__External_Id__c);
        bodyData = CBURLUtil.buildURLString(bodyData,'entity_type','customer');
        bodyData = CBURLUtil.buildURLString(bodyData,'integration_name','salesforce');
        endpointURL = endpointURL+'?'+bodyData;

        try{
           responseFromNet = CBURLUtil.sendRequest(endpointURL, null, urlUtil, true, 'GET');
        }
        catch(Exception exp){
                    System.debug('exception '+exp);
                    responseFromNet = 'exception '+exp;
                    response = 'error';
        }
        mapmeta = null;
        old_res = null;
            
            if(responseFromNet != null)
            {
                Integer index = responseFromNet.indexOf('"old_resource":');
                if(index != -1)
                {
                    Integer last_index = responseFromNet.indexOf('"mapping_meta"');
                    if(last_index!=-1)
                    {
                        last_index = responseFromNet.lastIndexOf(',', last_index);
                        old_res = responseFromNet.subString(index+15,last_index);
                    }
                }
                else
                {
                    response = responseFromNet;
                }
            }        
    return null;
  }  
}