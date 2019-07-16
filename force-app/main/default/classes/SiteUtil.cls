public with sharing class SiteUtil{

    public static Map<String,String> siteMap{
    get{
            Map<String,String> sm = new Map<String,String>();
            List<chargebeeapps__CB_Sites__c> sites= [select Id,Name from chargebeeapps__CB_Sites__c LIMIT 100];
            for(chargebeeapps__CB_Sites__c s:sites){
                sm.put(s.Id,s.Name);
            }
        return sm;
    }set;}
    
    public static Map<String,Map<String,Object>> settingsMap{
    get{
            Map<String,Map<String,Object>> sm = new Map<String,Map<String,Object>>();
            List<chargebeeapps__CB_Sites__c> sites= [select Id,Name,chargebeeapps__Custom_Field_Mapping__c from chargebeeapps__CB_Sites__c LIMIT 100];
            for(chargebeeapps__CB_Sites__c s:sites){
                if(s.chargebeeapps__Custom_Field_Mapping__c!=null){
                    Map<String,Object> mp=CBURLUtil.convertMap(s.chargebeeapps__Custom_Field_Mapping__c);
                    if(mp.get('quote_settings')!=null)
                        sm.put(s.Id,(Map<String,Object>)mp.get('quote_settings'));
                }
                
            }
        return sm;
    }set;}
    
   public static String getSiteName(String site_id){
       return siteMap.containsKey(site_id)?siteMap.get(site_id):null;       
   }
   public static String getSiteId(String site_name){
       for(String s:siteMap.keySet()){
           String site=siteMap.get(s);
           if(site.equalsIgnoreCase(site_name)){
               return s;
           }
       }
       return null;
   }

   public static boolean isQuoteApprovalUsed(String siteId) {
       if(settingsMap.get(siteId)!=null){
              Map<String,Object> mp=settingsMap.get(siteId);
              if(mp.get('use_approvals')!=null){
                  return mp.get('use_approvals')==true;
              }
       }
       return false;
   }

   public static boolean sendQuoteAcceptanceLinkInEmail(String siteId) {
       if(settingsMap.get(siteId)!=null){
              Map<String,Object> mp=settingsMap.get(siteId);
              if(mp.get('send_email_without_link')!=null){
                  return mp.get('send_email_without_link')==true;
              }
       }
       return true;
   }

   public static boolean sendQuoteEmailWithoutApproval(String siteId) {
       if(settingsMap.get(siteId)!=null){
              Map<String,Object> mp=settingsMap.get(siteId);
              if(mp.get('send_email_without_approvals')!=null){
                  return mp.get('send_email_without_approvals')==true;
              }
       }
       return true;
   }

   public static boolean createNewOpportunityOnUpdate(String siteId) {
       if(settingsMap.get(siteId)!=null){
              Map<String,Object> mp=settingsMap.get(siteId);
              if(mp.get('create_opp_on_update')!=null){
                  return mp.get('create_opp_on_update')==true;
              }
       }
       return false;
   }

   public static boolean doNotCreateOrUpdateOpportunity(String siteId) {
       if(settingsMap.get(siteId)!=null){
              Map<String,Object> mp=settingsMap.get(siteId);
              if(mp.get('do_not_create_or_update_opp')!=null){
                  return mp.get('do_not_create_or_update_opp')==true;
              }
       }
       return true;
   }

}