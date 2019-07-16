@RestResource(urlMapping='/chargebeesettings/*')
global with sharing class ChargeBeeSettings {

    @HttpGet
    global static string doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
      //  String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
       // Account result = [SELECT Id, Name, Phone, Website FROM Account WHERE Id = :accountId];
        chargebee__c mhc = chargebee__c.getInstance();

        string apikey = mhc.API_Key__c;

        return apikey;
    }

    @HttpPost
    global static String doPost(string apikey,string username,string chargebeeurl) {
    chargebee__c mhc = chargebee__c.getInstance();
    if(apikey!=null)
    {
      mhc.API_Key__c=apikey;
    }
    if(username!=null)
    {
      mhc.User_Name__c=username;
    }
    if(chargebeeurl!=null)
    {
      mhc.ChargeBee_URL__c=chargebeeurl;
    }
    upsert mhc;
    return mhc.API_Key__c;
    }
}