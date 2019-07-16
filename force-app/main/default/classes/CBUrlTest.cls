@IsTest public with sharing class CBUrlTest 
{
   
    @TestSetup public static void insertRecord()
    {
        TestdataUtility.insertCustomSetting();
         
         TestdataUtility.insertSiteDetails();
         
    }
     static boolean boolValue;
    //boolean overRide;
     @IsTest public static void testCBUrl() 
     {
         CBURLUtil urlUtil = new CBURLUtil('cbtest1');
         String url = urlUtil.getUrl();
         String api_key = urlUtil.getApiKey();
         string autoCollectionFlag = urlUtil.autoCollectionFlag();
         boolean canOverRide = urlUtil.canOverRide();
         urlUtil.getSiteConf('key');
         System.assertNotEquals(url,null);
         System.assertNotEquals(api_key,null); 
         //System.assertEquals(url,'https://cbtest1.chargebee.com');
         
     }
     
     @IsTest public static void testCBUrl1() 
     {
         CBURLUtil urlUtil = new CBURLUtil('cbtest1');
         String url = urlUtil.getUrl();
         String api_key = urlUtil.getApiKey();
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockCustGenerator('SyncNew'));
         String resp = CBURLUtil.sendRequest('https://cbtest1.chargebee.com/api/v2/subscriptions/1mkVvwZQYZrOPS3c40/change_term_end_estimate','',urlUtil,true);
         Test.stopTest();
         System.assertNotEquals(url,null);
         System.assertNotEquals(api_key,null); 
         //System.assertEquals(url,'https://cbtest1.chargebee.com');
         
     }
    //Yaali:added starts
    @IsTest public static void testCBUrlMultiSites() 
     {
         //string key;
         //string response = '{"hosted_page": {"id": "XZVi9PAZs3wa09O9nib1gdGoaTNhr9mC", "type": "manage_payment_sources","url": "https://cbtest1.chargebee.com/pages/v3/XZVi9PAZs3wa09O9nib1gdGoaTNhr9mC/","object": "hosted_page",}}';
         //string domain = 'cbtest1';
         
         CBURLUtil urlUtil = new CBURLUtil('cbtest1');
         String url = urlUtil.getUrl();
         
         String api_key = urlUtil.getApiKey();
         string settingJson = urlUtil.getSiteSettingJSON();
         string username = urlUtil.getUserName();
         boolValue = CBURLUtil.isMultiSite();
         Map<String,CB_Settings__c> sitedetails = CBURLUtil.getAllSiteDetails();
         Map<String, Object> convertData = CBURLUtil.convertMap('data');
         string autoCollectionFlag = urlUtil.autoCollectionFlag();
         boolean canOverRide = urlUtil.canOverRide();
         urlUtil.getSiteConf('key');
         CBURLUtil.boolToString(true);
         string buildUrl = CBURLUtil.buildURLString(url, 'email', 'sivanee.purohit@gmail.com');
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockCustGenerator('SyncNew'));
         String resp = CBURLUtil.sendRequest('https://cbtest1.chargebee.com/api/v2/customers',buildUrl,urlUtil,true);
         string responseId = CBURLUtil.getIdFromResponse(resp);
         string responseVal = CBURLUtil.getValueFromResponse(resp, 'email') ;
         
         PageReference pageRef =  urlUtil.redirectToError();
         Test.stopTest();
         System.assertNotEquals(url,null);
         System.assertNotEquals(api_key,null);
         System.assertNotEquals(autoCollectionFlag,null);
         //System.assertEquals(autoCollectionFlag,'OFF');
         //System.assertEquals(canOverRide,null);
         //System.assertEquals(url,'https://cbtest1.chargebee.com');
         
     }
    //End
}