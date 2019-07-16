/* This test class captures the test cases for 
 * various paths when the "Sync to ChargeBee" button action is done
 * from the Contact Details page.
 * Some of the use cases covered are
 * 1. Action to Sync Salesforce Contact to Chargebee which already exists in CB.
 * 2. Action to New Synch Salesforce Contact to Chargebee.
 * 3. Redirection/Error Message based on Failure response from Chargebee after Sync action.
 */

@IsTest public class UCSyncCustTest {
	/* This method will pre-load the data needed for
     * testing the "Sync" button click UserAction 
     * from Contact Detail page. The subsequent test methods for various
     * use cases will use this data 
     */
    @TestSetup public static void populateTestData()
    {
         TestdataUtility.insertCustomSetting(); 
         TestdataUtility.insertSiteDetails();
         chargebeeapps__CB_Sites__c site = TestdataUtility.getSites();        
         Contact[] contacts = TestdataUtility.insertContacts();
         TestdataUtility.insertContactSite(site.Id,contacts[1].Id);
         
    }
    /* This method simulates the test case when "Confirm" button click UserAction
     * is triggered from a Contact which is not synched to CB. 
     * The following cases are verified
     * 1.System.asserts verify that the next page navigation is "Create/Update customer page".  
     * 2.Sync the Contact details to CB and asserts positive case
     * from Server Mock response 
     */
    @IsTest public static void syncNewCustTest()
    {
        Contact con = TestdataUtility.getContact('test1');
        CBCustomerTest.cbCreateSubNewCus(con,'sync','NewCon');
    }
    /* This method simulates the test case when "Confirm" button click UserAction
     * is triggered from a Contact which is synched to CB. 
     * The following cases are verified 
     * 1.System.asserts verify that the next page navigation is "Create/Update customer page".    
     * 2.Sync the Contact details to CB and asserts positive case
     * from Server Mock response 
     */
    @IsTest public static void syncExistingCustTest()
    {
        Contact con = TestdataUtility.getContact('test2');
        CBCustomerTest.cbCreateSubNewCus(con,'sync','ExistingCon');
    }
    /** This method simulate the use case when "Confirm" action is triggered from
     * Contact detail page, contact is created without giving a emailid.
     
     * 1. System assert to ensure that error message is handled when "Confirm" button click user action
     * is done at "Create/Update Customer" page.
     * 3. "Cancel" user action is also handled which will navigate back to contact page.
     */
    @IsTest public static void newCusSyncWTEmail()
    {
        Contact con = new Contact(LastName='test3',FirstName='con3');  
        insert con;
        CBCustomerUtilTest.cusSyncWithNoEmail(con);
        delete con;
    }
    /* UseCase Simulation: Contact is created in Salesforce and "Confirm" button click user action
     * is done. 
     * Result is page navigation should go to "Create/Update customer page" page.
     * When we try to synch without selecting a target domain/site, handled
     * assert to validate the error message. 
     */ 
    @IsTest public static void contactWithNoSite()
    {
        Contact con = TestdataUtility.getContact('test1');
        CBCustomerTest.cusSyncWithNoSite(con);
        
    }
    /* This method simulates the use case when "Confirm" action is triggered from
	   "Create/Update customer page" for a synced contact(Synced in CB but not present now) 
     * assert to validate the API error message.
     */
    @IsTest public static void newCusSyncAPIError()
    {
        Contact con = TestdataUtility.getContact('test1');
        CBCustomerTest.custWithOutExtIdInResp(con,'NewCon');
    }
    /* This method simulates the use case when "Confirm" action is triggered from
	   "Create/Update customer page" for a new contact(not present in CB) 
     * assert to validate the API error message.
     */
    @IsTest public static void existingCusAPIError()
    {
        Contact con = TestdataUtility.getContact('test2');
        CBCustomerTest.custWithOutExtIdInResp(con,'ExistingCon');
    }
}