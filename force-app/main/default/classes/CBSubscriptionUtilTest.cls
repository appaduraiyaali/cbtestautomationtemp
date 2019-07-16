@IsTest public with sharing class CBSubscriptionUtilTest {
    
    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting();
        
         TestdataUtility.insertSiteDetails();
         chargebeeapps__CB_Sites__c sites = TestdataUtility.getSites();
         
         Contact[] contacts = TestdataUtility.insertContacts();
         chargebeeapps__Contact_Associate_Site__c consites = TestdataUtility.insertContactSite(sites.Id,contacts[0].Id);
         TestdataUtility.insertOpportunity();
         TestdataUtility.insertProducts();
         
    }	 
    
    @IsTest public static void testEstimateEndPoint()
    {
        Product2 prd1 = [select Name,ExternalId from Product2 where ExternalId ='TestAddon7' LIMIT 1];
        Product2 prd2 = [select Name,ExternalId from Product2 where ExternalId ='TestAddon8' LIMIT 1];
        chargebeeapps__Contact_Associate_Site__c contactSite = [select Id,chargebeeapps__External_Id__c,chargebeeapps__SiteName__c 
                                                                from chargebeeapps__Contact_Associate_Site__c where chargebeeapps__External_Id__c='1ps2glZRUOKGciVZ5'];
        Opportunity opt = [select Id,Name,StageName,CloseDate from Opportunity where Name='test opp1' LIMIT 1];
        AddonObject addlList1 = new AddonObject('TestAddon7', 1,001, 120.05,false);
        addlList1.status =1;
        AddonObject addlList2 = new AddonObject('TestAddon8', 2,002, 120.05,false);
        addlList2.status = 2;
        List<AddonObject> selList = new List<AddonObject>();
        selList.add(addlList1);
        selList.add(addlList2);
        List<SelectOption> sortingList = new List<SelectOption>();
        sortingList.add(new SelectOption('Select','Select'));
        sortingList.add(new SelectOption('Select','Select'));
        Map<String,String> PlanExternalIdVsChargeModel = new Map<String,String>();
        CBURLUtil urlUtil = new CBURLUtil();
        CBSubscriptionUtil cbu = new CBSubscriptionUtil();
        
        CBSubscriptionUtil.getEstimateEndPoint(urlUtil, contactSite.Id);
        CBSubscriptionUtil.getCreateSubscriptionEndPoint(urlUtil, contactSite.Id);
        
        CBSubscriptionUtil.getAddonURL(selList, 'bodyData', PlanExternalIdVsChargeModel, true);
        CBSubscriptionUtil.getListUnbilledChargesEndPoint(urlUtil);
        CBSubscriptionUtil.getUnbilledChargesEstimateEndPoint(urlUtil);
        string returl = CBSubscriptionUtil.getUpdateTPEndPoint(urlUtil);
        CBSubscriptionUtil.getCancelSubscriptionEndPoint(urlUtil, 'id001');
        CBSubscriptionUtil.getSyncSubsEndPoint(urlUtil);
        CBSubscriptionUtil.getSubscriptionStartDate('2018-06-23 02:30:00');
        CBSubscriptionUtil.getDataForTpSync(opt.Id, 'bodyData','CREATE_FAILED');
        CBSubscriptionUtil.getCheckoutURL(urlUtil,'cbtest1');
        CBSubscriptionUtil.getCheckoutURL(urlUtil);
        CBSubscriptionUtil.sortSelectOptions(sortingList);
        //CBSubscriptionUtil.getImmediateChargeDisplayText('curCode', 2018-06-23 02:30:00, 1.234d);
        CBSubscriptionUtil.getInvoiceUnbilledChargesEndPoint(urlUtil);
        CBSubscriptionUtil.getInvDisplayText('curCode', 1.234d);
        CBSubscriptionUtil.getNoChargeDisplayText();
        CBSubscriptionUtil.getNoChargeWithTotDisplayText('curCode', 1.234d);
        system.debug('returl '+returl);
        system.assertEquals(returl,'https://cbtest1.chargebee.com/api/v2/third_party_entity_mappings/update_entity');

        CBSubscriptionUtil.getListUnbilledChargesEndPoint(urlUtil,'cbtest1');
        CBSubscriptionUtil.getUnbilledChargesEstimateEndPoint(urlUtil,'cbtest1');
        //Datetime dtTime = Datetime.valueOf(2018/06/23 10:30:00);
        CBSubscriptionUtil.getImmediateChargeDisplayText('USD',system.today(),1.234d);
    }
}