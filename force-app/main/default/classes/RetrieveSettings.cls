@RestResource(urlMapping='/retrieve/v1_5/*')
global with sharing class RetrieveSettings {

    @HttpGet
    global static string doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        chargebee__c mhc = chargebee__c.getInstance();
        string url = mhc.ChargeBee_URL__c;
        string apikey = mhc.API_Key__c;
        string json = mhc.Settings_JSON__c;
        string name = mhc.User_Name__c;
        string settings = url+'|'+apikey+'|'+name+'|'+json;
        return settings;
    }
    
    
}