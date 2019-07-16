@IsTest public with sharing class NextInvTest 
{
    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting();
         
         TestdataUtility.insertSiteDetails();
         
    }
     @IsTest public static void testSubscription() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         NextInvEstimate cbn = new NextInvEstimate(10000,'USD');
         cbn.addLineItems('1234','2','dafsd','4543');
         system.assertEquals(cbn.curCode,'USD');
     }
     
     
}