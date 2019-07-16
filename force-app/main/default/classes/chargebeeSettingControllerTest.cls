@IsTest public with sharing class chargebeeSettingControllerTest {
	

    @TestSetup public static void insertRecord()
    {
        TestdataUtility.insertCustomSetting();
         
        TestdataUtility.insertSiteDetails();
         
    }
    @IsTest public static void testChargebeeSettig() 
     {
         PageReference pageRef = Page.ChargeBeeSettings;
         test.setCurrentPageReference(pageRef);
         ChargeBeeSettingController cbc = new ChargeBeeSettingController();
         cbc.selectedSite = 'cbtest1';
         
         cbc.getSiteDetails();
         ChargeBeeSettingController.CustomSettingProxy multiSiteSetting = new ChargeBeeSettingController.CustomSettingProxy('cbtest1');
         ChargeBeeSettingController.CustomSettingProxy singleSiteSetting = new ChargeBeeSettingController.CustomSettingProxy();
         
         cbc.showRelatedData();
         cbc.loadDefaultSetting();
         PageReference p = cbc.ToError();
         string url = p.getUrl();
         system.debug('url'+url);
         multiSiteSetting.redirectToError();
         system.assert(url.contains('/apex/chargebeeapps__error'));
         
     }
}