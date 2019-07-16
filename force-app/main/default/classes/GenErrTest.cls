@IsTest public with sharing class GenErrTest 
{
   
    @TestSetup public static void insertRecord()
    {
         TestdataUtility.insertCustomSetting();
         
         TestdataUtility.insertSiteDetails();
         
         TestdataUtility.insertContacts();
        
    }
    @IsTest public static void noArg() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         
         Contact con = [select Id,LastName from Contact where LastName='test1' LIMIT 1];
         PageReference pageRef = Page.General_err;
         test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('err',con.Id);
         pageRef.getParameters().put('id',con.Id);
         GenError b = new GenError();
         system.assertEquals(b.err,con.Id);
     }
     
     
     
}