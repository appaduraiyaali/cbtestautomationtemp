public with sharing class CBURLUtil
{
    //chargebee__c mhc{get;set;}    
    public chargebeeapps__CB_Settings__c mhc{get;set;}
    
    public CBURLUtil(){
        
        List<chargebeeapps__CB_Settings__c > siteList= chargebeeapps__CB_Settings__c.getAll().values();
        mhc=siteList[0]; 
        
    }
    
    public CBURLUtil(String domainName)
    {
        System.debug('domainName---'+domainName);
        if(domainName!=null){
            domainName = domainName.trim();
        }
        
        mhc= chargebeeapps__CB_Settings__c.getInstance(domainName);    
            
        
        
        System.debug('Setting in CBURLUTIL ' + mhc);
    }
    public static Map<String,CB_Settings__c> getAllSiteDetails()
    {
        return chargebeeapps__CB_Settings__c.getAll();
    }

public PageReference redirectToError(){
   PageReference pageRef = new PageReference('/apex/error');
   pageRef.setRedirect(true);
   return pageRef; 
}

public static boolean isMultiSite()
{
    return chargebeeapps__CB_Settings__c.getAll().size() > 1;
}
  
public String getUrl()
{
    return mhc.chargebeeapps__ChargeBee_URL__c;
}

public String getApiKey()
{
    return mhc.chargebeeapps__API_Key__c;
}

public String getSiteSettingJSON()
{
    return mhc.chargebeeapps__Settings_JSON__c;
}

public String getUserName()
{
    return mhc.chargebeeapps__User_Name__c;
}    

public Object getSiteConf(String key){
    String settingString = getSiteSettingJSON();
    Map<String, Object> SiteSettingObject = 
        settingString!=null?(Map<String, Object>)JSON.deserializeUntyped(settingString):null;
        
    if( SiteSettingObject != null && SiteSettingObject.containsKey(key) ){
        return SiteSettingObject.get(key);
    }
    return null;
}

public static String buildURLString(String url, String paramName, String paramValue){
    if(paramValue != null && !paramValue.equals('')){
        if(url == null || url == ''){
            url = '';
            url = url + paramName + '=' + EncodingUtil.urlEncode(paramValue, 'UTF-8');
        }else{
            url = url + '&' + paramName + '=' + EncodingUtil.urlEncode(paramValue, 'UTF-8');
        }
    }
    return url;
}

public static String sendRequest(String endpointURL, String bodyData, CBURLUtil urlUtil, boolean needAuth){
    return sendRequest(endpointURL, bodyData, urlUtil, needAuth,'POST');
}

public static String sendRequest(String endpointURL, String bodyData, CBURLUtil urlUtil, boolean needAuth, String action){
        HttpRequest reqData = new HttpRequest();
        Http http = new Http(); 
        reqData.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        reqData.setHeader('Connection','keep-alive');
        reqData.setTimeout(20000); 
        reqData.setEndpoint(endpointURL);
        if(needAuth){
            String username = urlUtil.getApiKey();
            System.debug('key-->>>'+username);
            Blob headerValue = Blob.valueOf(username + ':');
            String authorizationHeader = 'BASIC ' +
            EncodingUtil.base64Encode(headerValue);
            reqData.setHeader('Authorization', authorizationHeader); 
        }                              
        reqData.setMethod(action);
        if( bodyData != null ){
            reqData.setBody(bodyData);
        }
        String responseFromNet;  
        HTTPResponse res = http.send(reqData);
        responseFromNet = res.getBody();
        return responseFromNet;
}

     public static String getIdFromResponse(String responseFromNet){
        String ext_id = null;
         system.debug('Response:'+responseFromNet);
        if(responseFromNet != null && responseFromNet.startsWith('{'))
        {
            JSONParser parser = JSON.createParser(responseFromNet);
            while (parser !=null && parser.nextToken() != null) 
            {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id'))
                {
                    //system.debug('next token:'+parser.nextToken());
                    //system.debug(parser.getCurrentToken());
                     parser.nextToken();   
                     ext_id = parser.getText();
                    system.debug('Externalid:'+ext_id);
                     return ext_id;
                }
            }
        }
        return ext_id;
    }
    
    public static String getValueFromResponse(String responseFromNet, String key){
        String value = null;
        if(responseFromNet != null && responseFromNet.startsWith('{'))
        {
            JSONParser parser = JSON.createParser(responseFromNet);
            while (parser !=null && parser.nextToken() != null) 
            {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == key))
                {
                    
                     parser.nextToken();   
                     value = parser.getText();
                     return value;
                }
            }
        }
        return value;
    }
    
    public static Map<String, Object> convertMap(String jsonInput){
        //system.debug('Json data:'+jsonInput);
    try{
      if( jsonInput != null && !jsonInput.equals('null')){
          Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
          return m;
      }
     }catch(Exception e){System.debug('convertMap--' + e);}
      return null;
    }
    
    public static String boolToString(boolean t)
    {
        return (t)?'true':'false';
    }
    
    public String autoCollectionFlag(){
        String settingString = getSiteSettingJSON();
        Map<String, Object> SiteSettingObject = 
            settingString!=null?(Map<String, Object>)JSON.deserializeUntyped(settingString):null;
            
        if( SiteSettingObject != null && SiteSettingObject.get('autoCollectionFlag') != null ){
        
            return (String)SiteSettingObject.get('autoCollectionFlag') ;
        }
        return 'OFF';
    }
    
    public boolean canOverRide(){
        String settingString = getSiteSettingJSON();
        Map<String, Object> siteSettingObject = 
            settingString!=null?(Map<String, Object>)JSON.deserializeUntyped(settingString):null;
            
        if( siteSettingObject != null){
            return siteSettingObject.get('isOverRide') == 'true';
        }
        return false;
    }
    
    public boolean isQuotesEnabled(){
        String settingString = getSiteSettingJSON();
        Map<String, Object> siteSettingObject = 
            settingString!=null?(Map<String, Object>)JSON.deserializeUntyped(settingString):null;
            
        if( siteSettingObject != null){
            return siteSettingObject.get('isQuotesEnabled') == 'true';
        }
        return false;
    }
}