@IsTest(SeeAllData = true) public with sharing class BaseLTest 
{
     @IsTest(SeeAllData = true) public static void testSubscription() 
     {
         BaseEstLineItem cbn = new BaseEstLineItem('10000','2','fdgfdh','3546','USD');
         system.assertEquals(cbn.description,'fdgfdh');
         
     }
     
     
}