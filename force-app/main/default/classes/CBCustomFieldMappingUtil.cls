public class CBCustomFieldMappingUtil {
    public static String NO_VALUE_SET='__null';
    public static Map<String,Object> getFieldMapping(String domain){
        try{
            chargebeeapps__CB_Sites__c [] cb=[select Id,Name,chargebeeapps__Custom_Field_Mapping__c from chargebeeapps__CB_Sites__c  where Name=:domain];
            if(cb.size()>0 && cb[0].chargebeeapps__Custom_Field_Mapping__c!=null){
                Map<String, Object> settings=(Map<String, Object>)JSON.deserializeUntyped((String)cb[0].chargebeeapps__Custom_Field_Mapping__c);
                if(settings.get('sf_cb_map')!=null){
                    return (Map<String, Object>)settings.get('sf_cb_map');
                }
            }
        }
        catch(Exception e){
            system.debug('Exception::'+e);
        }
        return new Map<String, Object>();
    }
    public static Map<String, Object> getCustomFieldDataForSubscription(String opp_id,Map<String, Object> mapping){
        Map<String, Object> returnMap=new Map<String, Object>();
        if(mapping.containsKey('Opportunity')){
            returnMap=getDataFromObject(opp_id, 'Opportunity', (Map<String, Object>)mapping.get('Opportunity'));
        }
        if(returnMap.isEmpty()) return null;
        return returnMap;
    }
    public static Map<String, Object> getCustomFieldDataForCustomer(String contact_id,Map<String, Object> mapping){
        Map<String, Object> returnMap=new Map<String, Object>();
        boolean isTempField=false;
        if(mapping.containsKey('Contact')){
            if(mapping.containsKey('Account')){
                if(!((Map<String, Object>)mapping.get('Contact')).containsKey('AccountId')){
                    ((Map<String, Object>)mapping.get('Contact')).put('AccountId',contact_id+'AccountId');
                    isTempField=true;
                }
            }
            returnMap=getDataFromObject(contact_id, 'Contact', (Map<String, Object>)mapping.get('Contact'));
        }
        
        if(mapping.containsKey('Account')){
            if(returnMap.containsKey((String)((Map<String, Object>)mapping.get('Contact')).get('AccountId'))){
                String accountId=(String)returnMap.get((String)((Map<String, Object>)mapping.get('Contact')).get('AccountId'));
                returnMap.putAll(getDataFromObject(accountId,'Account', (Map<String, Object>)mapping.get('Account')));
            }
               
            if(isTempField){
                returnMap.remove((String)((Map<String, Object>)mapping.get('Contact')).get('AccountId'));
                ((Map<String, Object>)mapping.get('Contact')).remove('AccountId');
            }
        }
        if(returnMap.isEmpty()) return null;
        return returnMap;
    }
    Private static Map<String,Object> getDataFromObject(String id,String objectName, Map<String, Object> fields){
        Map<String, Object> returnMap=new Map<String, Object>();
        if(fields.size()>0){
            sObject obj=null;
            if(id!=null && id!=NO_VALUE_SET){
                String query='select ';
                integer count=0;
                for(String field:fields.keySet()){
                    if(count!=0){
                        query+=', ';
                    }
                    query+=field;
                    count++;
                }
                query+=' from '+objectName+' where Id=:id';
                obj=Database.query(query);
            }
            system.debug('fields'+fields);
            system.debug('object::'+obj);
            for(String col:fields.keySet()){
                Object value=NO_VALUE_SET;
                if(obj!=null && obj.get(col)!=null){
                   value=obj.get(col);
                }
                returnMap.put((String)fields.get(col),value);
            }
        }
        system.debug('return::'+returnMap);
        return returnMap;
    }
}