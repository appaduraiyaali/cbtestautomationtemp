public class EndPoint{
    private String url;
    public RequestType reqtype{get;set;}
    public String target{get;set;}
    public String partUrl{get;set;}
    private String domain;
    
    public static CBURLUtil util{
    get{
        CBURLUtil util = new CBURLUtil();
        return util;
    }set;}
    public EndPoint(String ul,RequestType rt){
        url=util.getUrl()+ul;
        partUrl=ul;
        reqtype=rt;
        target='\\?';
        
    }
    
    public void domainName(String siteName){
        domain = siteName;
        CBURLUtil temp = new CBURLUtil(siteName);
        system.debug('parturl:'+partUrl);
        url=temp.getUrl()+partUrl;
        system.debug('url:'+url);
        
    }
    public void replace(List<String> rplcg){
        for(String s:rplcg){
            url=url.replaceFirst(target,s);
        }
        
    }
    
    public String getdomainName(){
        return domain;
    }

    public String getUrl() {
        return url;
    }
}