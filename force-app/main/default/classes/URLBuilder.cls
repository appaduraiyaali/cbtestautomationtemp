public virtual class URLBuilder{

    public EndPoint endPoint;
    public String ustring{get;set;}

    public URLBuilder(EndPoint ep){
        endPoint = ep;
        ustring='';
    }
    
    public URLBuilder(){
        ustring='';
    }
    
    public void setEndPoint(EndPoint ep){
        endPoint=ep;
    }
    
    public String build(){
        return ustring;
    }
    
    public String getEndpointUrl(){
        return endPoint.getUrl();
    }
    
    public String getReqType(){
        return endPoint.reqtype.name();
    }
}