@IsTest public with sharing class UBTest 
{
   
    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting();
         
         TestdataUtility.insertSiteDetails();
         
         
    }
     @IsTest public static void testSubscription() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         UnbilledEstimate cbn = new UnbilledEstimate('10000','2','fdgfdh','3546','3456','USD','1548659739','1548659739','Plan','cbdemo',true,false);
         system.assertEquals(cbn.quantity,'2');
     }
     
     
}