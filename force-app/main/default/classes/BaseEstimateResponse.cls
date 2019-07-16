public virtual class BaseEstimateResponse{

    private String response{get;set;}
    public Map<String,Object> jsonMap{get;set;}

    public BaseEstimateResponse(String resp){
        response = resp;
        System.debug('resp-----'+resp);
        jsonMap = (Map<String,Object>)JSON.deserializeUntyped(resp);
    }
    
    public String getResponse(){
        return response;
    }
    
    public String getObjectType(){
        return (String)jsonMap.get('object');
    }
    
}