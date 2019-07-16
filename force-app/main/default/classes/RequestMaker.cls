public class RequestMaker{
    
    public URLBuilder builder{get;set;}
    private Map<String,Object> resp;
    private boolean is_err;
    private static chargebeeapps__CB_Settings__c mhc;
    
    public RequestMaker(){
        is_err=false;
        fetchSettings();
    }
    
    public RequestMaker(URLBuilder ub){
        builder=ub;
        is_err=false;
        fetchSettings();
    }
    
    public RequestMaker(URLBuilder ub,chargebeeapps__CB_Settings__c sts){
        builder=ub;
        is_err=false;
        mhc = sts;
    }
    
    private void fetchSettings(){
        if(mhc==null){
            mhc=chargebeeapps__CB_Settings__c.getOrgDefaults();
        }
        
    }
    
    public void setBuilder(URLBuilder ub){
        builder=ub;
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

    
    public Map<String,Object> makeRequest(){
        HttpRequest reqData = new HttpRequest();
        Http http = new Http();
        
        reqData.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        reqData.setHeader('Connection','keep-alive');
        reqData.setTimeout(20000);
        
        
        if(builder.getReqType().toLowerCase().equals('get')){
            reqData.setEndpoint(builder.getEndpointUrl()+'?'+builder.build());
        }else if(builder.getReqType().toLowerCase().equals('post')){
            reqData.setEndpoint(builder.getEndpointUrl());
        } 
        
        
        String username = getApiKey();
        System.debug('key-->>>'+username);
        Blob headerValue = Blob.valueOf(username + ':');
        String authorizationHeader = 'BASIC ' +
        EncodingUtil.base64Encode(headerValue);
        reqData.setHeader('Authorization', authorizationHeader);             
        reqData.setMethod(builder.getReqType());
        
        if(builder.getReqType().toLowerCase().equals('post')){
            if(builder.build()!=null && !builder.build().equals('')){
                
                reqData.setBody(builder.build());
            }
            
        }
        System.debug('builder----'+builder.build());
        String response;
        HTTPResponse res = http.send(reqData);
        system.debug('Req:'+reqData);
        system.debug('Body:'+res.getBody());
        response = res.getBody();
        
        resp = CBURLUtil.convertMap(response);
        
        if(resp.get('error_msg')!=null){
            this.is_err=true;
        }
        return resp;
    }
    
    public boolean isError(){
        return is_err;
    }
    
    public BaseError getErrorObject(){
        return new BaseError(resp); 
    }

}