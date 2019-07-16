public with sharing class CBNewCustomerUtil
{
    public  Contact  cont {get;set;}
    
    public  Account acct {get;set;}
    
    public String response{get;set;}
    
    public CBURLUtil urlUtil{get;set;}
    
    public string siteName;
    
    public boolean isMultiSite{get;set;}
    chargebeeapps__Contact_Associate_Site__c conSite; 
    List<chargebeeapps__Contact_Associate_Site__c> existingConSite{get;set;}

    public CBNewCustomerUtil()
    {
      urlUtil = new CBURLUtil();
        conSite = new chargebeeapps__Contact_Associate_Site__c();
      existingConSite = new List<chargebeeapps__Contact_Associate_Site__c>();
      
    }

    
    public CBNewCustomerUtil(string selectedSites)
    {
      siteName = selectedSites;
      urlUtil = new CBURLUtil(selectedSites);
      isMultiSite=CBURLUtil.isMultiSite();
      conSite = new chargebeeapps__Contact_Associate_Site__c();
      existingConSite = new List<chargebeeapps__Contact_Associate_Site__c>();
      
      
    }
    
    public PageReference redirectToError()
    {
           PageReference pageRef = new PageReference('/apex/error');
           pageRef.setRedirect(true);
           return pageRef; 
    }
    
    public PageReference back()
    {
            PageReference pageRef = new PageReference('/'+cont.id);
            //pageRef.getParameters.put('link_url', link);
            pageRef.setRedirect(true);
            return pageRef;    
        
    }
    
    public StatusClass.Status createCustomer(String cus_id)
    {
        system.debug('contact Id:'+cus_id);
        
        List<String> fields = new List<String> {'LastName', 'FirstName','Email', 'AccountId', 'Phone', 'MobilePhone', 'MailingStreet', 'MailingCity', 'MailingState', 'MailingCountry', 'MailingPostalCode', 'chargebeeapps__Auto_collection__c', 'chargebeeapps__External_Id__c', 'chargebeeapps__Net_Term_Days__c'};
        if(!FlsUtil.isPermitable(fields,'contact'))
        {
            return StatusClass.Status.ACCESSIBILITY_ERROR;
        }
        List<String> fields2 = new List<String> {'chargebeeapps__Contact__c','chargebeeapps__External_Id__c','chargebeeapps__CB_Site__c'};
        if(!FlsUtil.isPermitable(fields2,'chargebeeapps__Contact_Associate_Site__c'))
        {
            return StatusClass.Status.ACCESSIBILITY_ERROR;
        }
        cus_id = String.escapeSingleQuotes(cus_id);
        system.debug('Copy contact Id:'+cus_id);
        String que = 'select Id, LastName, FirstName,Email, AccountId, Phone, MobilePhone, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, chargebeeapps__Auto_collection__c, chargebeeapps__External_Id__c, chargebeeapps__Net_Term_Days__c from contact where id=:cus_id';
        cont = Database.query(que);
        
        if(cont.Email == null || cont.Email=='')
        {
            response = 'Email ID not available for the Contact. Unable to proceed further. Please update the contact and try again.';
            System.debug(response);
            return StatusClass.Status.API_ERROR; 
        }
        if(cont.AccountId != null)
        {
            fields = new List<String> {'Name'};
            if(!FlsUtil.isPermitable(fields,'account'))
            {
                return StatusClass.Status.ACCESSIBILITY_ERROR;
            }
            acct = [select Name from Account where id=:cont.AccountId];
        }
            
        String ext_id = null;
        //associatedSite = [SELECT Id,Contact__c ,External_Id__c FROM Contact_Associate_Site__c];
        String sid = SiteUtil.getSiteId(siteName);
        System.debug('sid--'+sid);
        System.debug('siteName---'+siteName);
        existingConSite = [SELECT Id,chargebeeapps__Contact__c ,chargebeeapps__External_Id__c,chargebeeapps__CB_Site__c  FROM chargebeeapps__Contact_Associate_Site__c WHERE (chargebeeapps__Contact__c =: cont.Id AND chargebeeapps__CB_Site__c=:sid)];
        
        //Making api call to create customer in chargebee!
        if(existingConSite.size() == 0)
        {
            
            String responseFromNet;
            System.debug('The other one is before the select statement');
            string endpointURL = urlUtil.getUrl()+'/api/v2/customers';
            system.debug('URL:'+endpointURL);
            String bodyData = '';
            bodyData = CBURLUtil.buildURLString(bodyData, 'email', cont.Email);
            if(acct!=null){
                bodyData = CBURLUtil.buildURLString(bodyData, 'company', acct.Name);
            }
            bodyData = CBURLUtil.buildURLString(bodyData, 'billing_address[email]', cont.Email);
            bodyData = CBURLUtil.buildURLString(bodyData, 'first_name', cont.FirstName);
            bodyData = CBURLUtil.buildURLString(bodyData, 'billing_address[first_name]', cont.FirstName);
            bodyData = CBURLUtil.buildURLString(bodyData, 'last_name', cont.LastName);
            bodyData = CBURLUtil.buildURLString(bodyData, 'billing_address[last_name]', cont.LastName);
            bodyData = CBURLUtil.buildURLString(bodyData, 'billing_address[line1]', cont.MailingStreet);
            bodyData = CBURLUtil.buildURLString(bodyData, 'phone', cont.Phone);
            bodyData = CBURLUtil.buildURLString(bodyData, 'net_term_days', getNetTerm(cont.Net_Term_Days__c));
            bodyData = CBURLUtil.buildURLString(bodyData, 'billing_address[city]', cont.MailingCity);
            bodyData = CBURLUtil.buildURLString(bodyData, 'billing_address[state]', cont.MailingState);
            bodyData = CBURLUtil.buildURLString(bodyData, 'billing_address[zip]', cont.MailingPostalCode);
            bodyData = CBURLUtil.buildURLString(bodyData, 'billing_address[country]', ChargebeeUtil.getCountryCode(cont.MailingCountry));
            Object isPaymentNetTermEnabled = urlUtil.getSiteConf('payment_term');
            Object defaultAutoCollectionFlag = urlUtil.getSiteConf('auto_collection');
            if(isPaymentNetTermEnabled != null && Boolean.valueOf(isPaymentNetTermEnabled) ){
                bodyData = CBURLUtil.buildURLString(bodyData, 'auto_collection', 'off');
            }else if(defaultAutoCollectionFlag != null){
                bodyData = CBURLUtil.buildURLString(bodyData, 'auto_collection', String.valueOf(defaultAutoCollectionFlag));
            }else{
                bodyData = CBURLUtil.buildURLString(bodyData, 'auto_collection', 'on');
            }
            //custom field mapping handling start
            Map<String, Object> sf_to_cb_mapping=CBCustomFieldMappingUtil.getFieldMapping(siteName);
        	Map<String,Object> sf_to_cb_values=CBCustomFieldMappingUtil.getCustomFieldDataForCustomer(cont.Id,sf_to_cb_mapping);
            if(sf_to_cb_values!=null){
                for(String fieldName:sf_to_cb_values.keySet()){
                    if(sf_to_cb_values.get(fieldName)+''!=CBCustomFieldMappingUtil.NO_VALUE_SET)
                    bodyData = CBURLUtil.buildURLString(bodyData, fieldName, sf_to_cb_values.get(fieldName)+'');
                }
            }
            //custom field mapping handling ends
            try 
            {
                responseFromNet = CBURLUtil.sendRequest(endpointURL, bodyData, urlUtil, true);
                System.debug('responseFromNet-->>'+responseFromNet);
            }
            catch(Exception exp)
            {
                        System.debug('exception '+exp);
                        //return null;
                        responseFromNet = 'exception '+exp;
            }
            response = null;
            ext_id = CBURLUtil.getIdFromResponse(responseFromNet);
            system.debug('External Id:'+ext_id);
            
            
            bodyData = '';
            bodyData = CBURLUtil.buildURLString(bodyData, 'entity_id', ext_id);
            bodyData = CBURLUtil.buildURLString(bodyData, 'entity_type', 'customer');
            bodyData = CBURLUtil.buildURLString(bodyData, 'third_party_entity_id', cont.id);
            bodyData = CBURLUtil.buildURLString(bodyData, 'integration_name', 'salesforce');
            bodyData = CBURLUtil.buildURLString(bodyData, 'status', 'SYNCED');
            bodyData = CBURLUtil.buildURLString(bodyData, 'old_resource', responseFromNet);
            
            System.debug('response : '+responseFromNet+ 'reqbody : '+bodyData);
            if(ext_id == null || ext_id == ''){
                try{
                    Map<String,Object> error=(Map<String,Object>)JSON.deserializeUntyped(responseFromNet);
                    if(error.containsKey('message')){
                        response = 'Unable to create Customer in Chargebee. '+ (String)error.get('message');
                    }
                }
                catch(Exception e){
                	response = 'Unable to create Customer in Chargebee. '+ responseFromNet ;
                }
                
                System.debug(response);
                return StatusClass.Status.API_ERROR;
            }
            else
            {  
                //Making api call to create a record in third_party_entity_mappings table in chargebee for this customer!
                if(acct!=null){
                    bodyData = CBURLUtil.buildURLString(bodyData, 'mapping_meta', '{"account_id":"'+acct.id+'"}');    
                }
                
                endpointURL = urlUtil.getUrl()+'/api/v2/third_party_entity_mappings/update_entity';  
                try{
                   responseFromNet = CBURLUtil.sendRequest(endpointURL, bodyData, urlUtil, true);
                }catch(Exception exp){
                System.debug('exception '+exp);
                responseFromNet = 'exception '+exp;
              }
              //response= responseFromNet;  
            }
             try
             {
                
                List<String> fields1 = new List<String> {'chargebeeapps__External_Id__c'};
                 if(!FlsUtil.isUpdate(fields1,'chargebeeapps__Contact_Associate_Site__c'))
                 {
                     return StatusClass.Status.ACCESSIBILITY_ERROR;
                 }
                //DML statement has to be made only after callout!
                UpdateSFContact(ext_id);
              }
              
            catch(Exception e)
            {
              response = e.getMessage();
            }            
              
        }
        else
        {
            //existingConSite = [SELECT Id,Contact__c ,External_Id__c FROM Contact_Associate_Site__c WHERE Contact__c =: cont.Id];
            
            if(existingConSite[0].chargebeeapps__External_Id__c != null && existingConSite[0].chargebeeapps__External_Id__c != '')
            {
                System.debug('update check');
                
                String extId = updateCustomer();
                if(extId == null){
                  System.debug(response);
                  return StatusClass.Status.API_ERROR;
                }else{
                  //triggerSync(extId);
              }
            }
            
        }
        
          return StatusClass.Status.SUCCESS;  
        }
        
        
        public String updateCustomer(){
            string endpointURL = urlUtil.getUrl()+'/api/v2/customers/' + existingConSite[0].chargebeeapps__External_Id__c;
            system.debug('URL:'+endpointURL);
            String url = '';
            url = CBURLUtil.buildURLString(url, 'email', cont.Email);
            url = CBURLUtil.buildURLString(url, 'first_name', cont.FirstName);
            url = CBURLUtil.buildURLString(url, 'last_name', cont.LastName);
            url = CBURLUtil.buildURLString(url, 'phone', cont.Phone);
            
            if(acct!=null){
                url = CBURLUtil.buildURLString(url, 'company', acct.Name);
            }
            
            //custom field mapping handling start
            Map<String, Object> sf_to_cb_mapping=CBCustomFieldMappingUtil.getFieldMapping(siteName);
        	Map<String,Object> sf_to_cb_values=CBCustomFieldMappingUtil.getCustomFieldDataForCustomer(cont.Id,sf_to_cb_mapping);
            if(sf_to_cb_values!=null){
                for(String fieldName:sf_to_cb_values.keySet()){
                    if(sf_to_cb_values.get(fieldName)+''!=CBCustomFieldMappingUtil.NO_VALUE_SET)
                    url = CBURLUtil.buildURLString(url, fieldName, sf_to_cb_values.get(fieldName)+'');
                }
            }
            //custom field mapping handling ends
            String cbResponse = CBURLUtil.sendRequest(endpointURL, url, urlUtil, true);
            System.debug('cbResponse' + cbResponse);
            String extId = CBURLUtil.getIdFromResponse(cbResponse);
                        
            if(extId == null){
                response = 'Error updating customer';
                try{
                    Map<String,Object> error=(Map<String,Object>)JSON.deserializeUntyped(cbResponse);
                    if(error.containsKey('message')){
                        response = 'Unable to create Customer in Chargebee. '+ (String)error.get('message');
                    }
                }
                catch(Exception e){
                    //do nothing
                }
            }
            //update customer billing info
            endpointURL = urlUtil.getUrl()+'/api/v2/customers/' + existingConSite[0].chargebeeapps__External_Id__c + '/update_billing_info';
            url = '';
            url = CBURLUtil.buildURLString(url, 'billing_address[email]', cont.Email);
            url = CBURLUtil.buildURLString(url, 'billing_address[first_name]', cont.FirstName);
            url = CBURLUtil.buildURLString(url, 'billing_address[last_name]', cont.LastName);
            url = CBURLUtil.buildURLString(url, 'billing_address[phone]', cont.Phone);
            url = CBURLUtil.buildURLString(url, 'billing_address[line1]', cont.MailingStreet);
            url = CBURLUtil.buildURLString(url, 'billing_address[city]', cont.MailingCity);
            url = CBURLUtil.buildURLString(url, 'net_term_days', getNetTerm(cont.chargebeeapps__Net_Term_Days__c));
            url = CBURLUtil.buildURLString(url, 'billing_address[state]', cont.MailingState);
            url = CBURLUtil.buildURLString(url, 'billing_address[zip]', cont.MailingPostalCode);
            url = CBURLUtil.buildURLString(url, 'billing_address[country]', ChargebeeUtil.getCountryCode(cont.MailingCountry));
            if(acct!=null){
                url = CBURLUtil.buildURLString(url, 'billing_address[company]', acct.Name);
            }
            Object isPaymentNetTermEnabled = urlUtil.getSiteConf('payment_term');
            Object defaultAutoCollectionFlag = urlUtil.getSiteConf('auto_collection');
        
            if(isPaymentNetTermEnabled != null && Boolean.valueOf(isPaymentNetTermEnabled) ){
                url = CBURLUtil.buildURLString(url, 'auto_collection', 'off');
            }else if(defaultAutoCollectionFlag != null){
                url = CBURLUtil.buildURLString(url, 'auto_collection', String.valueOf(defaultAutoCollectionFlag));
            }else{
                url = CBURLUtil.buildURLString(url, 'auto_collection', 'on');
            }
            cbResponse = CBURLUtil.sendRequest(endpointURL, url, urlUtil, true);
                
            return extId;
        }
        
        public void triggerSync(String extId){
            System.debug('Trigger Customer Sync');
            String endpointURL = urlUtil.getUrl() + '/salesfoce/api/sync_entity';
            String url = '';
            url = CBURLUtil.buildURLString(url, 'entity_handle', extId);
            url = CBURLUtil.buildURLString(url, 'api_key', urlUtil.getApiKey());
            url = CBURLUtil.buildURLString(url, 'entity_type', 'CUSTOMER');
            String cbResponse = CBURLUtil.sendRequest(endpointURL, url, urlUtil, false);
            System.debug('cbResponse-' + cbResponse);
        }
        
        private void UpdateSFContact(String extId){
            if(!(extId==null || extId=='')){
                system.debug('External Id:'+extId);
                
                if (Schema.sObjectType.chargebeeapps__Contact_Associate_Site__c.fields.External_Id__c.isCreateable())
                {
                    conSite.External_Id__c = extId;
                }
                    system.debug('External Id:'+conSite.chargebeeapps__External_Id__c);
                if (Schema.sObjectType.chargebeeapps__Contact_Associate_Site__c.fields.Contact__c.isCreateable())
                {
                    conSite.Contact__c  = cont.Id;
                }
                    String sid = SiteUtil.getSiteId(siteName);
                    system.debug('site '+sid);
                if (Schema.sObjectType.chargebeeapps__Contact_Associate_Site__c.fields.CB_Site__c.isCreateable())
                {
                    conSite.CB_Site__c = sid;
                }
                    Insert conSite;
                   system.debug('conSite '+conSite); 
                
            }
        }
        
        private boolean isAllowed(){
            if(Schema.sObjectType.chargebeeapps__Contact_Associate_Site__c.isCreateable() && Schema.sObjectType.chargebeeapps__Contact_Associate_Site__c.fields.chargebeeapps__External_Id__c.isCreateable() && Schema.sObjectType.chargebeeapps__Contact_Associate_Site__c.fields.chargebeeapps__Contact__c.isCreateable() && Schema.sObjectType.chargebeeapps__Contact_Associate_Site__c.fields.chargebeeapps__CB_Site__c.isCreateable()){
                return true;
            }
            return false;
        }
     
     private String getNetTerm(String netTerm){
         Object isPaymentNetTermEnabled = urlUtil.getSiteConf('payment_term');
         if(isPaymentNetTermEnabled != null && Boolean.valueOf(isPaymentNetTermEnabled) ){
         Object defPaymentNetTerm = urlUtil.getSiteConf('def_payment_term_value');
             if( netTerm != null && !netTerm.trim().equals('') ){
                 return netTerm;
             }else if( defPaymentNetTerm != null && !(String.valueOf(defPaymentNetTerm).trim().equals('')) ){
                 return String.valueOf(defPaymentNetTerm);
             }
         }
         
         return null;
     }       
}