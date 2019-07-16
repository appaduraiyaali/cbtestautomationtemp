@IsTest
public class Gbuildertest 
{
    
    @TestSetup public static void insertRecord()
    {
        TestdataUtility.insertCustomSetting();
         
         TestdataUtility.insertSiteDetails();
         
    }
     @IsTest
     public static void test1() 
     {
         chargebeeapps__CB_Sites__c sites1 = [select name from chargebeeapps__CB_Sites__c  where name='cbtest1'];
         GenericURLBuilder br1 = new GenericURLBuilder();
         GenericURLBuilder br = new GenericURLBuilder(EndPointsIndex.get_plan_details);
         GenericController cr = new GenericController();
         GenericController cr1 = new GenericController(br);
         cr1.createURL(new Map<String,String>());
         system.assertEquals(br.ustring,'');
     }
     
    
 }