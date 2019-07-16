@RestResource(urlMapping='/fieldpermissions/*')
global with sharing class FieldPermissions {

    @HttpGet
    global static string doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        //String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        //Account result = [SELECT Id, Name, Phone, Website FROM Account WHERE Id = :accountId];
        chargebee__c mhc = chargebee__c.getInstance();
        string apikey = mhc.API_Key__c;
        return apikey;
    }
    
      
}