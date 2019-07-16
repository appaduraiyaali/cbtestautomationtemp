@RestResource(urlMapping='/ChargebeeSettingsMultiEntity/v1/*')
global with sharing class ChargebeeSettingsMultiEntity{

    @HttpGet
    global static string doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        //String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        //Account result = [SELECT Id, Name, Phone, Website FROM Account WHERE Id = :accountId];
        chargebeeapps__CB_Settings__c mhc = chargebeeapps__CB_Settings__c.getInstance();
        string apikey = mhc.API_Key__c;
        return apikey;
    }
    
    @HttpPost
    global static String doPost(string apikey,string chargebeeurl,string username,string settingJSON,String domainName ) {
    
        //CB_Settings__c CBset = new CB_Settings__c();
        chargebeeapps__CB_Settings__c CBset = new chargebeeapps__CB_Settings__c();
        List<chargebeeapps__CB_Settings__c> CBsetList1 = new List<chargebeeapps__CB_Settings__c>();
        List<chargebeeapps__CB_Settings__c> CBsetList2 = new List<chargebeeapps__CB_Settings__c>();
        List<chargebeeapps__CB_Settings__c> CBsetList = chargebeeapps__CB_Settings__c.getAll().values();
        System.debug('Size is:'+CBsetList.size());
        
        if( !( String.isNotBlank(apikey)
            && String.isNotBlank(chargebeeurl)
           &&string.isNotBlank(username)
           &&  string.isNotBlank(settingJSON)&& string.isNotBlank(domainName)))
        {
           //return('Input can not be null or empty') ;
           System.debug('Custom Field Values are emptys');
           return 'Error: Custom Setting Field cannot be empty or null';
            // Return error; // Clarify from Hari
        }
        
        chargebeeapps__CB_Settings__c matchingrecord= chargebeeapps__CB_Settings__c.getInstance(domainname); 
            
            if(matchingrecord == null)
            {
                matchingrecord = new chargebeeapps__CB_Settings__c();                
            }
            matchingrecord.Name = domainName;
                System.debug('Name:'+matchingrecord.Name);
                matchingrecord.API_Key__c = apikey;
                System.debug('Api:'+matchingrecord.API_Key__c);
                matchingrecord.ChargeBee_URL__c = chargebeeurl;
                System.debug('url:'+matchingrecord.ChargeBee_URL__c);
                matchingrecord.User_Name__c  = username;
                System.debug('url:'+matchingrecord.User_Name__c);
                if(settingJSON!=null){
                    Map<String,String> jsonsettingMap=(Map<String,String> )JSON.deserialize(settingJSON, Map<String,String>.class);
                    if(jsonsettingMap.containsKey('site_settings')){
                        chargebeeapps__CB_Sites__c[] appData=[select Id,Name,chargebeeapps__Custom_Field_Mapping__c from chargebeeapps__CB_Sites__c where Name=:domainName];
                        if(appData.size()>0){
                            appData[0].chargebeeapps__Custom_Field_Mapping__c =(String)jsonsettingMap.get('sf_cb_map');
                            update appData[0];
                        }
                        jsonsettingMap.remove('site_settings');
                        settingJSON=JSON.serialize(jsonsettingMap);
                    }
                }
                matchingrecord.chargebeeapps__Settings_JSON__c = settingJSON;
                System.debug('url:'+matchingrecord.chargebeeapps__Settings_JSON__c); 
                
               upsert matchingrecord;                     
               return matchingrecord.API_Key__c;
              // return matchingrecord.Name;
    }   
}