@isTest
public class ChargebeeSettingsMultiEntityTest {
static testMethod void testPost() {
       // Add test method logic using System.assert(), System.assertEquals()
       // and System.assertNotEquals() here.
       Map<String,String> m=new Map<String,String>();
    	m.put('Id', 'first_name');
        Map<String,String> m1=new Map<String,String>();
    	m1.put('Contact',JSON.serialize(m));
    	Map<String,String> m2=new Map<String,String>();
        m2.put('sf_cb_map', JSON.serialize(m1));
       ChargebeeSettingsMultiEntity.doPost('set from apikey','https://chargebee.com','testsite',JSON.serialize(m2),'username@chargebee.com');
       ChargebeeSettingsMultiEntity.doPost('set from apikey1','https://chargebee.com','testsite',JSON.serialize(m2),'username@chargebee.com');
       ChargebeeSettingsMultiEntity.doPost('set from apikey1','https://chargebee.com','testsitedemo',JSON.serialize(m2),'username@chargebee.com');
       ChargebeeSettingsMultiEntity.doPost(null,null,null,null,null);
       string getresponse = ChargebeeSettingsMultiEntity.doPost('','','','','');
       System.debug('post Response ' + getresponse);
       system.assertEquals(getresponse, 'Error: Custom Setting Field cannot be empty or null');
     }


    static testMethod void testGet() {
       // Add test method logic using System.assert(), System.assertEquals()
       // and System.assertNotEquals() here.
       string getresponse = ChargebeeSettingsMultiEntity.doGet();
       System.debug('Get Response ' + getresponse);
	   system.assertEquals(getresponse, null);
     }

     }