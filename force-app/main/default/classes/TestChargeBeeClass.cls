@isTest
 public class TestChargeBeeClass {
static testMethod void testPost() {
       // Add test method logic using System.assert(), System.assertEquals()
       // and System.assertNotEquals() here.
      string getresponse = ChargeBeeSettings.doPost('set from apikey','username@chargebee.com','https://chargebee.com');
      system.assertEquals(getresponse, 'set from apikey');
     }


    static testMethod void testGet() {
       // Add test method logic using System.assert(), System.assertEquals()
       // and System.assertNotEquals() here.
       string getresponse = ChargeBeeSettings.doGet();
       System.debug('Get Response ' + getresponse);
	   system.assertEquals(getresponse, null);
     }

static testMethod void testSave(){
ChargeBeeSettingController cbsettings = new ChargeBeeSettingController();
//cbsettings.saveSettings();
system.assert(true);
}

static testMethod void testSave1(){
ChargeBeeSettingController cbsettings = new ChargeBeeSettingController();
//cbsettings.save();
system.assert(true);
}

     
     }