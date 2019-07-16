public class StagingTest{
    public String splchars{get;set;}
    public boolean boolvar{get;set;}
    public CBURLUtil urlUtil{get;set;}
    public StagingTest(){
       
        urlUtil = new CBURLUtil();
  
    }
    public void test(){
        
        string endpointURL = CBSubscriptionUtil.getCreateSubscriptionEndPoint(urlUtil,'1mk51dxR83hukCXu4');
        String bodyData = 'plan_id='+EncodingUtil.urlEncode('new1', 'UTF-8');
        bodyData = CBURLUtil.buildURLString(bodyData,'id',splchars);
        CBURLUtil.sendRequest(endpointURL, bodyData, urlUtil, true);
    }
}